import { Request, Response } from "express";

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
      res.json({ message: "Must be done via Auth Service API." });
    } catch (error) {
      res.status(500).json({ message: "Server error" });
    }
  }

  static async updateUserRole(req: Request, res: Response): Promise<void> {
    try {
      res.json({ message: "Must be done via Auth Service API." });
    } catch (error) {
      res.status(500).json({ message: "Server error" });
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
    res.json([]);
  }

  static async createSource(req: Request, res: Response): Promise<void> {
    res.json({});
  }

  static async updateSource(req: Request, res: Response): Promise<void> {
    res.json({});
  }

  static async deleteSource(req: Request, res: Response): Promise<void> {
    res.json({ message: "Deleted" });
  }

  static async triggerManualSync(req: Request, res: Response): Promise<void> {
    res.json({ message: "Triggered" });
  }
}
