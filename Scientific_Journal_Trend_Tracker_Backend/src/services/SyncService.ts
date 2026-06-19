import axios from "axios";
import Paper from "../models/Paper";
import Keyword from "../models/Keyword";
import SyncLog from "../models/SyncLog";
import { NotificationService } from "./NotificationService";
import { PublicationTrendService } from "./PublicationTrendService";
import mongoose from "mongoose";

export class SyncService {
  /**
   * Main ETL Sync Function
   * Fetches data from Semantic Scholar based on tracked keywords
   */
  static async syncPapers() {
    console.log("Starting ETL Sync Process...");
    
    // Create a sync log
    const syncLog = new SyncLog({
      apiSource: new mongoose.Types.ObjectId(), // Usually would link to ApiSource
      status: "running",
      startedAt: new Date()
    });
    await syncLog.save();

    let newPapersCount = 0;
    const newPapers: any[] = [];

    try {
      // 1. Fetch keywords to track
      const keywords = await Keyword.find().limit(5); // limit for example

      for (const keyword of keywords) {
        console.log(`Syncing keyword: ${keyword.name}`);
        // 2. Call external API (Semantic Scholar - simplified)
        // Note: Semantic Scholar has rate limits. Using a basic search query.
        const apiKey = process.env.SEMANTIC_SCHOLAR_API_KEY;
        const response = await axios.get(`https://api.semanticscholar.org/graph/v1/paper/search`, {
          params: {
            query: keyword.name,
            limit: 10,
            fields: "title,abstract,url,year,externalIds,authors,citationCount"
          },
          headers: {
            ...(apiKey && { "x-api-key": apiKey })
          },
          validateStatus: () => true // Handle rate limits gracefully
        });

        if (response.status !== 200) {
          console.warn(`Failed to fetch for ${keyword.name}: ${response.statusText}`);
          continue;
        }

        const data = response.data.data || [];

        // 3. Parse, normalize, dedup
        for (const item of data) {
          const doi = item.externalIds?.DOI;
          if (!doi) continue; // Skip if no DOI for dedup

          // Dedup theo DOI
          const existing = await Paper.findOne({ doi });
          if (!existing) {
            // Lưu paper mới
            const paper = new Paper({
              title: item.title,
              abstract: item.abstract,
              doi: doi,
              url: item.url,
              publicationYear: item.year,
              citationCount: item.citationCount || 0,
              externalId_semanticScholarId: item.paperId,
              keywords: [keyword._id],
              source: "SemanticScholar",
              lastSyncedAt: new Date()
            });

            await paper.save();
            newPapers.push(paper);
            newPapersCount++;
          }
        }
      }

      // 4. Update sync log
      syncLog.status = "success";
      syncLog.finishedAt = new Date();
      syncLog.papersAdded = newPapersCount;
      await syncLog.save();
      
      console.log(`ETL Sync Completed. Added ${newPapersCount} new papers.`);

      // 5. Trigger Trend Calculation (BE-06 requirement)
      console.log("Triggering Trend Calculation...");
      await PublicationTrendService.calculateAndUpsertTrends();

      // 6. Trigger notifications (BE-09 requirement)
      if (newPapersCount > 0) {
        await NotificationService.processPostSyncNotifications(newPapers);
      }

    } catch (error: any) {
      console.error("ETL Sync Error:", error);
      syncLog.status = "failed";
      syncLog.finishedAt = new Date();
      syncLog.errorMessage = error.message;
      await syncLog.save();
    }
  }
}
