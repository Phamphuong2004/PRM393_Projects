import { Request, Response } from "express";
import User from "../models/User";
import ApiSource from "../models/ApiSource";
import { SyncService } from "../services/SyncService";

export class AdminController {
  // ==========================================
  // USER MANAGEMENT
  // ==========================================

  static async updateUserStatus(req: Request, res: Response): Promise<void> {
    try {
      const { isActive } = req.body;
      const user = await User.findByIdAndUpdate(
        req.params.id,
        { isActive },
        { new: true }
      ).select("-password");

      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }
      res.json(user);
    } catch (error) {
      console.error("Error updating user status:", error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async updateUserRole(req: Request, res: Response): Promise<void> {
    try {
      const { role } = req.body;
      const validRoles = ["admin", "researcher", "user"];
      if (!validRoles.includes(role)) {
        res.status(400).json({ message: "Invalid role" });
        return;
      }

      const user = await User.findByIdAndUpdate(
        req.params.id,
        { role },
        { new: true }
      ).select("-password");

      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }
      res.json(user);
    } catch (error) {
      console.error("Error updating user role:", error);
      res.status(500).json({ message: "Server error" });
    }
  }

  // ==========================================
  // API SOURCE MANAGEMENT (CRUD)
  // ==========================================

  static async getAllSources(req: Request, res: Response): Promise<void> {
    try {
      const sources = await ApiSource.find().sort({ createdAt: -1 });
      res.json(sources);
    } catch (error) {
      console.error("Error fetching sources:", error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async createSource(req: Request, res: Response): Promise<void> {
    try {
      const source = new ApiSource(req.body);
      await source.save();
      res.status(201).json(source);
    } catch (error: any) {
      console.error("Error creating source:", error);
      if (error.code === 11000) {
        res.status(400).json({ message: "ApiSource name must be unique" });
        return;
      }
      res.status(500).json({ message: "Server error" });
    }
  }

  static async updateSource(req: Request, res: Response): Promise<void> {
    try {
      const source = await ApiSource.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
      });
      if (!source) {
        res.status(404).json({ message: "ApiSource not found" });
        return;
      }
      res.json(source);
    } catch (error) {
      console.error("Error updating source:", error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async deleteSource(req: Request, res: Response): Promise<void> {
    try {
      const source = await ApiSource.findByIdAndDelete(req.params.id);
      if (!source) {
        res.status(404).json({ message: "ApiSource not found" });
        return;
      }
      res.json({ message: "ApiSource deleted" });
    } catch (error) {
      console.error("Error deleting source:", error);
      res.status(500).json({ message: "Server error" });
    }
  }

  // ==========================================
  // SYNC TRIGGER
  // ==========================================

  static async triggerManualSync(req: Request, res: Response): Promise<void> {
    try {
      console.log("[Admin] Manual sync triggered");
      // Fire and forget (don't await) so we don't timeout the HTTP request
      SyncService.syncPapers().catch(err => {
        console.error("Manual sync failed in background:", err);
      });
      
      res.json({ message: "Sync process started in the background" });
    } catch (error) {
      console.error("Error triggering sync:", error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
