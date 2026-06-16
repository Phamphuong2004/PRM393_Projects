import { Request, Response } from "express";
import { validationResult } from "express-validator";
import Paper from "../models/Paper";

export class PaperController {
  static async getAllPapers(req: Request, res: Response): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const skip = (page - 1) * limit;

      const papers = await Paper.find()
        .populate("authors")
        .populate("journalId")
        .populate("keywords")
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 });

      const total = await Paper.countDocuments();

      res.json({
        papers,
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

  static async getPaperById(req: Request, res: Response): Promise<void> {
    try {
      const paper = await Paper.findById(req.params.id)
        .populate("authors")
        .populate("journalId")
        .populate("keywords")
        .populate("topics");

      if (!paper) {
        res.status(404).json({ message: "Paper not found" });
        return;
      }

      res.json(paper);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async createPaper(req: Request, res: Response): Promise<void> {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({ errors: errors.array() });
        return;
      }

      const paper = new Paper(req.body);
      await paper.save();
      await paper.populate(["authors", "journalId", "keywords"]);

      res.status(201).json(paper);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async updatePaper(req: Request, res: Response): Promise<void> {
    try {
      const paper = await Paper.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
      }).populate(["authors", "journalId", "keywords"]);

      if (!paper) {
        res.status(404).json({ message: "Paper not found" });
        return;
      }

      res.json(paper);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async deletePaper(req: Request, res: Response): Promise<void> {
    try {
      const paper = await Paper.findByIdAndDelete(req.params.id);

      if (!paper) {
        res.status(404).json({ message: "Paper not found" });
        return;
      }

      res.json({ message: "Paper deleted" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async searchPapers(req: Request, res: Response): Promise<void> {
    try {
      const { q, year, journalId } = req.query;
      const query: any = {};

      if (q) {
        query.$or = [
          { title: { $regex: q, $options: "i" } },
          { abstract: { $regex: q, $options: "i" } },
        ];
      }

      if (year) {
        query.publicationYear = year;
      }

      if (journalId) {
        query.journalId = journalId;
      }

      const papers = await Paper.find(query)
        .populate("authors")
        .populate("journalId")
        .limit(50);

      res.json(papers);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
