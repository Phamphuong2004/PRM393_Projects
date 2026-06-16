"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const middleware_1 = require("../middleware");
const services_1 = require("../services");
const router = (0, express_1.Router)();
// Apply rate limiting
router.use(middleware_1.authMiddleware);
router.use((0, middleware_1.rateLimit)(middleware_1.rateLimits.api));
// Get user bookmarks
router.get("/", async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const { bookmarks, total, pages } = await services_1.BookmarkService.getUserBookmarks(req.userId, page, limit);
        res.json({
            bookmarks,
            pagination: { page, limit, total, pages },
        });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Check if paper is bookmarked
router.get("/:paperId/check", async (req, res) => {
    try {
        const result = await services_1.BookmarkService.checkBookmark(req.userId, req.params.paperId);
        res.json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Add bookmark
router.post("/:paperId", async (req, res) => {
    try {
        const result = await services_1.BookmarkService.addBookmark(req.userId, req.params.paperId);
        res.json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Remove bookmark
router.delete("/:paperId", async (req, res) => {
    try {
        const result = await services_1.BookmarkService.removeBookmark(req.userId, req.params.paperId);
        res.json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
exports.default = router;
//# sourceMappingURL=bookmarks.js.map