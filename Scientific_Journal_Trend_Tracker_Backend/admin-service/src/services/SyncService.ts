import axios from "axios";
import SyncLog from "../models/SyncLog";

export class SyncService {
  static async syncData(sourceId: string, parameters: any = {}) {
    const log = new SyncLog({
      sourceId,
      status: "running",
      startTime: new Date(),
    });
    await log.save();

    try {
      log.status = "success";
      await log.save();

      return log;
    } catch (error: any) {
      log.status = "failed";
      await log.save();
      throw error;
    }
  }

  static async getSyncLogs(limit: number = 20) {
    return await SyncLog.find().sort({ startTime: -1 }).limit(limit);
  }
}
