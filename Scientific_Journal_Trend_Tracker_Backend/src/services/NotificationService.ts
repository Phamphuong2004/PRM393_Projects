import Notification from "../models/Notification";
import User from "../models/User";
import { sendEmail } from "../utils/mailer";

export class NotificationService {
  static async getUserNotifications(
    userId: string,
    page: number,
    limit: number,
  ) {
    const skip = (page - 1) * limit;

    const notifications = await Notification.find({ userId })
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });

    const total = await Notification.countDocuments({ userId });

    return {
      notifications,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  static async getUnreadCount(userId: string) {
    const count = await Notification.countDocuments({
      userId,
      isRead: false,
    });

    return { unreadCount: count };
  }

  static async getUnreadNotifications(userId: string) {
    const notifications = await Notification.find({
      userId,
      isRead: false,
    }).sort({ createdAt: -1 });

    return notifications;
  }

  static async markAsRead(notificationId: string) {
    const notification = await Notification.findByIdAndUpdate(
      notificationId,
      { isRead: true },
      { new: true },
    );

    if (!notification) {
      throw { status: 404, message: "Notification not found" };
    }

    return notification;
  }

  static async markAllAsRead(userId: string) {
    await Notification.updateMany({ userId, isRead: false }, { isRead: true });

    return { message: "All notifications marked as read" };
  }

  static async deleteNotification(notificationId: string) {
    const notification = await Notification.findByIdAndDelete(notificationId);

    if (!notification) {
      throw { status: 404, message: "Notification not found" };
    }

    return { message: "Notification deleted" };
  }

  static async clearAllNotifications(userId: string) {
    await Notification.deleteMany({ userId });

    return { message: "All notifications cleared" };
  }

  static async createNotification(
    userId: string,
    title: string,
    message: string,
    type: string,
    refId?: string,
    refType?: string,
  ) {
    const notification = new Notification({
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

  static async bulkCreateNotifications(
    userIds: string[],
    title: string,
    message: string,
    type: string,
    refId?: string,
    refType?: string,
  ) {
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

    const result = await Notification.insertMany(notifications);

    return result;
  }

  static async getNotificationsByType(userId: string, type: string) {
    const notifications = await Notification.find({ userId, type }).sort({
      createdAt: -1,
    });

    return notifications;
  }

  static async processPostSyncNotifications(newPapers: any[]) {
    // Collect all keyword IDs from new papers
    const keywordIds = new Set<string>();
    newPapers.forEach(paper => {
      paper.keywords?.forEach((kwId: any) => keywordIds.add(kwId.toString()));
    });

    if (keywordIds.size === 0) return;

    // Find users following these keywords
    const users = await User.find({
      "follows.targetType": "Keyword",
      "follows.targetId": { $in: Array.from(keywordIds) }
    });

    for (const user of users) {
      // Find which followed keywords match the new papers
      const matchingFollows = user.follows.filter(f => 
        f.targetType === "Keyword" && keywordIds.has(f.targetId.toString())
      );

      if (matchingFollows.length > 0) {
        // Create in-app notification
        const title = "New Papers Found!";
        const message = `We found ${newPapers.length} new papers for keywords you follow.`;
        
        await this.createNotification(
          user._id.toString(),
          title,
          message,
          "system"
        );

        // Check if any matching follow has email notify enabled
        const shouldEmail = matchingFollows.some(f => f.notifyEnabled);
        if (shouldEmail && user.email) {
          try {
            await sendEmail(
              user.email,
              title,
              `<p>Hello ${user.fullName},</p><p>${message}</p><p>Visit your dashboard to see the latest publications.</p>`
            );
          } catch (err) {
            console.error("Failed to send notification email to", user.email);
          }
        }
      }
    }
  }
}
