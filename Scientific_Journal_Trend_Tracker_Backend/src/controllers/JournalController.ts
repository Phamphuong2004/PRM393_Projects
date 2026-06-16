import { Request, Response } from "express";
import { validationResult } from "express-validator";
import Journal from "../models/Journal";

export class JournalController {
  static async getAllJournals(req: Request, res: Response): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const skip = (page - 1) * limit;

      const journals = await Journal.find()
        .skip(skip)
        .limit(limit)
        .sort({ name: 1 });

      const total = await Journal.countDocuments();

      res.json({
        journals,
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

  static async getJournalById(req: Request, res: Response): Promise<void> {
    try {
      const journal = await Journal.findById(req.params.id);

      if (!journal) {
        res.status(404).json({ message: "Journal not found" });
        return;
      }

      res.json(journal);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async createJournal(req: Request, res: Response): Promise<void> {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({ errors: errors.array() });
        return;
      }

      const journal = new Journal(req.body);
      await journal.save();

      res.status(201).json(journal);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async updateJournal(req: Request, res: Response): Promise<void> {
    try {
      const journal = await Journal.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
      });

      if (!journal) {
        res.status(404).json({ message: "Journal not found" });
        return;
      }

      res.json(journal);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async deleteJournal(req: Request, res: Response): Promise<void> {
    try {
      const journal = await Journal.findByIdAndDelete(req.params.id);

      if (!journal) {
        res.status(404).json({ message: "Journal not found" });
        return;
      }

      res.json({ message: "Journal deleted" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
