"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const middleware_1 = require("../middleware");
const express_validator_1 = require("express-validator");
const services_1 = require("../services");
const router = (0, express_1.Router)();
// Apply middleware
router.use(middleware_1.authMiddleware);
router.use((0, middleware_1.rateLimit)(middleware_1.rateLimits.api));
// Get user follows
router.get("/", async (req, res) => {
    try {
        const follows = await services_1.FollowService.getUserFollows(req.userId);
        res.json(follows);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Follow keyword or journal
router.post("/", [
    (0, express_validator_1.body)("targetType").isIn(["Keyword", "Journal"]),
    (0, express_validator_1.body)("targetId").notEmpty(),
], middleware_1.validateInputs, async (req, res) => {
    try {
        const { targetType, targetId, notifyEnabled } = req.body;
        const result = await services_1.FollowService.addFollow(req.userId, targetType, targetId, notifyEnabled);
        res.json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Unfollow keyword or journal
router.delete("/:targetId", async (req, res) => {
    try {
        const result = await services_1.FollowService.removeFollow(req.userId, req.params.targetId);
        res.json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get user tracked runs
router.get("/tracked-runs", async (req, res) => {
    try {
        const trackedRuns = await services_1.FollowService.getTrackedRuns(req.userId);
        res.json(trackedRuns);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Track analysis run
router.post("/tracked-runs/:analysisRunId", async (req, res) => {
    try {
        const result = await services_1.FollowService.trackAnalysisRun(req.userId, req.params.analysisRunId, req.body.notifyEnabled);
        res.json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Untrack analysis run
router.delete("/tracked-runs/:analysisRunId", async (req, res) => {
    try {
        const result = await services_1.FollowService.untrackAnalysisRun(req.userId, req.params.analysisRunId);
        res.json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Update notification preference for tracked run
router.put("/tracked-runs/:analysisRunId/notify", async (req, res) => {
    try {
        const result = await services_1.FollowService.updateTrackedRunNotification(req.userId, req.params.analysisRunId, req.body.notifyEnabled);
        res.json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
exports.default = router;
//# sourceMappingURL=follows.js.map