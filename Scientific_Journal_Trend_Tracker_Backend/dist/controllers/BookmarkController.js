"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.BookmarkController = void 0;
const Paper_1 = __importDefault(require("../models/Paper"));
const User_1 = __importDefault(require("../models/User"));
class BookmarkController {
    static async getUserBookmarks(req, res) {
        try {
            const user = await User_1.default.findById(req.userId).populate("bookmarks");
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            res.json(user.bookmarks);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async checkBookmark(req, res) {
        try {
            const user = await User_1.default.findById(req.userId);
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            const isBookmarked = user.bookmarks.includes(req.params.paperId);
            res.json({ isBookmarked });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async addBookmark(req, res) {
        try {
            const paper = await Paper_1.default.findById(req.params.paperId);
            if (!paper) {
                res.status(404).json({ message: "Paper not found" });
                return;
            }
            const user = await User_1.default.findById(req.userId);
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
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async removeBookmark(req, res) {
        try {
            const user = await User_1.default.findByIdAndUpdate(req.userId, { $pull: { bookmarks: req.params.paperId } }, { new: true });
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            res.json({ message: "Bookmark removed", bookmarks: user.bookmarks });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
}
exports.BookmarkController = BookmarkController;
//# sourceMappingURL=BookmarkController.js.map