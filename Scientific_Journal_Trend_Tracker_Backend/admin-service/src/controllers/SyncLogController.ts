import { Request, Response } from "express";
import SyncLog from "../models/SyncLog";

export class SyncLogController {
  static async getSyncLogs(req: Request, res: Response): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;
      const skip = (page - 1) * limit;

      const logs = await SyncLog.find()
        .populate("apiSource", "name type url")
        .skip(skip)
        .limit(limit)
        .sort({ startedAt: -1 });

      const total = await SyncLog.countDocuments();

      // Transform the populated apiSource to include sourceName so frontend doesn't break
      const formattedLogs = logs.map(log => {
        const logObj = log.toObject();
        let sourceName = "Unknown Source";
        if (log.apiSource) {
          const src = log.apiSource as any;
          if (src.name) {
            sourceName = src.name;
          } else if (src._id) {
            sourceName = `Source ID: ${src._id}`;
          }
        }
        return {
          ...logObj,
          sourceName,
        };
      });

      res.json({
        logs: formattedLogs,
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

  static async getSyncLogById(req: Request, res: Response): Promise<void> {
    try {
      const log = await SyncLog.findById(req.params.id).populate("apiSource", "name type url");

      if (!log) {
        res.status(404).json({ message: "Sync log not found" });
        return;
      }

      const logObj = log.toObject();
      let sourceName = "Unknown Source";
      if (log.apiSource) {
        const src = log.apiSource as any;
        if (src.name) {
          sourceName = src.name;
        } else if (src._id) {
          sourceName = `Source ID: ${src._id}`;
        }
      }

      res.json({
        ...logObj,
        sourceName,
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
