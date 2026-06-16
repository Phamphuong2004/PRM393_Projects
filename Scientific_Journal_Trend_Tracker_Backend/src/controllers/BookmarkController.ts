import { Request, Response } from "express";
import Paper from "../models/Paper";
import User from "../models/User";

export class BookmarkController {
  static async getUserBookmarks(req: Request, res: Response): Promise<void> {
    try {
      const user = await User.findById(req.userId).populate("bookmarks");

      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }

      res.json(user.bookmarks);
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
      const paper = await Paper.findById(req.params.paperId);

      if (!paper) {
        res.status(404).json({ message: "Paper not found" });
        return;
      }

      const user = await User.findById(req.userId);

      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }

      // Add to bookmarks if not already there
      if (!user.bookmarks.includes(paper._id)) {
        user.bookmarks.push(paper._id);
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
