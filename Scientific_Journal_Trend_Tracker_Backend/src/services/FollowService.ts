import User from "../models/User";
import Keyword from "../models/Keyword";
import Journal from "../models/Journal";
import AnalysisRun from "../models/AnalysisRun";
import mongoose from "mongoose";

export class FollowService {
  static async getUserFollows(userId: string) {
    const user = await User.findById(userId).populate("follows");

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    return user.follows;
  }

  static async addFollow(
    userId: string,
    targetType: "Keyword" | "Journal",
    targetId: string,
    notifyEnabled: boolean = true,
  ) {
    if (targetType !== "Keyword" && targetType !== "Journal") {
      throw { status: 400, message: "Invalid target type" };
    }

    // Verify target exists
    if (targetType === "Keyword") {
      const keyword = await Keyword.findById(targetId);
      if (!keyword) {
        throw { status: 404, message: "Keyword not found" };
      }
    } else if (targetType === "Journal") {
      const journal = await Journal.findById(targetId);
      if (!journal) {
        throw { status: 404, message: "Journal not found" };
      }
    }

    const user = await User.findById(userId);

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    // Check if already following
    const existingFollow = user.follows.find(
      (f) => f.targetType === targetType && f.targetId.toString() === targetId,
    );

    if (!existingFollow) {
      user.follows.push({
        targetType,
        targetId: new mongoose.Types.ObjectId(targetId),
        notifyEnabled,
      });
      await user.save();
    }

    return { message: "Following added", follows: user.follows };
  }

  static async removeFollow(userId: string, targetId: string) {
    const user = await User.findByIdAndUpdate(
      userId,
      { $pull: { follows: { targetId } } },
      { new: true },
    );

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    return { message: "Following removed", follows: user.follows };
  }

  static async checkIfFollowing(
    userId: string,
    targetType: string,
    targetId: string,
  ) {
    const user = await User.findById(userId);

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    const isFollowing = user.follows.some(
      (f) => f.targetType === targetType && f.targetId.toString() === targetId,
    );

    return { isFollowing };
  }

  static async getTrackedRuns(userId: string) {
    const user = await User.findById(userId).populate({
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

  static async trackAnalysisRun(
    userId: string,
    analysisRunId: string,
    notifyEnabled: boolean = true,
  ) {
    const run = await AnalysisRun.findById(analysisRunId);

    if (!run) {
      throw { status: 404, message: "Analysis run not found" };
    }

    const user = await User.findById(userId);

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    // Check if already tracking
    const existingTrack = user.trackedRuns.find(
      (t) => t.analysisRunId.toString() === analysisRunId,
    );

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

  static async untrackAnalysisRun(userId: string, analysisRunId: string) {
    const user = await User.findByIdAndUpdate(
      userId,
      { $pull: { trackedRuns: { analysisRunId } } },
      { new: true },
    );

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    return { message: "Analysis run untracked", trackedRuns: user.trackedRuns };
  }

  static async updateTrackedRunNotification(
    userId: string,
    analysisRunId: string,
    notifyEnabled: boolean,
  ) {
    const user = await User.findById(userId);

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    const trackedRun = user.trackedRuns.find(
      (t) => t.analysisRunId.toString() === analysisRunId,
    );

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

  static async getFollowStats(userId: string) {
    const user = await User.findById(userId);

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
