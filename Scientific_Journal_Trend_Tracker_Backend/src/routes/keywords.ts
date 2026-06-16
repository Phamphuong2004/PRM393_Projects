import { Router, Request, Response } from "express";
import {
  authMiddleware,
  roleMiddleware,
  rateLimit,
  rateLimits,
} from "../middleware";
import {
  validateCreateKeyword,
  validateIdParam,
  validateInputs,
} from "../middleware";
import { KeywordService } from "../services";

const router = Router();

// Apply rate limiting
router.use(rateLimit(rateLimits.read));

// Get all keywords with pagination
router.get("/", async (req: Request, res: Response): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const sort = (req.query.sort as string) || "-trendScore";

    const { keywords, total, pages } = await KeywordService.getAllKeywords(
      page,
      limit,
      sort,
    );

    res.json({
      keywords,
      pagination: { page, limit, total, pages },
    });
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// Get keyword by ID
router.get(
  "/:id",
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const keyword = await KeywordService.getKeywordById(req.params.id);
      res.json(keyword);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Create keyword (admin/researcher only)
router.post(
  "/",
  authMiddleware,
  roleMiddleware(["admin", "researcher"]),
  rateLimit(rateLimits.write),
  validateCreateKeyword,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const keyword = await KeywordService.createKeyword(req.body);
      res.status(201).json(keyword);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Get trending keywords
router.get(
  "/trends/trending",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const limit = parseInt(req.query.limit as string) || 20;
      const keywords = await KeywordService.getTrendingKeywords(limit);
      res.json(keywords);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Update keyword (admin only)
router.put(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const keyword = await KeywordService.updateKeyword(
        req.params.id,
        req.body,
      );
      res.json(keyword);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Delete keyword (admin only)
router.delete(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      await KeywordService.deleteKeyword(req.params.id);
      res.json({ message: "Keyword deleted" });
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

export default router;


