"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FollowService = void 0;
const User_1 = __importDefault(require("../models/User"));
const Keyword_1 = __importDefault(require("../models/Keyword"));
const Journal_1 = __importDefault(require("../models/Journal"));
const AnalysisRun_1 = __importDefault(require("../models/AnalysisRun"));
const mongoose_1 = __importDefault(require("mongoose"));
class FollowService {
    static async getUserFollows(userId) {
        const user = await User_1.default.findById(userId).populate("follows");
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        return user.follows;
    }
    static async addFollow(userId, targetType, targetId, notifyEnabled = true) {
        if (targetType !== "Keyword" && targetType !== "Journal") {
            throw { status: 400, message: "Invalid target type" };
        }
        // Verify target exists
        if (targetType === "Keyword") {
            const keyword = await Keyword_1.default.findById(targetId);
            if (!keyword) {
                throw { status: 404, message: "Keyword not found" };
            }
        }
        else if (targetType === "Journal") {
            const journal = await Journal_1.default.findById(targetId);
            if (!journal) {
                throw { status: 404, message: "Journal not found" };
            }
        }
        const user = await User_1.default.findById(userId);
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        // Check if already following
        const existingFollow = user.follows.find((f) => f.targetType === targetType && f.targetId.toString() === targetId);
        if (!existingFollow) {
            user.follows.push({
                targetType,
                targetId: new mongoose_1.default.Types.ObjectId(targetId),
                notifyEnabled,
            });
            await user.save();
        }
        return { message: "Following added", follows: user.follows };
    }
    static async removeFollow(userId, targetId) {
        const user = await User_1.default.findByIdAndUpdate(userId, { $pull: { follows: { targetId } } }, { new: true });
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        return { message: "Following removed", follows: user.follows };
    }
    static async checkIfFollowing(userId, targetType, targetId) {
        const user = await User_1.default.findById(userId);
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        const isFollowing = user.follows.some((f) => f.targetType === targetType && f.targetId.toString() === targetId);
        return { isFollowing };
    }
    static async getTrackedRuns(userId) {
        const user = await User_1.default.findById(userId).populate({
            path: "trackedRuns.analysisRunId",
            model: "AnalysisRun",
            populate: [
                { path: "keywordId", model: "Keyword" },
                { path: "topicId", model: "Topic" },
            ],
        });
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        return user.trackedRuns;
    }
    static async trackAnalysisRun(userId, analysisRunId, notifyEnabled = true) {
        const run = await AnalysisRun_1.default.findById(analysisRunId);
        if (!run) {
            throw { status: 404, message: "Analysis run not found" };
        }
        const user = await User_1.default.findById(userId);
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        // Check if already tracking
        const existingTrack = user.trackedRuns.find((t) => t.analysisRunId.toString() === analysisRunId);
        if (!existingTrack) {
            user.trackedRuns.push({
                analysisRunId: run._id,
                notifyEnabled,
                followedAt: new Date(),
            });
            await user.save();
        }
        return { message: "Analysis run tracked", trackedRuns: user.trackedRuns };
    }
    static async untrackAnalysisRun(userId, analysisRunId) {
        const user = await User_1.default.findByIdAndUpdate(userId, { $pull: { trackedRuns: { analysisRunId } } }, { new: true });
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        return { message: "Analysis run untracked", trackedRuns: user.trackedRuns };
    }
    static async updateTrackedRunNotification(userId, analysisRunId, notifyEnabled) {
        const user = await User_1.default.findById(userId);
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        const trackedRun = user.trackedRuns.find((t) => t.analysisRunId.toString() === analysisRunId);
        if (!trackedRun) {
            throw { status: 404, message: "Tracked run not found" };
        }
        trackedRun.notifyEnabled = notifyEnabled;
        await user.save();
        return {
            message: "Notification preference updated",
            trackedRuns: user.trackedRuns,
        };
    }
    static async getFollowStats(userId) {
        const user = await User_1.default.findById(userId);
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        return {
            totalFollows: user.follows.length,
            keywordFollows: user.follows.filter((f) => f.targetType === "Keyword")
                .length,
            journalFollows: user.follows.filter((f) => f.targetType === "Journal")
                .length,
            trackedRuns: user.trackedRuns.length,
        };
    }
}
exports.FollowService = FollowService;
//# sourceMappingURL=FollowService.js.map