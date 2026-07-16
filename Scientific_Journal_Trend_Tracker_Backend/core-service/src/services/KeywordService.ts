import Keyword from "../models/Keyword";
import { calculateTrendScore, calculateGrowthRate } from "../utils/analytics";

export class KeywordService {
  static async getAllKeywords(
    page: number,
    limit: number,
    sort: string = "-trendScore",
  ) {
    const skip = (page - 1) * limit;

    const keywords = await Keyword.find().skip(skip).limit(limit).sort(sort);

    const total = await Keyword.countDocuments();

    return {
      keywords,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  static async getKeywordById(id: string) {
    const keyword = await Keyword.findById(id);

    if (!keyword) {
      throw { status: 404, message: "Keyword not found" };
    }

    return keyword;
  }

  static async createKeyword(keywordData: any) {
    const keyword = new Keyword(keywordData);
    keyword.trendScore = calculateTrendScore(keyword.yearlyUsage);
    await keyword.save();
    return keyword;
  }

  static async updateKeyword(id: string, keywordData: any) {
    const keyword = await Keyword.findByIdAndUpdate(id, keywordData, {
      new: true,
    });

    if (!keyword) {
      throw { status: 404, message: "Keyword not found" };
    }

    // Recalculate trend score
    keyword.trendScore = calculateTrendScore(keyword.yearlyUsage);
    await keyword.save();

    return keyword;
  }

  static async deleteKeyword(id: string) {
    const keyword = await Keyword.findByIdAndDelete(id);

    if (!keyword) {
      throw { status: 404, message: "Keyword not found" };
    }

    return keyword;
  }

  static async getTrendingKeywords(limit: number = 20) {
    const keywords = await Keyword.find().sort({ trendScore: -1 }).limit(limit);

    return keywords;
  }

  static async getKeywordsByTopic(topicId: string) {
    const keywords = await Keyword.find({ topic: topicId }).sort({
      trendScore: -1,
    });

    return keywords;
  }

  static async normalizeKeyword(text: string) {
    return text.toLowerCase().trim();
  }

  static async calculateTrendMetrics(keyword: any) {
    const values = Array.from(
      (keyword.yearlyUsage as Map<string, number>).values(),
    );
    const startValue = values.length > 0 ? values[0] : 0;
    const endValue = values.length > 0 ? values[values.length - 1] : 0;
    const years = Math.max(1, values.length - 1);

    return {
      trendScore: calculateTrendScore(keyword.yearlyUsage),
      growthRate: calculateGrowthRate(startValue, endValue, years),
    };
  }
}
