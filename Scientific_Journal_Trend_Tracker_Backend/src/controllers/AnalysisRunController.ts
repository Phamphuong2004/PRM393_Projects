import { Request, Response } from "express";
import { validationResult } from "express-validator";
import AnalysisRun from "../models/AnalysisRun";

export class AnalysisRunController {
  static async getAllAnalysisRuns(req: Request, res: Response): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const skip = (page - 1) * limit;

      const runs = await AnalysisRun.find()
        .populate("keywordId")
        .populate("syncLogId")
        .populate("topicId")
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 });

      const total = await AnalysisRun.countDocuments();

      res.json({
        runs,
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

  static async getAnalysisRunById(req: Request, res: Response): Promise<void> {
    try {
      const run = await AnalysisRun.findById(req.params.id)
        .populate("keywordId")
        .populate("syncLogId")
        .populate("topicId");

      if (!run) {
        res.status(404).json({ message: "Analysis run not found" });
        return;
      }

      res.json(run);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async createAnalysisRun(req: Request, res: Response): Promise<void> {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({ errors: errors.array() });
        return;
      }

      const run = new AnalysisRun(req.body);
      await run.save();
      await run.populate(["keywordId", "syncLogId", "topicId"]);

      res.status(201).json(run);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async updateAnalysisRun(req: Request, res: Response): Promise<void> {
    try {
      const run = await AnalysisRun.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
      }).populate(["keywordId", "syncLogId", "topicId"]);

      if (!run) {
        res.status(404).json({ message: "Analysis run not found" });
        return;
      }

      res.json(run);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async deleteAnalysisRun(req: Request, res: Response): Promise<void> {
    try {
      const run = await AnalysisRun.findByIdAndDelete(req.params.id);

      if (!run) {
        res.status(404).json({ message: "Analysis run not found" });
        return;
      }

      res.json({ message: "Analysis run deleted" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getAnalysisRunsByKeyword(
    req: Request,
    res: Response,
  ): Promise<void> {
    try {
      const runs = await AnalysisRun.find({ keywordId: req.params.keywordId })
        .populate("keywordId")
        .populate("syncLogId")
        .populate("topicId")
        .sort({ createdAt: -1 });

      res.json(runs);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
