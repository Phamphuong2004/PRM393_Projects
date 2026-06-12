"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const middleware_1 = require("../middleware");
const middleware_2 = require("../middleware");
const services_1 = require("../services");
const router = (0, express_1.Router)();
// Apply rate limiting
router.use((0, middleware_1.rateLimit)(middleware_1.rateLimits.read));
// Get all topics with pagination
router.get("/", async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const { topics, total, pages } = await services_1.TopicService.getAllTopics(page, limit);
        res.json({
            topics,
            pagination: { page, limit, total, pages },
        });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get topic by ID
router.get("/:id", middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        const topic = await services_1.TopicService.getTopicById(req.params.id);
        res.json(topic);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Create topic (admin/researcher only)
router.post("/", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin", "researcher"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateCreateTopic, middleware_2.validateInputs, async (req, res) => {
    try {
        const topic = await services_1.TopicService.createTopic(req.body);
        res.status(201).json(topic);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get emerging topics
router.get("/emerging/list", async (req, res) => {
    try {
        const topics = await services_1.TopicService.getEmergingTopics();
        res.json(topics);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Update topic (admin only)
router.put("/:id", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        const topic = await services_1.TopicService.updateTopic(req.params.id, req.body);
        res.json(topic);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Delete topic (admin only)
router.delete("/:id", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        await services_1.TopicService.deleteTopic(req.params.id);
        res.json({ message: "Topic deleted" });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
exports.default = router;
//# sourceMappingURL=topics.js.map