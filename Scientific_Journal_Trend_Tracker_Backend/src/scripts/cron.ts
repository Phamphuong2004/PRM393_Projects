import cron from "node-cron";
import { SyncService } from "../services/SyncService";

export const initCronJobs = () => {
  console.log("Initializing Cron Jobs...");
  
  // Run everyday at midnight (0 0 * * *)
  // For testing purposes, you could change this to '* * * * *' (every minute)
  cron.schedule("0 0 * * *", async () => {
    console.log(`[CRON] Triggering SyncService at ${new Date().toISOString()}`);
    await SyncService.syncPapers();
  });
  
  console.log("Cron Jobs Initialized.");
};
