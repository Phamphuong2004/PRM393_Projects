import { Router, Request, Response } from "express";
import { authMiddleware, rateLimit, rateLimits } from "../middleware";
import { BookmarkService } from "../services";

const router = Router();

// Apply rate limiting
router.use(authMiddleware);
router.use(rateLimit(rateLimits.api));

// Get user bookmarks
router.get("/", async (req: Request, res: Response): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;

    const { bookmarks, total, pages } = await BookmarkService.getUserBookmarks(
      req.userId!,
      page,
      limit,
    );

    res.json({
      bookmarks,
      pagination: { page, limit, total, pages },
    });
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// Check if paper is bookmarked
router.get(
  "/:paperId/check",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const result = await BookmarkService.checkBookmark(
        req.userId!,
        req.params.paperId,
      );
      res.json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Add bookmark
router.post("/:paperId", async (req: Request, res: Response): Promise<void> => {
  try {
    const result = await BookmarkService.addBookmark(
      req.userId!,
      req.params.paperId,
    );
    res.json(result);
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// Remove bookmark
router.delete(
  "/:paperId",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const result = await BookmarkService.removeBookmark(
        req.userId!,
        req.params.paperId,
      );
      res.json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

export default router;
