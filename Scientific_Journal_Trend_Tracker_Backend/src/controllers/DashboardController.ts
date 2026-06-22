import { Request, Response } from "express";
import Paper from "../models/Paper";
import Keyword from "../models/Keyword";
import Journal from "../models/Journal";
import redisClient from "../config/redis";

export class DashboardController {
  static async getStats(req: Request, res: Response): Promise<void> {
    try {
      // Allow optional year filtering
      const year = req.query.year ? parseInt(req.query.year as string) : null;
      
      const cacheKey = `dashboard:stats${year ? ':' + year : ''}`;
      
      // Try to fetch from Redis
      let cachedData = null;
      try {
        cachedData = await redisClient.get(cacheKey);
      } catch (redisError) {
        console.warn("Redis GET error (falling back to DB):", redisError);
      }

      if (cachedData) {
        res.json(JSON.parse(cachedData));
        return;
      }

      // Base query for Papers
      const matchStage = year ? { publicationYear: year } : {};

      // 1. Top 10 Keywords
      const topKeywordsAgg = await Paper.aggregate([
        { $match: matchStage },
        { $unwind: "$keywords" },
        { $group: { _id: "$keywords", count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 10 }
      ]);

      const keywordIds = topKeywordsAgg.map(k => k._id);
      const keywords = await Keyword.find({ _id: { $in: keywordIds } });
      const topKeywords = topKeywordsAgg.map(k => {
        const keyword = keywords.find(kw => kw._id.toString() === k._id.toString());
        return {
          _id: k._id,
          name: keyword ? keyword.name : "Unknown",
          count: k.count
        };
      });

      // 2. Top 10 Journals
      const topJournalsAgg = await Paper.aggregate([
        { $match: matchStage },
        { $match: { journalId: { $ne: null } } },
        { $group: { _id: "$journalId", count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 10 }
      ]);

      const journalIds = topJournalsAgg.map(j => j._id);
      const journals = await Journal.find({ _id: { $in: journalIds } });
      const topJournals = topJournalsAgg.map(j => {
        const journal = journals.find(jo => jo._id.toString() === j._id.toString());
        return {
          _id: j._id,
          name: journal ? journal.name : "Unknown",
          count: j.count
        };
      });

      // 3. Timeline data (Year x PaperCount)
      const timelineDataAgg = await Paper.aggregate([
        { $match: { publicationYear: { $ne: null } } },
        { $group: { _id: "$publicationYear", paperCount: { $sum: 1 } } },
        { $sort: { _id: 1 } } // Sort by year ascending
      ]);

      const timelineData = timelineDataAgg.map(t => ({
        year: t._id,
        paperCount: t.paperCount
      }));

      const responseData = {
        topKeywords,
        topJournals,
        timelineData,
        generatedAt: new Date()
      };

      // Cache for 1 hour
      try {
        await redisClient.setex(cacheKey, 3600, JSON.stringify(responseData));
      } catch (redisError) {
        console.warn("Redis SET error:", redisError);
      }

      res.json(responseData);
    } catch (error) {
      console.error("Dashboard Stats Error:", error);
      res.status(500).json({ message: "Server error generating dashboard stats" });
    }
  }
}
