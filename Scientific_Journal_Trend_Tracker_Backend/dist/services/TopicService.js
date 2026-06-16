"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TopicService = void 0;
const Topic_1 = __importDefault(require("../models/Topic"));
const analytics_1 = require("../utils/analytics");
class TopicService {
    static async getAllTopics(page, limit) {
        const skip = (page - 1) * limit;
        const topics = await Topic_1.default.find()
            .populate("analysisRunId")
            .populate("papers")
            .skip(skip)
            .limit(limit)
            .sort({ createdAt: -1 });
        const total = await Topic_1.default.countDocuments();
        return {
            topics,
            total,
            pages: Math.ceil(total / limit),
        };
    }
    static async getTopicById(id) {
        const topic = await Topic_1.default.findById(id)
            .populate("analysisRunId")
            .populate("papers");
        if (!topic) {
            throw { status: 404, message: "Topic not found" };
        }
        return topic;
    }
    static async createTopic(topicData) {
        const topic = new Topic_1.default(topicData);
        await topic.save();
        await topic.populate(["analysisRunId", "papers"]);
        return topic;
    }
    static async updateTopic(id, topicData) {
        const topic = await Topic_1.default.findByIdAndUpdate(id, topicData, {
            new: true,
        }).populate(["analysisRunId", "papers"]);
        if (!topic) {
            throw { status: 404, message: "Topic not found" };
        }
        return topic;
    }
    static async deleteTopic(id) {
        const topic = await Topic_1.default.findByIdAndDelete(id);
        if (!topic) {
            throw { status: 404, message: "Topic not found" };
        }
        return topic;
    }
    static async getEmergingTopics() {
        const topics = await Topic_1.default.find({ isEmerging: true })
            .populate("analysisRunId")
            .populate("papers")
            .sort({ createdAt: -1 });
        return topics;
    }
    static async analyzeTrendStatus(yearlyData) {
        const years = Array.from(yearlyData.keys()).sort((a, b) => Number(a) - Number(b));
        if (years.length < 2)
            return "stable";
        const firstYear = years[0];
        const lastYear = years[years.length - 1];
        const firstValue = yearlyData.get(firstYear) ?? 0;
        const lastValue = yearlyData.get(lastYear) ?? 0;
        const yearSpan = Math.max(1, Number(lastYear) - Number(firstYear));
        const growthRate = firstValue === 0
            ? 0
            : ((lastValue - firstValue) / firstValue) * (100 / yearSpan);
        return (0, analytics_1.normalizeTrendStatus)(growthRate);
    }
    static async updateTrendStatus(id) {
        const topic = await Topic_1.default.findById(id);
        if (!topic) {
            throw { status: 404, message: "Topic not found" };
        }
        topic.trendStatus = await this.analyzeTrendStatus(topic.yearlyData);
        topic.isEmerging = topic.trendStatus === "emerging";
        await topic.save();
        return topic;
    }
}
exports.TopicService = TopicService;
//# sourceMappingURL=TopicService.js.map