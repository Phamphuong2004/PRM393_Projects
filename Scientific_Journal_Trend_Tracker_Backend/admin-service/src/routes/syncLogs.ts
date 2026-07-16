import express from "express";
import { SyncLogController } from "../controllers/SyncLogController";
import { authMiddleware, roleMiddleware } from "../middleware/auth";

const router = express.Router();

// Apply middleware to all sync log routes
router.use(authMiddleware);
router.use(roleMiddleware(["admin"]));

// Sync Logs
router.get("/", SyncLogController.getSyncLogs);
router.get("/:id", SyncLogController.getSyncLogById);

export default router;
