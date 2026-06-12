"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserService = void 0;
const User_1 = __importDefault(require("../models/User"));
const bcryptjs_1 = __importDefault(require("bcryptjs"));
class UserService {
    static async getAllUsers(page, limit) {
        const skip = (page - 1) * limit;
        const users = await User_1.default.find()
            .select("-password")
            .skip(skip)
            .limit(limit)
            .sort({ createdAt: -1 });
        const total = await User_1.default.countDocuments();
        return {
            users,
            total,
            pages: Math.ceil(total / limit),
        };
    }
    static async getUserById(id) {
        const user = await User_1.default.findById(id).select("-password");
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        return user;
    }
    static async updateUserProfile(id, userData, requestingUserId, requestingUserRole) {
        // Users can only update their own profile unless admin
        if (requestingUserId !== id && requestingUserRole !== "admin") {
            throw { status: 403, message: "Access denied" };
        }
        // Prevent password change through this endpoint
        const { password, ...updateData } = userData;
        const user = await User_1.default.findByIdAndUpdate(id, updateData, {
            new: true,
        }).select("-password");
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        return user;
    }
    static async deleteUser(id) {
        const user = await User_1.default.findByIdAndDelete(id);
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        return user;
    }
    static async changePassword(id, currentPassword, newPassword, requestingUserId) {
        // Users can only change their own password
        if (requestingUserId !== id) {
            throw { status: 403, message: "Access denied" };
        }
        const user = await User_1.default.findById(id);
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        const isMatch = await bcryptjs_1.default.compare(currentPassword, user.password);
        if (!isMatch) {
            throw { status: 400, message: "Current password is incorrect" };
        }
        const salt = await bcryptjs_1.default.genSalt(parseInt(process.env.BCRYPT_ROUNDS || "10"));
        user.password = await bcryptjs_1.default.hash(newPassword, salt);
        await user.save();
        return { message: "Password changed successfully" };
    }
    static async getUsersByRole(role) {
        const users = await User_1.default.find({ role })
            .select("-password")
            .sort({ createdAt: -1 });
        return users;
    }
    static async getUserStats(id) {
        const user = await User_1.default.findById(id);
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        return {
            bookmarks: user.bookmarks.length,
            follows: user.follows.length,
            trackedRuns: user.trackedRuns.length,
            joinedAt: user.createdAt,
            lastLogin: user.lastLogin,
        };
    }
    static async getActiveUsers(days = 30) {
        const date = new Date();
        date.setDate(date.getDate() - days);
        const users = await User_1.default.find({
            lastLogin: { $gte: date },
        })
            .select("-password")
            .sort({ lastLogin: -1 });
        return users;
    }
}
exports.UserService = UserService;
//# sourceMappingURL=UserService.js.map