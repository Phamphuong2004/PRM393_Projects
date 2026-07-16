import { Router } from "express";
import { DashboardController } from "../controllers/DashboardController";

const router = Router();

// /api/dashboard/stats
router.get("/stats", DashboardController.getDashboardStats);

export default router;
