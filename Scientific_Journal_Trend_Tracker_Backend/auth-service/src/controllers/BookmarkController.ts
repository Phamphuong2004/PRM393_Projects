import { Request, Response } from "express";
import User from "../models/User";

export class BookmarkController {
  static async getUserBookmarks(req: Request, res: Response): Promise<void> {
    try {
      const user = await User.findById(req.userId);
      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }

      let populatedBookmarks = [];
      if (user.bookmarks.length > 0) {
        try {
          const { createInternalClient, SERVICES } = require("../../shared/src/utils/internalApiClient");
          const internalClient = createInternalClient(SERVICES.CORE, req.headers.authorization);
          const response = await internalClient.post("/api/papers/batch", { ids: user.bookmarks });
          populatedBookmarks = response.data;
        } catch (err) {
          console.error("Failed to fetch papers from core-service:", err);
          // Fallback to just IDs if core-service fails
          populatedBookmarks = user.bookmarks.map((id) => ({ _id: id }));
        }
      }

      res.json({ bookmarks: populatedBookmarks });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async checkBookmark(req: Request, res: Response): Promise<void> {
    try {
      const user = await User.findById(req.userId);
      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }
      const isBookmarked = user.bookmarks.includes(req.params.paperId as any);
      res.json({ isBookmarked });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async addBookmark(req: Request, res: Response): Promise<void> {
    try {
      const user = await User.findById(req.userId);
      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }
      
      const paperId = req.params.paperId;
      // Add to bookmarks if not already there
      if (!user.bookmarks.includes(paperId as any)) {
        user.bookmarks.push(paperId as any);
        await user.save();
      }

      res.json({ message: "Paper bookmarked", bookmarks: user.bookmarks });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async removeBookmark(req: Request, res: Response): Promise<void> {
    try {
      const user = await User.findByIdAndUpdate(
        req.userId,
        { $pull: { bookmarks: req.params.paperId } },
        { new: true },
      );

      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }

      res.json({ message: "Bookmark removed", bookmarks: user.bookmarks });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }
}
