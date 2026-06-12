"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FollowController = void 0;
const express_validator_1 = require("express-validator");
const User_1 = __importDefault(require("../models/User"));
const Keyword_1 = __importDefault(require("../models/Keyword"));
const Journal_1 = __importDefault(require("../models/Journal"));
const AnalysisRun_1 = __importDefault(require("../models/AnalysisRun"));
class FollowController {
    static async getUserFollows(req, res) {
        try {
            const user = await User_1.default.findById(req.userId).populate("follows");
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            res.json(user.follows);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async addFollow(req, res) {
        try {
            const errors = (0, express_validator_1.validationResult)(req);
            if (!errors.isEmpty()) {
                res.status(400).json({ errors: errors.array() });
                return;
            }
            const { targetType, targetId, notifyEnabled } = req.body;
            // Verify target exists
            if (targetType === "Keyword") {
                const keyword = await Keyword_1.default.findById(targetId);
                if (!keyword) {
                    res.status(404).json({ message: "Keyword not found" });
                    return;
                }
            }
            else if (targetType === "Journal") {
                const journal = await Journal_1.default.findById(targetId);
                if (!journal) {
                    res.status(404).json({ message: "Journal not found" });
                    return;
                }
            }
            const user = await User_1.default.findById(req.userId);
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            // Check if already following
            const existingFollow = user.follows.find((f) => f.targetType === targetType && f.targetId.toString() === targetId);
            if (!existingFollow) {
                user.follows.push({
                    targetType,
                    targetId,
                    notifyEnabled: notifyEnabled ?? true,
                });
                await user.save();
            }
            res.json({ message: "Following added", follows: user.follows });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async removeFollow(req, res) {
        try {
            const user = await User_1.default.findByIdAndUpdate(req.userId, { $pull: { follows: { targetId: req.params.targetId } } }, { new: true });
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            res.json({ message: "Following removed", follows: user.follows });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async getTrackedRuns(req, res) {
        try {
            const user = await User_1.default.findById(req.userId).populate({
                path: "trackedRuns.analysisRunId",
                model: "AnalysisRun",
                populate: [
                    { path: "keywordId", model: "Keyword" },
                    { path: "topicId", model: "Topic" },
                ],
            });
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            res.json(user.trackedRuns);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async trackAnalysisRun(req, res) {
        try {
            const run = await AnalysisRun_1.default.findById(req.params.analysisRunId);
            if (!run) {
                res.status(404).json({ message: "Analysis run not found" });
                return;
            }
            const user = await User_1.default.findById(req.userId);
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            // Check if already tracking
            const existingTrack = user.trackedRuns.find((t) => t.analysisRunId.toString() === req.params.analysisRunId);
            if (!existingTrack) {
                user.trackedRuns.push({
                    analysisRunId: run._id,
                    notifyEnabled: req.body.notifyEnabled ?? true,
                    followedAt: new Date(),
                });
                await user.save();
            }
            res.json({
                message: "Analysis run tracked",
                trackedRuns: user.trackedRuns,
            });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async untrackAnalysisRun(req, res) {
        try {
            const user = await User_1.default.findByIdAndUpdate(req.userId, { $pull: { trackedRuns: { analysisRunId: req.params.analysisRunId } } }, { new: true });
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            res.json({
                message: "Analysis run untracked",
                trackedRuns: user.trackedRuns,
            });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async updateTrackedRunNotification(req, res) {
        try {
            const user = await User_1.default.findById(req.userId);
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            const trackedRun = user.trackedRuns.find((t) => t.analysisRunId.toString() === req.params.analysisRunId);
            if (!trackedRun) {
                res.status(404).json({ message: "Tracked run not found" });
                return;
            }
            trackedRun.notifyEnabled = req.body.notifyEnabled;
            await user.save();
            res.json({
                message: "Notification preference updated",
                trackedRuns: user.trackedRuns,
            });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
}
exports.FollowController = FollowController;
//# sourceMappingURL=FollowController.js.map