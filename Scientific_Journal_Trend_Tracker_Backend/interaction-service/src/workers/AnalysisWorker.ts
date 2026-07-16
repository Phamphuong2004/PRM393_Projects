import { AnalysisRunService } from "../services/AnalysisRunService";

export class AnalysisWorker {
  private static isRunning = false;
  private static intervalId: NodeJS.Timeout | null = null;

  static start() {
    if (this.intervalId) return;

    console.log("🛠️  Starting Analysis Worker...");
    // Check for pending jobs every 10 seconds
    this.intervalId = setInterval(async () => {
      if (this.isRunning) return;
      this.isRunning = true;

      try {
        const pendingRuns = await AnalysisRunService.getPendingAnalysisRuns(5);
        for (const run of pendingRuns) {
          console.log(`[Worker] Processing Analysis Run ID: ${run._id}`);
          // 1. Mark as running
          await AnalysisRunService.startAnalysisRun(run._id as string);

          // 2. Simulate processing delay (e.g. calling external APIs)
          await new Promise((resolve) => setTimeout(resolve, 3000));

          // 3. Generate mock yearly data
          const startYear = run.startYear || 2015;
          const endYear = run.endYear || new Date().getFullYear();
          const yearlyData: Record<string, number> = {};
          
          let baseCount = Math.floor(Math.random() * 50) + 10;
          for (let year = startYear; year <= endYear; year++) {
            // Simulate trend growth/decline
            const change = Math.floor(Math.random() * 20) - 5; // -5 to +15
            baseCount = Math.max(0, baseCount + change);
            yearlyData[year.toString()] = baseCount;
          }

          // 4. Mark as completed
          await AnalysisRunService.completeAnalysisRun(run._id as string, { yearlyData });
          console.log(`[Worker] Completed Analysis Run ID: ${run._id}`);
        }
      } catch (error) {
        console.error("[Worker] Error processing analysis runs:", error);
      } finally {
        this.isRunning = false;
      }
    }, 10000);
  }

  static stop() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
      console.log("🛑 Stopped Analysis Worker.");
    }
  }
}
