"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const middleware_1 = require("../middleware");
const middleware_2 = require("../middleware");
const services_1 = require("../services");
const router = (0, express_1.Router)();
// Apply rate limiting
router.use((0, middleware_1.rateLimit)(middleware_1.rateLimits.api));
// Get all users (admin only)
router.get("/", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const { users, total, pages } = await services_1.UserService.getAllUsers(page, limit);
        res.json({
            users,
            pagination: { page, limit, total, pages },
        });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get user by ID
router.get("/:id", middleware_1.authMiddleware, middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        const user = await services_1.UserService.getUserById(req.params.id);
        res.json(user);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Update user profile
router.put("/:id", middleware_1.authMiddleware, (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        const user = await services_1.UserService.updateUserProfile(req.params.id, req.body, req.userId, req.userRole);
        res.json(user);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Delete user (admin only)
router.delete("/:id", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), (0, middleware_1.rateLimit)(middleware_1.rateLimits.write), middleware_2.validateIdParam, middleware_2.validateInputs, async (req, res) => {
    try {
        await services_1.UserService.deleteUser(req.params.id);
        res.json({ message: "User deleted" });
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Change user password
router.post("/:id/change-password", middleware_1.authMiddleware, (0, middleware_1.rateLimit)(middleware_1.rateLimits.sensitive), middleware_2.validateChangePassword, middleware_2.validateInputs, async (req, res) => {
    try {
        const { currentPassword, newPassword } = req.body;
        const result = await services_1.UserService.changePassword(req.params.id, currentPassword, newPassword, req.userId);
        res.json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get users by role (admin only)
router.get("/role/:role", middleware_1.authMiddleware, (0, middleware_1.roleMiddleware)(["admin"]), async (req, res) => {
    try {
        const users = await services_1.UserService.getUsersByRole(req.params.role);
        res.json(users);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
exports.default = router;
//# sourceMappingURL=users.js.map