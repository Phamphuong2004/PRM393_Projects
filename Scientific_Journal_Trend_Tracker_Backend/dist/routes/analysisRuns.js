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
// Get all analysis runs
router.get("/", async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const { runs, total, pages } = await services_1.AnalysisRunService.getAllAnalysisRuns(page, limit);
        res.json({
            runs,
            pagination: { page, limit, total, pages },
        });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get analysis run by ID
router.get("/:id", middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        const run = await services_1.AnalysisRunService.getAnalysisRunById(req.params.id);
        res.json(run);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Create analysis run (admin/researcher only)
router.post("/", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin", "researcher"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), [(0, express_validator_1.body)("keywordId").notEmpty(), (0, express_validator_1.body)("seedKeyword").notEmpty()], middleware_2.validateInputs, async (req, res) => {
    try {
        const run = await services_1.AnalysisRunService.createAnalysisRun(req.body);
        res.status(201).json(run);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Update analysis run (admin only)
router.put("/:id", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        const run = await services_1.AnalysisRunService.updateAnalysisRun(req.params.id, req.body);
        res.json(run);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Delete analysis run (admin only)
router.delete("/:id", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        await services_1.AnalysisRunService.deleteAnalysisRun(req.params.id);
        res.json({ message: "Analysis run deleted" });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get analysis runs by keyword
router.get("/keyword/:keywordId", async (req, res) => {
    try {
        const runs = await services_1.AnalysisRunService.getAnalysisRunsByKeyword(req.params.keywordId);
        res.json(runs);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
exports.default = router;
//# sourceMappingURL=analysisRuns.js.map