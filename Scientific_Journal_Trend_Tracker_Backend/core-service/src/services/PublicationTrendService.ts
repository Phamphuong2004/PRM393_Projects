import mongoose from "mongoose";
import PublicationTrend from "../models/PublicationTrend";
import Keyword from "../models/Keyword";
import Paper from "../models/Paper";
// AnalysisRun imported removed
import { calculateGrowthRate } from "../utils/analytics";

export class PublicationTrendService {
  static async getAllTrends(page: number, limit: number) {
    const skip = (page - 1) * limit;

    const trends = await PublicationTrend.find()
      .populate("keywordId")
      .populate("journalId")
      .populate("analysisRunId")
      .skip(skip)
      .limit(limit)
      .sort({ calculatedAt: -1 });

    const total = await PublicationTrend.countDocuments();

    return {
      trends,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  static async getTrendingPublications(limit: number = 50) {
    const trends = await PublicationTrend.find({ isTrending: true })
      .populate("keywordId")
      .populate("journalId")
      .populate("analysisRunId")
      .sort({ growthRate: -1 })
      .limit(limit);

    return trends;
  }

  static async getTrendById(id: string) {
    const trend = await PublicationTrend.findById(id)
      .populate("keywordId")
      .populate("journalId")
      .populate("analysisRunId");

    if (!trend) {
      throw { status: 404, message: "Publication trend not found" };
    }

    return trend;
  }

  static async createTrend(trendData: any) {
    // Calculate growth rate if needed
    if (trendData.previousCount) {
      trendData.growthRate = calculateGrowthRate(
        trendData.previousCount,
        trendData.paperCount,
      );
    }

    // Determine if trending based on growth rate
    if (trendData.growthRate && trendData.growthRate > 20) {
      trendData.isTrending = true;
    }

    const trend = new PublicationTrend(trendData);
    await trend.save();
    await trend.populate(["keywordId", "journalId", "analysisRunId"]);

    return trend;
  }

  static async updateTrend(id: string, trendData: any) {
    const trend = await PublicationTrend.findByIdAndUpdate(id, trendData, {
      new: true,
    }).populate(["keywordId", "journalId", "analysisRunId"]);

    if (!trend) {
      throw { status: 404, message: "Publication trend not found" };
    }

    return trend;
  }

  static async deleteTrend(id: string) {
    const trend = await PublicationTrend.findByIdAndDelete(id);

    if (!trend) {
      throw { status: 404, message: "Publication trend not found" };
    }

    return trend;
  }

  static async getTrendsByKeyword(keywordId: string) {
    const trends = await PublicationTrend.find({ keywordId })
      .populate("keywordId")
      .populate("journalId")
      .populate("analysisRunId")
      .sort({ year: -1 });

    return trends;
  }

  static async getTrendsByJournal(journalId: string) {
    const trends = await PublicationTrend.find({ journalId })
      .populate("keywordId")
      .populate("journalId")
      .populate("analysisRunId")
      .sort({ year: -1 });

    return trends;
  }

  static async getTrendsByYear(year: number) {
    const trends = await PublicationTrend.find({ year })
      .populate("keywordId")
      .populate("journalId")
      .populate("analysisRunId")
      .sort({ growthRate: -1 });

    return trends;
  }

  static async getTrendsByYearRange(startYear: number, endYear: number) {
    const trends = await PublicationTrend.find({
      year: { $gte: startYear, $lte: endYear },
    })
      .populate("keywordId")
      .populate("journalId")
      .populate("analysisRunId")
      .sort({ year: 1, growthRate: -1 });

    return trends;
  }

  static async getMonthlyTrends(keywordId: string, year: number) {
    const trends = await PublicationTrend.find({
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

  static async analyzeTrendGrowth(
    keywordId: string,
    startYear: number,
    endYear: number,
  ) {
    const trends = await PublicationTrend.find({
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
      overallGrowthRate:
        trends.length > 1
          ? calculateGrowthRate(
              trends[trends.length - 1].paperCount,
              trends[0].paperCount,
            )
          : 0,
    };

    return analysis;
  }

  static async calculateAndUpsertTrends() {
    console.log("[TrendService] Starting trend calculation...");
    
    // 1. Calculate paper counts per keyword x year using Aggregation
    const trendsAggregation = await Paper.aggregate([
      { $unwind: "$keywords" },
      {
        $group: {
          _id: {
            keywordId: "$keywords",
            year: "$publicationYear"
          },
          paperCount: { $sum: 1 }
        }
      },
      {
        $sort: { "_id.keywordId": 1, "_id.year": 1 }
      }
    ]);

    // Group the results by keyword to calculate growth rates and prepare bulk operations
    const keywordYearCounts: Record<string, { year: number; paperCount: number }[]> = {};
    
    for (const item of trendsAggregation) {
      if (!item._id.keywordId || !item._id.year) continue;
      const kwStr = item._id.keywordId.toString();
      if (!keywordYearCounts[kwStr]) {
        keywordYearCounts[kwStr] = [];
      }
      keywordYearCounts[kwStr].push({
        year: item._id.year,
        paperCount: item.paperCount
      });
    }

    const trendBulkOps = [];
    const runBulkOps = [];

    // Map to keep track of analysisRunId per keyword
    const analysisRunsMap: Record<string, mongoose.Types.ObjectId> = {};

    for (const [kwStr, yearsData] of Object.entries(keywordYearCounts)) {
      const keywordId = new mongoose.Types.ObjectId(kwStr);
      const analysisRunId = new mongoose.Types.ObjectId();
      analysisRunsMap[kwStr] = analysisRunId;

      // 1.a Create an AnalysisRun for this keyword
      runBulkOps.push({
        insertOne: {
          document: {
            _id: analysisRunId,
            keywordId: keywordId,
            status: "completed",
            source: "batch-calculation",
          }
        }
      });

      // Sort by year to calculate growth rate
      yearsData.sort((a, b) => a.year - b.year);
      
      let previousCount = 0;
      for (const data of yearsData) {
        const growthRate = previousCount === 0 ? 0 : calculateGrowthRate(previousCount, data.paperCount);
        const isTrending = growthRate > 20;

        trendBulkOps.push({
          updateOne: {
            filter: { keywordId, year: data.year },
            update: {
              $set: {
                keywordId,
                year: data.year,
                paperCount: data.paperCount,
                previousCount,
                growthRate,
                isTrending,
                analysisRunId,
                calculatedAt: new Date()
              }
            },
            upsert: true
          }
        });

        previousCount = data.paperCount;
      }
    }

    // Execute Bulk Ops for AnalysisRun and PublicationTrend
    // if (runBulkOps.length > 0) {
    //   await AnalysisRun.bulkWrite(runBulkOps);
    // }
    if (trendBulkOps.length > 0) {
      await PublicationTrend.bulkWrite(trendBulkOps);
    }

    // 2. Denormalize paperCount into Keyword collection
    console.log("[TrendService] Updating Keyword paperCounts...");
    const keywordAggregation = await Paper.aggregate([
      { $unwind: "$keywords" },
      {
        $group: {
          _id: "$keywords",
          totalCount: { $sum: 1 }
        }
      }
    ]);

    const keywordBulkOps = [];
    for (const item of keywordAggregation) {
      if (!item._id) continue;
      keywordBulkOps.push({
        updateOne: {
          filter: { _id: item._id },
          update: { $set: { paperCount: item.totalCount } }
        }
      });
    }

    if (keywordBulkOps.length > 0) {
      await Keyword.bulkWrite(keywordBulkOps);
    }

    console.log(`[TrendService] Calculation finished. Updated ${trendBulkOps.length} trends and ${keywordBulkOps.length} keywords.`);
  }

  // Aliases used by routes
  static getAllPublicationTrends = PublicationTrendService.getAllTrends;
  static getPublicationTrendById = PublicationTrendService.getTrendById;
  static createPublicationTrend = PublicationTrendService.createTrend;
  static updatePublicationTrend = PublicationTrendService.updateTrend;
  static deletePublicationTrend = PublicationTrendService.deleteTrend;
}
