"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const middleware_1 = require("../middleware");
const middleware_2 = require("../middleware");
const express_validator_1 = require("express-validator");
const services_1 = require("../services");
const router = (0, express_1.Router)();
// Apply rate limiting
router.use((0, middleware_1.rateLimit)(middleware_1.rateLimits.read));
// Get all publication trends
router.get("/", async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const { trends, total, pages } = await services_1.PublicationTrendService.getAllPublicationTrends(page, limit);
        res.json({
            trends,
            pagination: { page, limit, total, pages },
        });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get trending publications
router.get("/trending/list", async (req, res) => {
    try {
        const trends = await services_1.PublicationTrendService.getTrendingPublications();
        res.json(trends);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get publication trend by ID
router.get("/:id", middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        const trend = await services_1.PublicationTrendService.getPublicationTrendById(req.params.id);
        res.json(trend);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Create publication trend (admin only)
router.post("/", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), [
    (0, express_validator_1.body)("keywordId").notEmpty(),
    (0, express_validator_1.body)("analysisRunId").notEmpty(),
    (0, express_validator_1.body)("year").isInt(),
    (0, express_validator_1.body)("paperCount").isInt(),
    (0, express_validator_1.body)("growthRate").isFloat(),
], middleware_2.validateInputs, async (req, res) => {
    try {
        const trend = await services_1.PublicationTrendService.createPublicationTrend(req.body);
        res.status(201).json(trend);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Update publication trend (admin only)
router.put("/:id", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        const trend = await services_1.PublicationTrendService.updatePublicationTrend(req.params.id, req.body);
        res.json(trend);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Delete publication trend (admin only)
router.delete("/:id", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        await services_1.PublicationTrendService.deletePublicationTrend(req.params.id);
        res.json({ message: "Publication trend deleted" });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get trends by keyword
router.get("/keyword/:keywordId", async (req, res) => {
    try {
        const trends = await services_1.PublicationTrendService.getTrendsByKeyword(req.params.keywordId);
        res.json(trends);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get trends by journal
router.get("/journal/:journalId", async (req, res) => {
    try {
        const trends = await services_1.PublicationTrendService.getTrendsByJournal(req.params.journalId);
        res.json(trends);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
exports.default = router;
//# sourceMappingURL=publicationTrends.js.map