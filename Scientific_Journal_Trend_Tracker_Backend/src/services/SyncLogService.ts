import { SyncLog } from "../models";

export class SyncLogService {
  static async getAllSyncLogs(page: number, limit: number, status?: string) {
    const skip = (page - 1) * limit;

    let query: any = {};
    if (status && ["success", "failed", "running"].includes(status)) {
      query.status = status;
    }

    const logs = await SyncLog.find(query)
      .populate("apiSource", "name baseUrl")
      .skip(skip)
      .limit(limit)
      .sort({ startedAt: -1 });

    const total = await SyncLog.countDocuments(query);

    return {
      logs,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  static async getSyncLogById(id: string) {
    const log = await SyncLog.findById(id).populate("apiSource", "name baseUrl");

    if (!log) {
      throw { status: 404, message: "Sync log not found" };
    }

    return log;
  }

  static async deleteSyncLog(id: string) {
    const log = await SyncLog.findByIdAndDelete(id);

    if (!log) {
      throw { status: 404, message: "Sync log not found" };
    }

    return log;
  }

  static async clearAllSyncLogs() {
    const result = await SyncLog.deleteMany({});
    return { deletedCount: result.deletedCount };
  }
}
