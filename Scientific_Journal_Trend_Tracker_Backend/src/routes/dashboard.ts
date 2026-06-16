import { Router } from "express";
import { DashboardController } from "../controllers/DashboardController";

const router = Router();

/**
 * @route GET /api/dashboard/stats
 * @desc Get dashboard statistics (top keywords, journals, timeline)
 * @access Public (or require auth depending on requirements)
 */
router.get("/stats", DashboardController.getStats);

export default router;
