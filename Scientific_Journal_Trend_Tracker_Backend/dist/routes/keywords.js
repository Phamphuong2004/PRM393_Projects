"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const middleware_1 = require("../middleware");
const middleware_2 = require("../middleware");
const services_1 = require("../services");
const router = (0, express_1.Router)();
// Apply rate limiting
router.use((0, middleware_1.rateLimit)(middleware_1.rateLimits.read));
// Get all keywords with pagination
router.get("/", async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const sort = req.query.sort || "-trendScore";
        const { keywords, total, pages } = await services_1.KeywordService.getAllKeywords(page, limit, sort);
        res.json({
            keywords,
            pagination: { page, limit, total, pages },
        });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get keyword by ID
router.get("/:id", middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        const keyword = await services_1.KeywordService.getKeywordById(req.params.id);
        res.json(keyword);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Create keyword (admin/researcher only)
router.post("/", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin", "researcher"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateCreateKeyword, middleware_2.validateInputs, async (req, res) => {
    try {
        const keyword = await services_1.KeywordService.createKeyword(req.body);
        res.status(201).json(keyword);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get trending keywords
router.get("/trends/trending", async (req, res) => {
    try {
        const limit = parseInt(req.query.limit) || 20;
        const keywords = await services_1.KeywordService.getTrendingKeywords(limit);
        res.json(keywords);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Update keyword (admin only)
router.put("/:id", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        const keyword = await services_1.KeywordService.updateKeyword(req.params.id, req.body);
        res.json(keyword);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Delete keyword (admin only)
router.delete("/:id", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        await services_1.KeywordService.deleteKeyword(req.params.id);
        res.json({ message: "Keyword deleted" });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
exports.default = router;
//# sourceMappingURL=keywords.js.map