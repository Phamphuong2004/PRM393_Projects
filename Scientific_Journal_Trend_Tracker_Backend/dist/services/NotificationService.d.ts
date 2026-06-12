export declare class NotificationService {
    static getUserNotifications(userId: string, page: number, limit: number): Promise<{
        notifications: (import("mongoose").Document<unknown, {}, import("../models/Notification").INotification> & import("../models/Notification").INotification & {
            _id: import("mongoose").Types.ObjectId;
        })[];
        total: number;
        pages: number;
    }>;
    static getUnreadCount(userId: string): Promise<{
        unreadCount: number;
    }>;
    static getUnreadNotifications(userId: string): Promise<(import("mongoose").Document<unknown, {}, import("../models/Notification").INotification> & import("../models/Notification").INotification & {
        _id: import("mongoose").Types.ObjectId;
    })[]>;
    static markAsRead(notificationId: string): Promise<import("mongoose").Document<unknown, {}, import("../models/Notification").INotification> & import("../models/Notification").INotification & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static markAllAsRead(userId: string): Promise<{
        message: string;
    }>;
    static deleteNotification(notificationId: string): Promise<{
        message: string;
    }>;
    static clearAllNotifications(userId: string): Promise<{
        message: string;
    }>;
    static createNotification(userId: string, title: string, message: string, type: string, refId?: string, refType?: string): Promise<import("mongoose").Document<unknown, {}, import("../models/Notification").INotification> & import("../models/Notification").INotification & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static bulkCreateNotifications(userIds: string[], title: string, message: string, type: string, refId?: string, refType?: string): Promise<import("mongoose").MergeType<import("mongoose").Document<unknown, {}, import("../models/Notification").INotification> & import("../models/Notification").INotification & {
        _id: import("mongoose").Types.ObjectId;
    }, Omit<{
        userId: string;
        title: string;
        message: string;
        type: string;
        refId: string | undefined;
        refType: string | undefined;
        isRead: boolean;
        createdAt: Date;
    }, "_id">>[]>;
    static getNotificationsByType(userId: string, type: string): Promise<(import("mongoose").Document<unknown, {}, import("../models/Notification").INotification> & import("../models/Notification").INotification & {
        _id: import("mongoose").Types.ObjectId;
    })[]>;
}
//# sourceMappingURL=NotificationService.d.ts.map