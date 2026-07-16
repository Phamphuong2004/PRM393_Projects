import { Router, Request, Response } from "express";
import {
  authMiddleware,
  roleMiddleware,
  rateLimit,
  rateLimits,
} from "../middleware";
import { validateIdParam, validateInputs } from "../middleware";
import { body } from "express-validator";
import { AnalysisRunService } from "../services/AnalysisRunService";

const router = Router();

// Apply rate limiting
router.use(rateLimit(rateLimits.read));

// Get all analysis runs
router.get("/", async (req: Request, res: Response): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;

    const { runs, total, pages } = await AnalysisRunService.getAllAnalysisRuns(
      page,
      limit,
    );

    res.json({
      runs,
      pagination: { page, limit, total, pages },
    });
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// Get analysis run by ID
router.get(
  "/:id",
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const run = await AnalysisRunService.getAnalysisRunById(req.params.id);
      res.json(run);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Create analysis run (admin/researcher only)
router.post(
  "/",
  authMiddleware,
  roleMiddleware(["admin", "researcher"]),
  rateLimit(rateLimits.write),
  [body("keywordId").notEmpty(), body("seedKeyword").notEmpty()],
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const run = await AnalysisRunService.createAnalysisRun(req.body);
      res.status(201).json(run);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Update analysis run (admin only)
router.put(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const run = await AnalysisRunService.updateAnalysisRun(
        req.params.id,
        req.body,
      );
      res.json(run);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Delete analysis run (admin only)
router.delete(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      await AnalysisRunService.deleteAnalysisRun(req.params.id);
      res.json({ message: "Analysis run deleted" });
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Get analysis runs by keyword
router.get(
  "/keyword/:keywordId",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const runs = await AnalysisRunService.getAnalysisRunsByKeyword(
        req.params.keywordId,
      );
      res.json(runs);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

export default router;


