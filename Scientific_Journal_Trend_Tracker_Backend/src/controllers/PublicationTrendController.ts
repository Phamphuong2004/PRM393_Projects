import { Request, Response } from "express";
import { validationResult } from "express-validator";
import PublicationTrend from "../models/PublicationTrend";
import { TrendAnalyzerService } from "../services/TrendAnalyzerService";

export class PublicationTrendController {
  static async analyzeRelatedKeywords(req: Request, res: Response): Promise<void> {
    try {
      const keyword = req.query.keyword as string;
      const source = req.query.source as string || 'OpenAlex';
      const startYear = parseInt(req.query.startYear as string) || 2018;

      if (!keyword) {
        res.status(400).json({ message: "Keyword is required" });
        return;
      }

      const data = await TrendAnalyzerService.analyzeRelatedKeywords(keyword, source, startYear);
      res.json(data);
    } catch (error: any) {
      console.error(error);
      res.status(500).json({ message: error.message || "Server error" });
    }
  }
  static async getAllTrends(req: Request, res: Response): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const skip = (page - 1) * limit;

      const trends = await PublicationTrend.find()
        .populate("keywordId")
        .populate("journalId")
        .populate("analysisRunId")
        .skip(skip)
        .limit(limit)
        .sort({ calculatedAt: -1 });

      const total = await PublicationTrend.countDocuments();

      res.json({
        trends,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit),
        },
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getTrendingPublications(
    req: Request,
    res: Response,
  ): Promise<void> {
    try {
      const trends = await PublicationTrend.find({ isTrending: true })
        .populate("keywordId")
        .populate("journalId")
        .populate("analysisRunId")
        .sort({ growthRate: -1 })
        .limit(50);

      res.json(trends);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getTrendById(req: Request, res: Response): Promise<void> {
    try {
      const trend = await PublicationTrend.findById(req.params.id)
        .populate("keywordId")
        .populate("journalId")
        .populate("analysisRunId");

      if (!trend) {
        res.status(404).json({ message: "Publication trend not found" });
        return;
      }

      res.json(trend);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async createTrend(req: Request, res: Response): Promise<void> {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({ errors: errors.array() });
        return;
      }

      const trend = new PublicationTrend(req.body);
      await trend.save();
      await trend.populate(["keywordId", "journalId", "analysisRunId"]);

      res.status(201).json(trend);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async updateTrend(req: Request, res: Response): Promise<void> {
    try {
      const trend = await PublicationTrend.findByIdAndUpdate(
        req.params.id,
        req.body,
        { new: true },
      ).populate(["keywordId", "journalId", "analysisRunId"]);

      if (!trend) {
        res.status(404).json({ message: "Publication trend not found" });
        return;
      }

      res.json(trend);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async deleteTrend(req: Request, res: Response): Promise<void> {
    try {
      const trend = await PublicationTrend.findByIdAndDelete(req.params.id);

      if (!trend) {
        res.status(404).json({ message: "Publication trend not found" });
        return;
      }

      res.json({ message: "Publication trend deleted" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getTrendsByKeyword(req: Request, res: Response): Promise<void> {
    try {
      const trends = await PublicationTrend.find({
        keywordId: req.params.keywordId,
      })
        .populate("keywordId")
        .populate("journalId")
        .populate("analysisRunId")
        .sort({ year: -1 });

      res.json(trends);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getTrendsByJournal(req: Request, res: Response): Promise<void> {
    try {
      const trends = await PublicationTrend.find({
        journalId: req.params.journalId,
      })
        .populate("keywordId")
        .populate("journalId")
        .populate("analysisRunId")
        .sort({ year: -1 });

      res.json(trends);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
