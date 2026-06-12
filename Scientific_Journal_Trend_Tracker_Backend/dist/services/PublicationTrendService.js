"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PublicationTrendService = void 0;
const PublicationTrend_1 = __importDefault(require("../models/PublicationTrend"));
const analytics_1 = require("../utils/analytics");
class PublicationTrendService {
    static async getAllTrends(page, limit) {
        const skip = (page - 1) * limit;
        const trends = await PublicationTrend_1.default.find()
            .populate("keywordId")
            .populate("journalId")
            .populate("analysisRunId")
            .skip(skip)
            .limit(limit)
            .sort({ calculatedAt: -1 });
        const total = await PublicationTrend_1.default.countDocuments();
        return {
            trends,
            total,
            pages: Math.ceil(total / limit),
        };
    }
    static async getTrendingPublications(limit = 50) {
        const trends = await PublicationTrend_1.default.find({ isTrending: true })
            .populate("keywordId")
            .populate("journalId")
            .populate("analysisRunId")
            .sort({ growthRate: -1 })
            .limit(limit);
        return trends;
    }
    static async getTrendById(id) {
        const trend = await PublicationTrend_1.default.findById(id)
            .populate("keywordId")
            .populate("journalId")
            .populate("analysisRunId");
        if (!trend) {
            throw { status: 404, message: "Publication trend not found" };
        }
        return trend;
    }
    static async createTrend(trendData) {
        // Calculate growth rate if needed
        if (trendData.previousCount) {
            trendData.growthRate = (0, analytics_1.calculateGrowthRate)(trendData.paperCount, trendData.previousCount);
        }
        // Determine if trending based on growth rate
        if (trendData.growthRate && trendData.growthRate > 0.2) {
            trendData.isTrending = true;
        }
        const trend = new PublicationTrend_1.default(trendData);
        await trend.save();
        await trend.populate(["keywordId", "journalId", "analysisRunId"]);
        return trend;
    }
    static async updateTrend(id, trendData) {
        const trend = await PublicationTrend_1.default.findByIdAndUpdate(id, trendData, {
            new: true,
        }).populate(["keywordId", "journalId", "analysisRunId"]);
        if (!trend) {
            throw { status: 404, message: "Publication trend not found" };
        }
        return trend;
    }
    static async deleteTrend(id) {
        const trend = await PublicationTrend_1.default.findByIdAndDelete(id);
        if (!trend) {
            throw { status: 404, message: "Publication trend not found" };
        }
        return trend;
    }
    static async getTrendsByKeyword(keywordId) {
        const trends = await PublicationTrend_1.default.find({ keywordId })
            .populate("keywordId")
            .populate("journalId")
            .populate("analysisRunId")
            .sort({ year: -1 });
        return trends;
    }
    static async getTrendsByJournal(journalId) {
        const trends = await PublicationTrend_1.default.find({ journalId })
            .populate("keywordId")
            .populate("journalId")
            .populate("analysisRunId")
            .sort({ year: -1 });
        return trends;
    }
    static async getTrendsByYear(year) {
        const trends = await PublicationTrend_1.default.find({ year })
            .populate("keywordId")
            .populate("journalId")
            .populate("analysisRunId")
            .sort({ growthRate: -1 });
        return trends;
    }
    static async getTrendsByYearRange(startYear, endYear) {
        const trends = await PublicationTrend_1.default.find({
            year: { $gte: startYear, $lte: endYear },
        })
            .populate("keywordId")
            .populate("journalId")
            .populate("analysisRunId")
            .sort({ year: 1, growthRate: -1 });
        return trends;
    }
    static async getMonthlyTrends(keywordId, year) {
        const trends = await PublicationTrend_1.default.find({
            keywordId,
            year,
            month: { $exists: true },
        })
            .populate("keywordId")
            .populate("journalId")
            .populate("analysisRunId")
            .sort({ month: 1 });
        return trends;
    }
    static async analyzeTrendGrowth(keywordId, startYear, endYear) {
        const trends = await PublicationTrend_1.default.find({
            keywordId,
            year: { $gte: startYear, $lte: endYear },
        }).sort({ year: 1 });
        const analysis = {
            keywordId,
            startYear,
            endYear,
            trends: trends.map((t) => ({
                year: t.year,
                paperCount: t.paperCount,
                growthRate: t.growthRate,
            })),
            overallGrowthRate: trends.length > 1
                ? (0, analytics_1.calculateGrowthRate)(trends[trends.length - 1].paperCount, trends[0].paperCount)
                : 0,
        };
        return analysis;
    }
}
exports.PublicationTrendService = PublicationTrendService;
// Aliases used by routes
PublicationTrendService.getAllPublicationTrends = PublicationTrendService.getAllTrends;
PublicationTrendService.getPublicationTrendById = PublicationTrendService.getTrendById;
PublicationTrendService.createPublicationTrend = PublicationTrendService.createTrend;
PublicationTrendService.updatePublicationTrend = PublicationTrendService.updateTrend;
PublicationTrendService.deletePublicationTrend = PublicationTrendService.deleteTrend;
//# sourceMappingURL=PublicationTrendService.js.map