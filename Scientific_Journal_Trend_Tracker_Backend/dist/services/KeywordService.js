"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.KeywordService = void 0;
const Keyword_1 = __importDefault(require("../models/Keyword"));
const analytics_1 = require("../utils/analytics");
class KeywordService {
    static async getAllKeywords(page, limit, sort = "-trendScore") {
        const skip = (page - 1) * limit;
        const keywords = await Keyword_1.default.find().skip(skip).limit(limit).sort(sort);
        const total = await Keyword_1.default.countDocuments();
        return {
            keywords,
            total,
            pages: Math.ceil(total / limit),
        };
    }
    static async getKeywordById(id) {
        const keyword = await Keyword_1.default.findById(id);
        if (!keyword) {
            throw { status: 404, message: "Keyword not found" };
        }
        return keyword;
    }
    static async createKeyword(keywordData) {
        const keyword = new Keyword_1.default(keywordData);
        keyword.trendScore = (0, analytics_1.calculateTrendScore)(keyword.yearlyUsage);
        await keyword.save();
        return keyword;
    }
    static async updateKeyword(id, keywordData) {
        const keyword = await Keyword_1.default.findByIdAndUpdate(id, keywordData, {
            new: true,
        });
        if (!keyword) {
            throw { status: 404, message: "Keyword not found" };
        }
        // Recalculate trend score
        keyword.trendScore = (0, analytics_1.calculateTrendScore)(keyword.yearlyUsage);
        await keyword.save();
        return keyword;
    }
    static async deleteKeyword(id) {
        const keyword = await Keyword_1.default.findByIdAndDelete(id);
        if (!keyword) {
            throw { status: 404, message: "Keyword not found" };
        }
        return keyword;
    }
    static async getTrendingKeywords(limit = 20) {
        const keywords = await Keyword_1.default.find().sort({ trendScore: -1 }).limit(limit);
        return keywords;
    }
    static async getKeywordsByTopic(topicId) {
        const keywords = await Keyword_1.default.find({ topic: topicId }).sort({
            trendScore: -1,
        });
        return keywords;
    }
    static async normalizeKeyword(text) {
        return text.toLowerCase().trim();
    }
    static async calculateTrendMetrics(keyword) {
        const values = Array.from(keyword.yearlyUsage.values());
        const startValue = values.length > 0 ? values[0] : 0;
        const endValue = values.length > 0 ? values[values.length - 1] : 0;
        const years = Math.max(1, values.length - 1);
        return {
            trendScore: (0, analytics_1.calculateTrendScore)(keyword.yearlyUsage),
            growthRate: (0, analytics_1.calculateGrowthRate)(startValue, endValue, years),
        };
    }
}
exports.KeywordService = KeywordService;
//# sourceMappingURL=KeywordService.js.map