import { Request, Response } from "express";
import { validationResult } from "express-validator";
import Keyword from "../models/Keyword";

export class KeywordController {
  static async getAllKeywords(req: Request, res: Response): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;
      const skip = (page - 1) * limit;
      const sort = (req.query.sort as string) || "-trendScore";

      const keywords = await Keyword.find().skip(skip).limit(limit).sort(sort);

      const total = await Keyword.countDocuments();

      res.json({
        keywords,
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

  static async getKeywordById(req: Request, res: Response): Promise<void> {
    try {
      const keyword = await Keyword.findById(req.params.id);

      if (!keyword) {
        res.status(404).json({ message: "Keyword not found" });
        return;
      }

      res.json(keyword);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async createKeyword(req: Request, res: Response): Promise<void> {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({ errors: errors.array() });
        return;
      }

      const keyword = new Keyword(req.body);
      await keyword.save();

      res.status(201).json(keyword);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async updateKeyword(req: Request, res: Response): Promise<void> {
    try {
      const keyword = await Keyword.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
      });

      if (!keyword) {
        res.status(404).json({ message: "Keyword not found" });
        return;
      }

      res.json(keyword);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async deleteKeyword(req: Request, res: Response): Promise<void> {
    try {
      const keyword = await Keyword.findByIdAndDelete(req.params.id);

      if (!keyword) {
        res.status(404).json({ message: "Keyword not found" });
        return;
      }

      res.json({ message: "Keyword deleted" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getTrendingKeywords(req: Request, res: Response): Promise<void> {
    try {
      const keywords = await Keyword.find().sort({ trendScore: -1 }).limit(20);

      res.json(keywords);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
