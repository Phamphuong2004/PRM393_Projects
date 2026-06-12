"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.BookmarkService = void 0;
const User_1 = __importDefault(require("../models/User"));
const Paper_1 = __importDefault(require("../models/Paper"));
class BookmarkService {
    static async getUserBookmarks(userId, page = 1, limit = 20) {
        const skip = (page - 1) * limit;
        const user = await User_1.default.findById(userId).populate({
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
    static async checkBookmark(userId, paperId) {
        const user = await User_1.default.findById(userId);
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        const isBookmarked = user.bookmarks.includes(paperId);
        return { isBookmarked };
    }
    static async addBookmark(userId, paperId) {
        const paper = await Paper_1.default.findById(paperId);
        if (!paper) {
            throw { status: 404, message: "Paper not found" };
        }
        const user = await User_1.default.findById(userId);
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
    static async removeBookmark(userId, paperId) {
        const user = await User_1.default.findByIdAndUpdate(userId, { $pull: { bookmarks: paperId } }, { new: true });
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        return { message: "Bookmark removed", bookmarks: user.bookmarks };
    }
    static async clearAllBookmarks(userId) {
        const user = await User_1.default.findByIdAndUpdate(userId, { bookmarks: [] }, { new: true });
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        return { message: "All bookmarks cleared" };
    }
    static async getBookmarkCount(userId) {
        const user = await User_1.default.findById(userId);
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        return { count: user.bookmarks.length };
    }
}
exports.BookmarkService = BookmarkService;
//# sourceMappingURL=BookmarkService.js.map