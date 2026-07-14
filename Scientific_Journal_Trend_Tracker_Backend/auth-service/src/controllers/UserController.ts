import { Request, Response } from "express";
import { validationResult } from "express-validator";
import bcrypt from "bcryptjs";
import User from "../models/User";

export class UserController {
  static async getAllUsers(req: Request, res: Response): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const skip = (page - 1) * limit;

      const users = await User.find()
        .select("-password")
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 });

      const total = await User.countDocuments();

      res.json({
        users,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit),
        },
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getUserById(req: Request, res: Response): Promise<void> {
    try {
      const user = await User.findById(req.params.id).select("-password");

      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }

      res.json(user);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async updateUserProfile(req: Request, res: Response): Promise<void> {
    try {
      // Users can only update their own profile
      if (req.userId !== req.params.id && req.userRole !== "admin") {
        res.status(403).json({ message: "Access denied" });
        return;
      }

      // Prevent password change through this endpoint
      const updateData = { ...req.body };
      delete updateData.password;

      const user = await User.findByIdAndUpdate(req.params.id, updateData, {
        new: true,
      }).select("-password");

      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }

      res.json(user);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async deleteUser(req: Request, res: Response): Promise<void> {
    try {
      const user = await User.findByIdAndDelete(req.params.id);

      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }

      res.json({ message: "User deleted" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async changePassword(req: Request, res: Response): Promise<void> {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({ errors: errors.array() });
        return;
      }

      // Users can only change their own password
      if (req.userId !== req.params.id) {
        res.status(403).json({ message: "Access denied" });
        return;
      }

      const user = await User.findById(req.params.id);
      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }

      const isMatch = await bcrypt.compare(
        req.body.currentPassword,
        user.password,
      );

      if (!isMatch) {
        res.status(400).json({ message: "Current password is incorrect" });
        return;
      }

      const salt = await bcrypt.genSalt(
        parseInt(process.env.BCRYPT_ROUNDS || "10"),
      );
      user.password = await bcrypt.hash(req.body.newPassword, salt);

      await user.save();

      res.json({ message: "Password changed successfully" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getUsersByRole(req: Request, res: Response): Promise<void> {
    try {
      const users = await User.find({ role: req.params.role })
        .select("-password")
        .sort({ createdAt: -1 });

      res.json(users);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}


