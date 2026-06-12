"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AnalysisRunService = void 0;
const AnalysisRun_1 = __importDefault(require("../models/AnalysisRun"));
class AnalysisRunService {
    static async getAllAnalysisRuns(page, limit) {
        const skip = (page - 1) * limit;
        const runs = await AnalysisRun_1.default.find()
            .populate("keywordId")
            .populate("syncLogId")
            .populate("topicId")
            .skip(skip)
            .limit(limit)
            .sort({ createdAt: -1 });
        const total = await AnalysisRun_1.default.countDocuments();
        return {
            runs,
            total,
            pages: Math.ceil(total / limit),
        };
    }
    static async getAnalysisRunById(id) {
        const run = await AnalysisRun_1.default.findById(id)
            .populate("keywordId")
            .populate("syncLogId")
            .populate("topicId");
        if (!run) {
            throw { status: 404, message: "Analysis run not found" };
        }
        return run;
    }
    static async createAnalysisRun(runData) {
        const run = new AnalysisRun_1.default(runData);
        await run.save();
        await run.populate(["keywordId", "syncLogId", "topicId"]);
        return run;
    }
    static async updateAnalysisRun(id, runData) {
        const run = await AnalysisRun_1.default.findByIdAndUpdate(id, runData, {
            new: true,
        }).populate(["keywordId", "syncLogId", "topicId"]);
        if (!run) {
            throw { status: 404, message: "Analysis run not found" };
        }
        return run;
    }
    static async deleteAnalysisRun(id) {
        const run = await AnalysisRun_1.default.findByIdAndDelete(id);
        if (!run) {
            throw { status: 404, message: "Analysis run not found" };
        }
        return run;
    }
    static async getAnalysisRunsByKeyword(keywordId) {
        const runs = await AnalysisRun_1.default.find({ keywordId })
            .populate("keywordId")
            .populate("syncLogId")
            .populate("topicId")
            .sort({ createdAt: -1 });
        return runs;
    }
    static async getActiveAnalysisRuns() {
        const runs = await AnalysisRun_1.default.find({ status: "running" })
            .populate("keywordId")
            .populate("syncLogId")
            .populate("topicId");
        return runs;
    }
    static async getCompletedAnalysisRuns(limit = 10) {
        const runs = await AnalysisRun_1.default.find({ status: "completed" })
            .populate("keywordId")
            .populate("syncLogId")
            .populate("topicId")
            .sort({ createdAt: -1 })
            .limit(limit);
        return runs;
    }
    static async startAnalysisRun(id) {
        const run = await AnalysisRun_1.default.findByIdAndUpdate(id, { status: "running", startedAt: new Date() }, { new: true }).populate(["keywordId", "syncLogId", "topicId"]);
        if (!run) {
            throw { status: 404, message: "Analysis run not found" };
        }
        return run;
    }
    static async completeAnalysisRun(id, results) {
        const run = await AnalysisRun_1.default.findByIdAndUpdate(id, {
            status: "completed",
            completedAt: new Date(),
            yearlyData: results.yearlyData,
        }, { new: true }).populate(["keywordId", "syncLogId", "topicId"]);
        if (!run) {
            throw { status: 404, message: "Analysis run not found" };
        }
        return run;
    }
}
exports.AnalysisRunService = AnalysisRunService;
//# sourceMappingURL=AnalysisRunService.js.map