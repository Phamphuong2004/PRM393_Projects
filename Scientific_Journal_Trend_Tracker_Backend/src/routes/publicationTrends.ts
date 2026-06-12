import { Router, Request, Response } from "express";
import {
  authMiddleware,
  roleMiddleware,
  rateLimit,
  rateLimits,
} from "../middleware";
import { validateIdParam, validateInputs } from "../middleware";
import { body } from "express-validator";
import { PublicationTrendService } from "../services";

const router = Router();

// Apply rate limiting
router.use(rateLimit(rateLimits.read));

// Get all publication trends
router.get("/", async (req: Request, res: Response): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;

    const { trends, total, pages } =
      await PublicationTrendService.getAllPublicationTrends(page, limit);

    res.json({
      trends,
      pagination: { page, limit, total, pages },
    });
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// Get trending publications
router.get(
  "/trending/list",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const trends = await PublicationTrendService.getTrendingPublications();
      res.json(trends);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Get publication trend by ID
router.get(
  "/:id",
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const trend = await PublicationTrendService.getPublicationTrendById(
        req.params.id,
      );
      res.json(trend);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Create publication trend (admin only)
router.post(
  "/",
  authMiddleware,
  roleMiddleware(["admin"]),
  rateLimit(rateLimits.write),
  [
    body("keywordId").notEmpty(),
    body("analysisRunId").notEmpty(),
    body("year").isInt(),
    body("paperCount").isInt(),
    body("growthRate").isFloat(),
  ],
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const trend = await PublicationTrendService.createPublicationTrend(
        req.body,
      );
      res.status(201).json(trend);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Update publication trend (admin only)
router.put(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const trend = await PublicationTrendService.updatePublicationTrend(
        req.params.id,
        req.body,
      );
      res.json(trend);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Delete publication trend (admin only)
router.delete(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      await PublicationTrendService.deletePublicationTrend(req.params.id);
      res.json({ message: "Publication trend deleted" });
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Get trends by keyword
router.get(
  "/keyword/:keywordId",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const trends = await PublicationTrendService.getTrendsByKeyword(
        req.params.keywordId,
      );
      res.json(trends);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Get trends by journal
router.get(
  "/journal/:journalId",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const trends = await PublicationTrendService.getTrendsByJournal(
        req.params.journalId,
      );
      res.json(trends);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

export default router;


