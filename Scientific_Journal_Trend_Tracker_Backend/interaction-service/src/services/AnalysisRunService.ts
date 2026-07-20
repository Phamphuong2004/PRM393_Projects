import AnalysisRun from "../models/AnalysisRun";

export class AnalysisRunService {
  static async getAllAnalysisRuns(page: number, limit: number) {
    const skip = (page - 1) * limit;

    const runs = await AnalysisRun.find()

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
;

    if (!run) {
      throw { status: 404, message: "Analysis run not found" };
    }

    return run;
  }

  static async createAnalysisRun(runData: any) {
    const run = new AnalysisRun(runData);
    await run.save();
    await run;
    return run;
  }

  static async updateAnalysisRun(id: string, runData: any) {
    const run = await AnalysisRun.findByIdAndUpdate(id, runData, {
      new: true,
    });

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

      .sort({ createdAt: -1 });

    return runs;
  }

  static async getActiveAnalysisRuns() {
    const runs = await AnalysisRun.find({ status: "running" })
;

    return runs;
  }

  static async getPendingAnalysisRuns(limit: number = 10) {
    const runs = await AnalysisRun.find({ status: "pending" })

      .sort({ createdAt: 1 }) // oldest first
      .limit(limit);

    return runs;
  }

  static async getCompletedAnalysisRuns(limit: number = 10) {
    const runs = await AnalysisRun.find({ status: "completed" })

      .sort({ createdAt: -1 })
      .limit(limit);

    return runs;
  }

  static async startAnalysisRun(id: string) {
    const run = await AnalysisRun.findByIdAndUpdate(
      id,
      { status: "running", startedAt: new Date() },
      { new: true },
    );

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
    );

    if (!run) {
      throw { status: 404, message: "Analysis run not found" };
    }

    return run;
  }
}
