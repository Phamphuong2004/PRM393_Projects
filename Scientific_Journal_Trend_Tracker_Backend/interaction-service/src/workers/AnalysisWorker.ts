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

          // 3. Generate real yearly data from Semantic Scholar
          const startYear = run.startYear || 2015;
          const endYear = run.endYear || new Date().getFullYear();
          const yearlyData: Record<string, number> = {};
          const axios = require('axios');
          const apiKey = process.env.SEMANTIC_SCHOLAR_API_KEY;
          
          for (let year = startYear; year <= endYear; year++) {
            let success = false;
            let retries = 5;
            
            while (!success && retries > 0) {
              try {
                const res = await axios.get(`https://api.semanticscholar.org/graph/v1/paper/search`, {
                  params: { query: run.seedKeyword, year: year, limit: 1 },
                  headers: apiKey ? { "x-api-key": apiKey } : {},
                  validateStatus: () => true
                });
                
                if (res.status === 200 && res.data) {
                  yearlyData[year.toString()] = res.data.total || 0;
                  success = true;
                } else if (res.status === 429) {
                  console.log(`[Worker] Rate limited for ${year}, retrying... (${retries} left)`);
                  retries--;
                  await new Promise(r => setTimeout(r, 5000)); // Wait 5s before retry
                  continue;
                } else {
                  console.log(`[Worker] API returned ${res.status} for ${year}`);
                  yearlyData[year.toString()] = 0;
                  success = true;
                }
              } catch (err) {
                console.error(`[Worker] Error fetching data for ${year}:`, err);
                retries--;
                await new Promise(r => setTimeout(r, 5000));
              }
            }
            
            if (!success) {
               yearlyData[year.toString()] = 0;
            }

            // Normal rate limit protection (2s to be safe on free tier)
            await new Promise(r => setTimeout(r, 2000));
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
