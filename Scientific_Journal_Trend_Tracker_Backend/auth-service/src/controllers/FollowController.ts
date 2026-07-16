import { Request, Response } from "express";
import User from "../models/User";

export class FollowController {
  static async getUserFollows(req: Request, res: Response): Promise<void> {
    try {
      const user = await User.findById(req.userId);
      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }

      let populatedFollows = [];
      if (user.follows.length > 0) {
        try {
          const { createInternalClient, SERVICES } = require("../../shared/src/utils/internalApiClient");
          const internalClient = createInternalClient(SERVICES.CORE, req.headers.authorization);
          
          populatedFollows = await Promise.all(user.follows.map(async (f) => {
            try {
              let endpoint = "";
              if (f.targetType === "Keyword") endpoint = `/api/keywords/${f.targetId}`;
              else if (f.targetType === "Journal") endpoint = `/api/journals/${f.targetId}`;
              else if (f.targetType === "Author") endpoint = `/api/authors/${f.targetId}`;
              
              if (endpoint) {
                const res = await internalClient.get(endpoint);
                const rawF = (f as any).toObject ? (f as any).toObject() : f;
                return { ...rawF, targetDetails: res.data };
              }
            } catch (err) {
              console.error(`Failed to fetch details for ${f.targetType} ${f.targetId}`);
            }
            return f;
          }));
        } catch (err) {
          console.error("Failed to setup internal client:", err);
          populatedFollows = user.follows;
        }
      }

      res.json({ follows: populatedFollows });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async followTarget(req: Request, res: Response): Promise<void> {
    try {
      const { targetId, targetType } = req.body;
      const user = await User.findById(req.userId);
      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }

      const existingFollow = user.follows.find(
        (f) => f.targetId.toString() === targetId && f.targetType === targetType
      );
      if (!existingFollow) {
        user.follows.push({ targetId, targetType } as any);
        await user.save();
      }

      res.json({ message: "Followed successfully", follows: user.follows });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async unfollowTarget(req: Request, res: Response): Promise<void> {
    try {
      const { targetId, targetType } = req.body;
      const user = await User.findById(req.userId);
      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }

      user.follows = user.follows.filter(
        (f) => !(f.targetId.toString() === targetId && f.targetType === targetType)
      ) as any;
      await user.save();

      res.json({ message: "Unfollowed successfully", follows: user.follows });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async checkFollow(req: Request, res: Response): Promise<void> {
    try {
      const { targetId, targetType } = req.query;
      const user = await User.findById(req.userId);
      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }

      const isFollowing = user.follows.some(
        (f) => f.targetId.toString() === targetId && f.targetType === targetType
      );
      res.json({ isFollowing });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getDashboardFeed(req: Request, res: Response): Promise<void> {
    try {
      res.json({ message: "Dashboard feed moved to interaction-service", data: [] });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
