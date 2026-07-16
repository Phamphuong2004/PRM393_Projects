import express from "express";
import { AdminController } from "../controllers/AdminController";
import { authMiddleware, roleMiddleware } from "../middleware/auth";

const router = express.Router();

// Apply middleware to all admin routes
router.use(authMiddleware);
router.use(roleMiddleware(["admin"]));

// User Management
router.patch("/users/:id/status", AdminController.updateUserStatus);
router.patch("/users/:id/role", AdminController.updateUserRole);

// Api Source Management
router.get("/sources", AdminController.getAllSources);
router.post("/sources", AdminController.createSource);
router.put("/sources/:id", AdminController.updateSource);
router.delete("/sources/:id", AdminController.deleteSource);

// Sync Trigger
router.post("/sync", AdminController.triggerManualSync);

export default router;
