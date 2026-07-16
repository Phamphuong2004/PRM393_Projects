import { Request, Response } from "express";
import Notification from "../models/Notification";

export class NotificationController {
  static async getUserNotifications(
    req: Request,
    res: Response,
  ): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;
      const skip = (page - 1) * limit;

      const notifications = await Notification.find({ userId: req.userId })
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 });

      const total = await Notification.countDocuments({ userId: req.userId });

      res.json({
        notifications,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit),
        },
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getUnreadCount(req: Request, res: Response): Promise<void> {
    try {
      const count = await Notification.countDocuments({
        userId: req.userId,
        isRead: false,
      });

      res.json({ unreadCount: count });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async markAsRead(req: Request, res: Response): Promise<void> {
    try {
      const notification = await Notification.findByIdAndUpdate(
        req.params.id,
        { isRead: true },
        { new: true },
      );

      if (!notification) {
        res.status(404).json({ message: "Notification not found" });
        return;
      }

      res.json(notification);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async markAllAsRead(req: Request, res: Response): Promise<void> {
    try {
      await Notification.updateMany(
        { userId: req.userId, isRead: false },
        { isRead: true },
      );

      res.json({ message: "All notifications marked as read" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async deleteNotification(req: Request, res: Response): Promise<void> {
    try {
      const notification = await Notification.findByIdAndDelete(req.params.id);

      if (!notification) {
        res.status(404).json({ message: "Notification not found" });
        return;
      }

      res.json({ message: "Notification deleted" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async clearAllNotifications(
    req: Request,
    res: Response,
  ): Promise<void> {
    try {
      await Notification.deleteMany({ userId: req.userId });

      res.json({ message: "All notifications cleared" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
