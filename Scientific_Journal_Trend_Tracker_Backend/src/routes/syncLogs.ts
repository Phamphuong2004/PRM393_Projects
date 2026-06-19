import { Router, Request, Response } from "express";
import {
  authMiddleware,
  roleMiddleware,
  rateLimit,
  rateLimits,
} from "../middleware";
import { validateIdParam, validateInputs } from "../middleware";
import { SyncLogService } from "../services";

const router = Router();

// Apply auth middleware and admin role restriction to all syncLog routes
router.use(authMiddleware);
router.use(roleMiddleware(["admin"]));
router.use(rateLimit(rateLimits.read));

// Get all sync logs (paginated + status filter)
router.get("/", async (req: Request, res: Response): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const status = req.query.status as string;

    const { logs, total, pages } = await SyncLogService.getAllSyncLogs(
      page,
      limit,
      status
    );

    res.json({
      logs,
      pagination: { page, limit, total, pages },
    });
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// Get sync log by ID
router.get(
  "/:id",
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const log = await SyncLogService.getSyncLogById(req.params.id);
      res.json(log);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Delete sync log
router.delete(
  "/:id",
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      await SyncLogService.deleteSyncLog(req.params.id);
      res.json({ message: "Sync log deleted" });
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Clear/Purge all sync logs
router.delete(
  "/",
  rateLimit(rateLimits.write),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const result = await SyncLogService.clearAllSyncLogs();
      res.json({ message: "All sync logs cleared", deletedCount: result.deletedCount });
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

export default router;
