"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationController = void 0;
const Notification_1 = __importDefault(require("../models/Notification"));
class NotificationController {
    static async getUserNotifications(req, res) {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 20;
            const skip = (page - 1) * limit;
            const notifications = await Notification_1.default.find({ userId: req.userId })
                .skip(skip)
                .limit(limit)
                .sort({ createdAt: -1 });
            const total = await Notification_1.default.countDocuments({ userId: req.userId });
            res.json({
                notifications,
                pagination: {
                    page,
                    limit,
                    total,
                    pages: Math.ceil(total / limit),
                },
            });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async getUnreadCount(req, res) {
        try {
            const count = await Notification_1.default.countDocuments({
                userId: req.userId,
                isRead: false,
            });
            res.json({ unreadCount: count });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async markAsRead(req, res) {
        try {
            const notification = await Notification_1.default.findByIdAndUpdate(req.params.id, { isRead: true }, { new: true });
            if (!notification) {
                res.status(404).json({ message: "Notification not found" });
                return;
            }
            res.json(notification);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async markAllAsRead(req, res) {
        try {
            await Notification_1.default.updateMany({ userId: req.userId, isRead: false }, { isRead: true });
            res.json({ message: "All notifications marked as read" });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async deleteNotification(req, res) {
        try {
            const notification = await Notification_1.default.findByIdAndDelete(req.params.id);
            if (!notification) {
                res.status(404).json({ message: "Notification not found" });
                return;
            }
            res.json({ message: "Notification deleted" });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async clearAllNotifications(req, res) {
        try {
            await Notification_1.default.deleteMany({ userId: req.userId });
            res.json({ message: "All notifications cleared" });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
}
exports.NotificationController = NotificationController;
//# sourceMappingURL=NotificationController.js.map