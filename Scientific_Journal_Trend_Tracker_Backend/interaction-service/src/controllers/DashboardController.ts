import { Request, Response } from "express";


import { createInternalClient, SERVICES } from "../utils/internalApiClient";

export class DashboardController {
  static async getDashboardStats(req: Request, res: Response): Promise<void> {
    try {
      const coreClient = createInternalClient(SERVICES.CORE, req.headers.authorization);
      const response = await coreClient.get("/api/dashboard/stats");
      res.json(response.data);
    } catch (error: any) {
      console.error("Error fetching dashboard stats from core-service:", error.message);
      res.status(500).json({ message: "Server error while fetching dashboard stats" });
    }
  }

  static async getUserDashboard(req: Request, res: Response): Promise<void> {
    try {
      res.json({
        message: "User Dashboard aggregation needs to be implemented via API Composition.",
        bookmarks: [],
        recentSearches: [],
        recentAnalysis: []
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
