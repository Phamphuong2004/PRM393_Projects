import { Router, Request, Response } from "express";
import {
  authMiddleware,
  rateLimit,
  rateLimits,
  validateInputs,
} from "../middleware";
import { body } from "express-validator";
import { FollowService } from "../services";

const router = Router();

// Apply middleware
router.use(authMiddleware);
router.use(rateLimit(rateLimits.api));

// Get user follows
router.get("/", async (req: Request, res: Response): Promise<void> => {
  try {
    const follows = await FollowService.getUserFollows(req.userId!);
    res.json(follows);
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// Follow keyword or journal
router.post(
  "/",
  [
    body("targetType").isIn(["Keyword", "Journal"]),
    body("targetId").notEmpty(),
  ],
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const { targetType, targetId, notifyEnabled } = req.body;
      const result = await FollowService.addFollow(
        req.userId!,
        targetType,
        targetId,
        notifyEnabled,
      );
      res.json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Unfollow keyword or journal
router.delete(
  "/:targetId",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const result = await FollowService.removeFollow(
        req.userId!,
        req.params.targetId,
      );
      res.json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Get user tracked runs
router.get(
  "/tracked-runs",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const trackedRuns = await FollowService.getTrackedRuns(req.userId!);
      res.json(trackedRuns);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Track analysis run
router.post(
  "/tracked-runs/:analysisRunId",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const result = await FollowService.trackAnalysisRun(
        req.userId!,
        req.params.analysisRunId,
        req.body.notifyEnabled,
      );
      res.json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Untrack analysis run
router.delete(
  "/tracked-runs/:analysisRunId",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const result = await FollowService.untrackAnalysisRun(
        req.userId!,
        req.params.analysisRunId,
      );
      res.json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Update notification preference for tracked run
router.put(
  "/tracked-runs/:analysisRunId/notify",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const result = await FollowService.updateTrackedRunNotification(
        req.userId!,
        req.params.analysisRunId,
        req.body.notifyEnabled,
      );
      res.json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

export default router;
