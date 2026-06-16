"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const middleware_1 = require("../middleware");
const services_1 = require("../services");
const router = (0, express_1.Router)();
// Apply rate limiting
router.use(middleware_1.authMiddleware);
router.use((0, middleware_1.rateLimit)(middleware_1.rateLimits.api));
// Get user notifications
router.get("/", async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const { notifications, total, pages } = await services_1.NotificationService.getUserNotifications(req.userId, page, limit);
        res.json({
            notifications,
            pagination: { page, limit, total, pages },
        });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get unread notification count
router.get("/unread/count", async (req, res) => {
    try {
        const result = await services_1.NotificationService.getUnreadCount(req.userId);
        res.json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Mark notification as read
router.put("/:id/read", middleware_1.validateIdParam, async (req, res) => {
    try {
        const notification = await services_1.NotificationService.markAsRead(req.params.id);
        res.json(notification);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Mark all notifications as read
router.put("/all/read", async (req, res) => {
    try {
        const result = await services_1.NotificationService.markAllAsRead(req.userId);
        res.json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Delete notification
router.delete("/:id", middleware_1.validateIdParam, async (req, res) => {
    try {
        const result = await services_1.NotificationService.deleteNotification(req.params.id);
        res.json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Clear all notifications
router.delete("/", async (req, res) => {
    try {
        const result = await services_1.NotificationService.clearAllNotifications(req.userId);
        res.json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
exports.default = router;
//# sourceMappingURL=notifications.js.map