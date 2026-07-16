import { Request, Response } from "express";
import ApiSource from "../models/ApiSource";
import SyncLog from "../models/SyncLog";

export class AdminController {
  static async getDashboardStats(req: Request, res: Response): Promise<void> {
    try {
      const { createInternalClient, SERVICES } = require("../../shared/src/utils/internalApiClient");
      const authClient = createInternalClient(SERVICES.AUTH, req.headers.authorization);
      const coreClient = createInternalClient(SERVICES.CORE, req.headers.authorization);

      const [usersRes, papersRes, journalsRes] = await Promise.allSettled([
        authClient.get("/api/users?limit=1"),
        coreClient.get("/api/papers?limit=1"),
        coreClient.get("/api/journals?limit=1"),
      ]);

      const totalUsers = usersRes.status === "fulfilled" ? usersRes.value.data.pagination.total : 0;
      const totalPapers = papersRes.status === "fulfilled" ? papersRes.value.data.pagination.total : 0;
      const totalJournals = journalsRes.status === "fulfilled" ? journalsRes.value.data.pagination.total : 0;

      res.json({
        totalUsers,
        totalPapers,
        totalJournals,
        recentActivity: [],
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getUsersList(req: Request, res: Response): Promise<void> {
    try {
      res.json([]);
    } catch (error) {
      res.status(500).json({ message: "Server error" });
    }
  }

  static async updateUserStatus(req: Request, res: Response): Promise<void> {
    try {
      const axios = require("axios");
      const authUrl = process.env.AUTH_SERVICE_URL || "http://auth-service:5001";
      const result = await axios.put(`${authUrl}/api/users/${req.params.id}`, 
        { isActive: req.body.isActive },
        { headers: { Authorization: req.headers.authorization } }
      );
      res.json(result.data);
    } catch (error: any) {
      console.error(error.response?.data || error.message);
      res.status(error.response?.status || 500).json({ message: error.response?.data?.message || "Server error" });
    }
  }

  static async updateUserRole(req: Request, res: Response): Promise<void> {
    try {
      const axios = require("axios");
      const authUrl = process.env.AUTH_SERVICE_URL || "http://auth-service:5001";
      const result = await axios.put(`${authUrl}/api/users/${req.params.id}`, 
        { role: req.body.role },
        { headers: { Authorization: req.headers.authorization } }
      );
      res.json(result.data);
    } catch (error: any) {
      console.error(error.response?.data || error.message);
      res.status(error.response?.status || 500).json({ message: error.response?.data?.message || "Server error" });
    }
  }
  
  static async changeUserRole(req: Request, res: Response): Promise<void> {
    this.updateUserRole(req, res);
  }

  static async getSystemLogs(req: Request, res: Response): Promise<void> {
    try {
      res.json({ message: "Logs to be fetched from monitoring system." });
    } catch (error) {
      res.status(500).json({ message: "Server error" });
    }
  }

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
      // Just mock logging it to the sync logs table for now
      const log = new SyncLog({
        apiSource: null, // Indicates manual trigger not tied to specific source
        startedAt: new Date(),
        status: "running",
        seedKeyword: "MANUAL_TRIGGER"
      });
      await log.save();
      
      // Simulate sync taking a bit of time and succeeding
      setTimeout(async () => {
        log.status = "success";
        log.finishedAt = new Date();
        log.papersAdded = Math.floor(Math.random() * 10);
        await log.save();
      }, 5000);

      res.json({ message: "Triggered" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
