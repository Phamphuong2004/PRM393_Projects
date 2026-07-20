import { Request, Response } from "express";
import ApiSource from "../models/ApiSource";
import SyncLog from "../models/SyncLog";
import Notification from "../models/Notification";
import axios from "axios";

export class AdminController {


  static async getAllSources(req: Request, res: Response): Promise<void> {
    try {
      const sources = await ApiSource.find().sort({ createdAt: -1 });
      res.json(sources);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async createSource(req: Request, res: Response): Promise<void> {
    try {
      const newSource = new ApiSource(req.body);
      await newSource.save();
      res.status(201).json(newSource);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async updateSource(req: Request, res: Response): Promise<void> {
    try {
      const updatedSource = await ApiSource.findByIdAndUpdate(
        req.params.id,
        req.body,
        { new: true }
      );
      if (!updatedSource) {
        res.status(404).json({ message: "Source not found" });
        return;
      }
      res.json(updatedSource);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async deleteSource(req: Request, res: Response): Promise<void> {
    try {
      const deletedSource = await ApiSource.findByIdAndDelete(req.params.id);
      if (!deletedSource) {
        res.status(404).json({ message: "Source not found" });
        return;
      }
      res.json({ message: "Deleted" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async triggerManualSync(req: Request, res: Response): Promise<void> {
    try {
      const source = await ApiSource.findOne();
      const log = new SyncLog({
        apiSource: source ? source._id : null,
        startedAt: new Date(),
        status: "running",
        seedKeyword: "Artificial Intelligence"
      });
      await log.save();
      
      // Fire and forget background process (Ponytail ultra mode)
      (async () => {
        try {
          const CORE_URL = process.env.CORE_SERVICE_URL || "http://core-service:5002";
          const searchRes = await axios.get(`${CORE_URL}/api/papers/external/search`, {
            params: { q: "Artificial Intelligence", limit: 3, source: "Semantic Scholar" }
          });
          
          let added = 0;
          for (const paper of searchRes.data.papers || []) {
             try {
                await axios.post(`${CORE_URL}/api/papers/import`, paper, {
                   headers: { Authorization: req.headers.authorization }
                });
                added++;
             } catch (e) { /* ignore duplicate/error */ }
          }
          
          log.status = "success";
          log.papersAdded = added;
          log.finishedAt = new Date();
          await log.save();
          
          // Create notification
          const userId = (req as any).userId || (req as any).user?.id;
          if (userId) {
            await new Notification({
              userId,
              title: "ETL Sync Completed",
              message: `Successfully synchronized and imported ${added} papers.`,
              type: "system",
              isRead: false
            }).save();
          }
        } catch (e: any) {
          log.status = "failed";
          log.errorMessage = e.message;
          log.finishedAt = new Date();
          await log.save();
          
          // Create error notification
          const userId = (req as any).userId || (req as any).user?.id;
          if (userId) {
            await new Notification({
              userId,
              title: "ETL Sync Failed",
              message: `Sync failed: ${e.message}`,
              type: "error",
              isRead: false
            }).save();
          }
        }
      })();

      res.json({ message: "ETL Sync Triggered" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
