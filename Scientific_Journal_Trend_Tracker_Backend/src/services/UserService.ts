import User from "../models/User";
import Paper from "../models/Paper";
import Journal from "../models/Journal";
import Topic from "../models/Topic";
import Keyword from "../models/Keyword";
import AnalysisRun from "../models/AnalysisRun";
import bcrypt from "bcryptjs";

export class UserService {
  static async getAllUsers(page: number, limit: number) {
    const skip = (page - 1) * limit;

    const users = await User.find()
      .select("-password")
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });

    const total = await User.countDocuments();

    return {
      users,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  static async getUserById(id: string) {
    const user = await User.findById(id).select("-password");

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    return user;
  }

  static async updateUserProfile(
    id: string,
    userData: any,
    requestingUserId?: string,
    requestingUserRole?: string,
  ) {
    // Users can only update their own profile unless admin
    if (requestingUserId !== id && requestingUserRole !== "admin") {
      throw { status: 403, message: "Access denied" };
    }

    // Prevent password change through this endpoint
    const { password, ...updateData } = userData;

    const user = await User.findByIdAndUpdate(id, updateData, {
      new: true,
    }).select("-password");

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    return user;
  }

  static async deleteUser(id: string) {
    const user = await User.findByIdAndDelete(id);

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    return user;
  }

  static async changePassword(
    id: string,
    currentPassword: string,
    newPassword: string,
    requestingUserId?: string,
  ) {
    // Users can only change their own password
    if (requestingUserId !== id) {
      throw { status: 403, message: "Access denied" };
    }

    const user = await User.findById(id);
    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    const isMatch = await bcrypt.compare(currentPassword, user.password);

    if (!isMatch) {
      throw { status: 400, message: "Current password is incorrect" };
    }

    const salt = await bcrypt.genSalt(
      parseInt(process.env.BCRYPT_ROUNDS || "10"),
    );
    user.password = await bcrypt.hash(newPassword, salt);

    await user.save();

    return { message: "Password changed successfully" };
  }

  static async getUsersByRole(role: string) {
    const users = await User.find({ role })
      .select("-password")
      .sort({ createdAt: -1 });

    return users;
  }

  static async getUserStats(id: string) {
    const user = await User.findById(id);

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

  static async getActiveUsers(days: number = 30) {
    const date = new Date();
    date.setDate(date.getDate() - days);

    const users = await User.find({
      lastLogin: { $gte: date },
    })
      .select("-password")
      .sort({ lastLogin: -1 });

    return users;
  }

  static async getAdminStats() {
    const [
      totalUsers,
      totalPapers,
      totalJournals,
      totalTopics,
      totalKeywords,
      totalAnalysisRuns,
      researchers,
      users,
      admins
    ] = await Promise.all([
      User.countDocuments(),
      Paper.countDocuments(),
      Journal.countDocuments(),
      Topic.countDocuments(),
      Keyword.countDocuments(),
      AnalysisRun.countDocuments(),
      User.countDocuments({ role: "researcher" }),
      User.countDocuments({ role: "user" }),
      User.countDocuments({ role: "admin" })
    ]);

    return {
      users: {
        total: totalUsers,
        researchers,
        lecturersStudents: users,
        admins
      },
      papers: totalPapers,
      journals: totalJournals,
      topics: totalTopics,
      keywords: totalKeywords,
      analysisRuns: totalAnalysisRuns
    };
  }
}


