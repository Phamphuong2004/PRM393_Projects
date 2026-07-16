import { Router, Request, Response } from "express";
import {
  authMiddleware,
  rateLimit,
  rateLimits,
  validateIdParam,
} from "../middleware";
import { NotificationService } from "../services/NotificationService";

const router = Router();

// Internal API for cross-service bulk notification creation
router.post("/internal/bulk", async (req: Request, res: Response): Promise<void> => {
  try {
    const { internalSecret, userIds, title, message, type, refId, refType } = req.body;
    
    // Verify internal secret
    if (internalSecret !== process.env.INTERNAL_API_SECRET) {
      res.status(401).json({ message: "Unauthorized internal API call" });
      return;
    }

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      res.status(400).json({ message: "userIds array is required" });
      return;
    }

    const result = await NotificationService.bulkCreateNotifications(
      userIds, title, message, type, refId, refType
    );
    
    res.json({ success: true, count: result.length });
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// Apply rate limiting and auth to user routes
router.use(authMiddleware);
router.use(rateLimit(rateLimits.api));

// Test Real-time Notification
router.post("/test-realtime", async (req: Request, res: Response): Promise<void> => {
  try {
    const title = "Real-time Test";
    const message = `Hello! This is a test notification sent at ${new Date().toLocaleTimeString()}`;
    const notification = await NotificationService.createNotification(
      req.userId!,
      title,
      message,
      "system"
    );
    res.json({ success: true, notification });
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// Get user notifications
router.get("/", async (req: Request, res: Response): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;

    const { notifications, total, pages } =
      await NotificationService.getUserNotifications(req.userId!, page, limit);

    res.json({
      notifications,
      pagination: { page, limit, total, pages },
    });
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// Get unread notification count
router.get(
  "/unread/count",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const result = await NotificationService.getUnreadCount(req.userId!);
      res.json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Mark all notifications as read
router.put("/all/read", async (req: Request, res: Response): Promise<void> => {
  try {
    const result = await NotificationService.markAllAsRead(req.userId!);
    res.json(result);
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// Mark notification as read
router.put(
  "/:id/read",
  validateIdParam,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const notification = await NotificationService.markAsRead(req.params.id);
      res.json(notification);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Delete notification
router.delete(
  "/:id",
  validateIdParam,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const result = await NotificationService.deleteNotification(
        req.params.id,
      );
      res.json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Clear all notifications
router.delete("/", async (req: Request, res: Response): Promise<void> => {
  try {
    const result = await NotificationService.clearAllNotifications(req.userId!);
    res.json(result);
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

export default router;
