"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationService = void 0;
const Notification_1 = __importDefault(require("../models/Notification"));
class NotificationService {
    static async getUserNotifications(userId, page, limit) {
        const skip = (page - 1) * limit;
        const notifications = await Notification_1.default.find({ userId })
            .skip(skip)
            .limit(limit)
            .sort({ createdAt: -1 });
        const total = await Notification_1.default.countDocuments({ userId });
        return {
            notifications,
            total,
            pages: Math.ceil(total / limit),
        };
    }
    static async getUnreadCount(userId) {
        const count = await Notification_1.default.countDocuments({
            userId,
            isRead: false,
        });
        return { unreadCount: count };
    }
    static async getUnreadNotifications(userId) {
        const notifications = await Notification_1.default.find({
            userId,
            isRead: false,
        }).sort({ createdAt: -1 });
        return notifications;
    }
    static async markAsRead(notificationId) {
        const notification = await Notification_1.default.findByIdAndUpdate(notificationId, { isRead: true }, { new: true });
        if (!notification) {
            throw { status: 404, message: "Notification not found" };
        }
        return notification;
    }
    static async markAllAsRead(userId) {
        await Notification_1.default.updateMany({ userId, isRead: false }, { isRead: true });
        return { message: "All notifications marked as read" };
    }
    static async deleteNotification(notificationId) {
        const notification = await Notification_1.default.findByIdAndDelete(notificationId);
        if (!notification) {
            throw { status: 404, message: "Notification not found" };
        }
        return { message: "Notification deleted" };
    }
    static async clearAllNotifications(userId) {
        await Notification_1.default.deleteMany({ userId });
        return { message: "All notifications cleared" };
    }
    static async createNotification(userId, title, message, type, refId, refType) {
        const notification = new Notification_1.default({
            userId,
            title,
            message,
            type,
            refId,
            refType,
            isRead: false,
            createdAt: new Date(),
        });
        await notification.save();
        return notification;
    }
    static async bulkCreateNotifications(userIds, title, message, type, refId, refType) {
        const notifications = userIds.map((userId) => ({
            userId,
            title,
            message,
            type,
            refId,
            refType,
            isRead: false,
            createdAt: new Date(),
        }));
        const result = await Notification_1.default.insertMany(notifications);
        return result;
    }
    static async getNotificationsByType(userId, type) {
        const notifications = await Notification_1.default.find({ userId, type }).sort({
            createdAt: -1,
        });
        return notifications;
    }
}
exports.NotificationService = NotificationService;
//# sourceMappingURL=NotificationService.js.map