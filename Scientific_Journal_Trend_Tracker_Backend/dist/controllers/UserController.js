"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserController = void 0;
const express_validator_1 = require("express-validator");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const User_1 = __importDefault(require("../models/User"));
class UserController {
    static async getAllUsers(req, res) {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 10;
            const skip = (page - 1) * limit;
            const users = await User_1.default.find()
                .select("-password")
                .skip(skip)
                .limit(limit)
                .sort({ createdAt: -1 });
            const total = await User_1.default.countDocuments();
            res.json({
                users,
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
    static async getUserById(req, res) {
        try {
            const user = await User_1.default.findById(req.params.id).select("-password");
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            res.json(user);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async updateUserProfile(req, res) {
        try {
            // Users can only update their own profile
            if (req.userId !== req.params.id && req.userRole !== "admin") {
                res.status(403).json({ message: "Access denied" });
                return;
            }
            // Prevent password change through this endpoint
            const { password, ...updateData } = req.body;
            const user = await User_1.default.findByIdAndUpdate(req.params.id, updateData, {
                new: true,
            }).select("-password");
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            res.json(user);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async deleteUser(req, res) {
        try {
            const user = await User_1.default.findByIdAndDelete(req.params.id);
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            res.json({ message: "User deleted" });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async changePassword(req, res) {
        try {
            const errors = (0, express_validator_1.validationResult)(req);
            if (!errors.isEmpty()) {
                res.status(400).json({ errors: errors.array() });
                return;
            }
            // Users can only change their own password
            if (req.userId !== req.params.id) {
                res.status(403).json({ message: "Access denied" });
                return;
            }
            const user = await User_1.default.findById(req.params.id);
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            const isMatch = await bcryptjs_1.default.compare(req.body.currentPassword, user.password);
            if (!isMatch) {
                res.status(400).json({ message: "Current password is incorrect" });
                return;
            }
            const salt = await bcryptjs_1.default.genSalt(parseInt(process.env.BCRYPT_ROUNDS || "10"));
            user.password = await bcryptjs_1.default.hash(req.body.newPassword, salt);
            await user.save();
            res.json({ message: "Password changed successfully" });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async getUsersByRole(req, res) {
        try {
            const users = await User_1.default.find({ role: req.params.role })
                .select("-password")
                .sort({ createdAt: -1 });
            res.json(users);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
}
exports.UserController = UserController;
//# sourceMappingURL=UserController.js.map