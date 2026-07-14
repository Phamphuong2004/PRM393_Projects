import AnalysisRun from "../models/AnalysisRun";

export class AnalysisRunService {
  static async getAllAnalysisRuns(page: number, limit: number) {
    const skip = (page - 1) * limit;

    const runs = await AnalysisRun.find()
      .populate("keywordId")
      .populate("syncLogId")
      .populate("topicId")
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });

    const total = await AnalysisRun.countDocuments();

    return {
      runs,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  static async getAnalysisRunById(id: string) {
    const run = await AnalysisRun.findById(id)
      .populate("keywordId")
      .populate("syncLogId")
      .populate("topicId");

    if (!run) {
      throw { status: 404, message: "Analysis run not found" };
    }

    return run;
  }

  static async createAnalysisRun(runData: any) {
    const run = new AnalysisRun(runData);
    await run.save();
    await run.populate(["keywordId", "syncLogId", "topicId"]);
    return run;
  }

  static async updateAnalysisRun(id: string, runData: any) {
    const run = await AnalysisRun.findByIdAndUpdate(id, runData, {
      new: true,
    }).populate(["keywordId", "syncLogId", "topicId"]);

    if (!run) {
      throw { status: 404, message: "Analysis run not found" };
    }

    return run;
  }

  static async deleteAnalysisRun(id: string) {
    const run = await AnalysisRun.findByIdAndDelete(id);

    if (!run) {
      throw { status: 404, message: "Analysis run not found" };
    }

    return run;
  }

  static async getAnalysisRunsByKeyword(keywordId: string) {
    const runs = await AnalysisRun.find({ keywordId })
      .populate("keywordId")
      .populate("syncLogId")
      .populate("topicId")
      .sort({ createdAt: -1 });

    return runs;
  }

  static async getActiveAnalysisRuns() {
    const runs = await AnalysisRun.find({ status: "running" })
      .populate("keywordId")
      .populate("syncLogId")
      .populate("topicId");

    return runs;
  }

  static async getCompletedAnalysisRuns(limit: number = 10) {
    const runs = await AnalysisRun.find({ status: "completed" })
      .populate("keywordId")
      .populate("syncLogId")
      .populate("topicId")
      .sort({ createdAt: -1 })
      .limit(limit);

    return runs;
  }

  static async startAnalysisRun(id: string) {
    const run = await AnalysisRun.findByIdAndUpdate(
      id,
      { status: "running", startedAt: new Date() },
      { new: true },
    ).populate(["keywordId", "syncLogId", "topicId"]);

    if (!run) {
      throw { status: 404, message: "Analysis run not found" };
    }

    return run;
  }

  static async completeAnalysisRun(id: string, results: any) {
    const run = await AnalysisRun.findByIdAndUpdate(
      id,
      {
        status: "completed",
        completedAt: new Date(),
        yearlyData: results.yearlyData,
      },
      { new: true },
    ).populate(["keywordId", "syncLogId", "topicId"]);

    if (!run) {
      throw { status: 404, message: "Analysis run not found" };
    }

    return run;
  }
}
