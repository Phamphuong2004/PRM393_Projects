import { Request, Response } from "express";
export declare class NotificationController {
    static getUserNotifications(req: Request, res: Response): Promise<void>;
    static getUnreadCount(req: Request, res: Response): Promise<void>;
    static markAsRead(req: Request, res: Response): Promise<void>;
    static markAllAsRead(req: Request, res: Response): Promise<void>;
    static deleteNotification(req: Request, res: Response): Promise<void>;
    static clearAllNotifications(req: Request, res: Response): Promise<void>;
}
//# sourceMappingURL=NotificationController.d.ts.map