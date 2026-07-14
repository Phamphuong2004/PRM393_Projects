import { Router } from "express";
import { authMiddleware, rateLimit, rateLimits } from "../middleware";
import { BookmarkController } from "../controllers/BookmarkController";

const router = Router();

// Apply rate limiting
router.use(authMiddleware);
router.use(rateLimit(rateLimits.api));

// Get user bookmarks
router.get("/", BookmarkController.getUserBookmarks);

// Check if paper is bookmarked
router.get("/:paperId/check", BookmarkController.checkBookmark);

// Add bookmark
router.post("/:paperId", BookmarkController.addBookmark);

// Remove bookmark
router.delete("/:paperId", BookmarkController.removeBookmark);

export default router;
