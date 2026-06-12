import User from "../models/User";
import Paper from "../models/Paper";

export class BookmarkService {
  static async getUserBookmarks(
    userId: string,
    page: number = 1,
    limit: number = 20,
  ) {
    const skip = (page - 1) * limit;

    const user = await User.findById(userId).populate({
      path: "bookmarks",
      options: { skip, limit, sort: { _id: -1 } },
    });

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    const total = user.bookmarks.length;

    return {
      bookmarks: user.bookmarks,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  static async checkBookmark(userId: string, paperId: string) {
    const user = await User.findById(userId);

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    const isBookmarked = user.bookmarks.includes(paperId as any);

    return { isBookmarked };
  }

  static async addBookmark(userId: string, paperId: string) {
    const paper = await Paper.findById(paperId);

    if (!paper) {
      throw { status: 404, message: "Paper not found" };
    }

    const user = await User.findById(userId);

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    // Add to bookmarks if not already there
    if (!user.bookmarks.includes(paper._id)) {
      user.bookmarks.push(paper._id);
      await user.save();
    }

    return { message: "Paper bookmarked", bookmarks: user.bookmarks };
  }

  static async removeBookmark(userId: string, paperId: string) {
    const user = await User.findByIdAndUpdate(
      userId,
      { $pull: { bookmarks: paperId } },
      { new: true },
    );

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    return { message: "Bookmark removed", bookmarks: user.bookmarks };
  }

  static async clearAllBookmarks(userId: string) {
    const user = await User.findByIdAndUpdate(
      userId,
      { bookmarks: [] },
      { new: true },
    );

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    return { message: "All bookmarks cleared" };
  }

  static async getBookmarkCount(userId: string) {
    const user = await User.findById(userId);

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    return { count: user.bookmarks.length };
  }
}
