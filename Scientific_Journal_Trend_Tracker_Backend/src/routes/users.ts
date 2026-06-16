import { Router, Request, Response } from "express";
import {
  authMiddleware,
  roleMiddleware,
  rateLimit,
  rateLimits,
} from "../middleware";
import {
  validateChangePassword,
  validateIdParam,
  validateInputs,
} from "../middleware";
import { UserService } from "../services";

const router = Router();

// Apply rate limiting
router.use(rateLimit(rateLimits.api));

// Get all users (admin only)
router.get(
  "/",
  authMiddleware,
  roleMiddleware(["admin"]),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;

      const { users, total, pages } = await UserService.getAllUsers(
        page,
        limit,
      );

      res.json({
        users,
        pagination: { page, limit, total, pages },
      });
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Get admin dashboard stats (admin only)
router.get(
  "/admin/stats",
  authMiddleware,
  roleMiddleware(["admin"]),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const stats = await UserService.getAdminStats();
      res.json(stats);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Get user by ID
router.get(
  "/:id",
  authMiddleware,
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const user = await UserService.getUserById(req.params.id);
      res.json(user);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Update user profile
router.put(
  "/:id",
  authMiddleware,
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const user = await UserService.updateUserProfile(
        req.params.id,
        req.body,
        req.userId,
        req.userRole,
      );
      res.json(user);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Delete user (admin only)
router.delete(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      await UserService.deleteUser(req.params.id);
      res.json({ message: "User deleted" });
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Change user password
router.post(
  "/:id/change-password",
  authMiddleware,
  rateLimit(rateLimits.sensitive),
  validateChangePassword,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const { currentPassword, newPassword } = req.body;
      const result = await UserService.changePassword(
        req.params.id,
        currentPassword,
        newPassword,
        req.userId,
      );
      res.json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Get users by role (admin only)
router.get(
  "/role/:role",
  authMiddleware,
  roleMiddleware(["admin"]),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const users = await UserService.getUsersByRole(req.params.role);
      res.json(users);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

export default router;


