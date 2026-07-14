import { Request, Response } from "express";
import { validationResult } from "express-validator";
import Topic from "../models/Topic";

export class TopicController {
  static async getAllTopics(req: Request, res: Response): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const skip = (page - 1) * limit;

      const topics = await Topic.find()
        .populate("analysisRunId")
        .populate("papers")
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 });

      const total = await Topic.countDocuments();

      res.json({
        topics,
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

  static async getTopicById(req: Request, res: Response): Promise<void> {
    try {
      const topic = await Topic.findById(req.params.id)
        .populate("analysisRunId")
        .populate("papers");

      if (!topic) {
        res.status(404).json({ message: "Topic not found" });
        return;
      }

      res.json(topic);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async createTopic(req: Request, res: Response): Promise<void> {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({ errors: errors.array() });
        return;
      }

      const topic = new Topic(req.body);
      await topic.save();
      await topic.populate(["analysisRunId", "papers"]);

      res.status(201).json(topic);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async updateTopic(req: Request, res: Response): Promise<void> {
    try {
      const topic = await Topic.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
      }).populate(["analysisRunId", "papers"]);

      if (!topic) {
        res.status(404).json({ message: "Topic not found" });
        return;
      }

      res.json(topic);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async deleteTopic(req: Request, res: Response): Promise<void> {
    try {
      const topic = await Topic.findByIdAndDelete(req.params.id);

      if (!topic) {
        res.status(404).json({ message: "Topic not found" });
        return;
      }

      res.json({ message: "Topic deleted" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getEmergingTopics(req: Request, res: Response): Promise<void> {
    try {
      const topics = await Topic.find({ isEmerging: true })
        .populate("analysisRunId")
        .populate("papers")
        .sort({ createdAt: -1 });

      res.json(topics);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
