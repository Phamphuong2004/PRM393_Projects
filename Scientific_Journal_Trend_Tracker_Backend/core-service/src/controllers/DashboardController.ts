import { Request, Response } from "express";
import Paper from "../models/Paper";
import Journal from "../models/Journal";
import Keyword from "../models/Keyword";
import Author from "../models/Author";

export class DashboardController {
  static async getDashboardStats(req: Request, res: Response): Promise<void> {
    try {
      // Run counts in parallel
      const [
        totalPapers,
        totalJournals,
        totalKeywords,
        totalAuthors,
        recentPapers,
        topKeywords,
        topJournals,
      ] = await Promise.all([
        Paper.countDocuments(),
        Journal.countDocuments(),
        Keyword.countDocuments(),
        Author.countDocuments(),
        Paper.find().sort({ publicationYear: -1, createdAt: -1 }).limit(5).populate('journalId').lean(),
        Keyword.find().sort({ paperCount: -1 }).limit(8).lean(),
        Journal.find().sort({ paperCount: -1 }).limit(5).lean(),
      ]);

      // Generate timeline data for the last 10 years
      const currentYear = new Date().getFullYear();
      const startYear = currentYear - 9;
      
      const timelineAggregation = await Paper.aggregate([
        {
          $match: {
            publicationYear: { $gte: startYear, $lte: currentYear }
          }
        },
        {
          $group: {
            _id: "$publicationYear",
            paperCount: { $sum: 1 }
          }
        },
        {
          $sort: { _id: 1 }
        }
      ]);

      const timelineMap = new Map();
      timelineAggregation.forEach((item: any) => timelineMap.set(item._id, item.paperCount));

      const timelineData = [];
      for (let y = startYear; y <= currentYear; y++) {
        timelineData.push({
          year: y.toString(),
          paperCount: timelineMap.get(y) || 0,
          citationCount: 0 // Optional: can be computed similarly if needed
        });
      }

      res.json({
        totalPapers,
        totalJournals,
        totalKeywords,
        totalAuthors,
        recentPapers,
        topKeywords,
        topJournals,
        timelineData
      });
    } catch (error: any) {
      console.error("Dashboard Stats Error:", error);
      res.status(500).json({ message: "Failed to get dashboard stats" });
    }
  }
}
