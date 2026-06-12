"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const middleware_1 = require("../middleware");
const middleware_2 = require("../middleware");
const services_1 = require("../services");
const router = (0, express_1.Router)();
// Apply rate limiting
router.use((0, middleware_1.rateLimit)(middleware_1.rateLimits.read));
// Get all papers with pagination
router.get("/", async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const { papers, total, pages } = await services_1.PaperService.getAllPapers(page, limit);
        res.json({
            papers,
            pagination: { page, limit, total, pages },
        });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get paper by ID
router.get("/:id", middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        const paper = await services_1.PaperService.getPaperById(req.params.id);
        res.json(paper);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Create paper (admin/researcher only)
router.post("/", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin", "researcher"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateCreatePaper, middleware_2.validateInputs, async (req, res) => {
    try {
        const paper = await services_1.PaperService.createPaper(req.body);
        res.status(201).json(paper);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Update paper (admin only)
router.put("/:id", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        const paper = await services_1.PaperService.updatePaper(req.params.id, req.body);
        res.json(paper);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Delete paper (admin only)
router.delete("/:id", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        await services_1.PaperService.deletePaper(req.params.id);
        res.json({ message: "Paper deleted" });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Search papers
router.get("/search/query", async (req, res) => {
    try {
        const { q, year, journalId } = req.query;
        const papers = await services_1.PaperService.searchPapers(q, year ? parseInt(year) : undefined, journalId);
        res.json(papers);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
exports.default = router;
//# sourceMappingURL=papers.js.map