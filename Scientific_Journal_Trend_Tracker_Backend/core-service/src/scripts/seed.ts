import mongoose from "mongoose";
import dotenv from "dotenv";
import Keyword from "../models/Keyword";
import Topic from "../models/Topic";
import PublicationTrend from "../models/PublicationTrend";
import Paper from "../models/Paper";
import Journal from "../models/Journal";
import Author from "../models/Author";
import path from "path";
import axios from "axios";

// Load environment variables
dotenv.config({ path: path.join(__dirname, "../../../.env") });

const MONGODB_URI = process.env.MONGODB_URI 
  ? process.env.MONGODB_URI.replace("/JournalTrackerDB?", "/core_db?").replace("/?", "/core_db?")
  : "mongodb+srv://thanhtu_user:Thanhtu%40204@cluster0.h3nsaiz.mongodb.net/core_db?appName=Cluster0";

const SEED_QUERIES = ["IoT", "Mamba Architecture", "iPhone", "Samsung"];
const PER_PAGE_OPENALEX = 10; // per topic to save time
const PER_PAGE_ARXIV = 5; // per topic to save time

const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const fetchArxivPapers = async (query: string) => {
  try {
    const url = `http://export.arxiv.org/api/query?search_query=all:"${encodeURIComponent(query)}"&start=0&max_results=${PER_PAGE_ARXIV}&sortBy=submittedDate&sortOrder=descending`;
    const response = await axios.get(url);
    const xml = response.data;
    
    // Simple regex parser for arXiv XML
    const entries = xml.match(/<entry>[\s\S]*?<\/entry>/g) || [];
    const papers = [];
    
    for (const entry of entries) {
      const titleMatch = entry.match(/<title>([\s\S]*?)<\/title>/);
      const idMatch = entry.match(/<id>([\s\S]*?)<\/id>/);
      const summaryMatch = entry.match(/<summary>([\s\S]*?)<\/summary>/);
      const publishedMatch = entry.match(/<published>([\s\S]*?)<\/published>/);
      const doiMatch = entry.match(/<arxiv:doi[^>]*>([\s\S]*?)<\/arxiv:doi>/);
      
      const authorMatches = entry.match(/<author>[\s\S]*?<name>([\s\S]*?)<\/name>[\s\S]*?<\/author>/g) || [];
      const authors = authorMatches.map((a: string) => {
        const nameMatch = a.match(/<name>([\s\S]*?)<\/name>/);
        return nameMatch ? nameMatch[1].trim() : "Unknown";
      });

      if (titleMatch && idMatch) {
        papers.push({
          title: titleMatch[1].trim().replace(/\n/g, " "),
          abstract: summaryMatch ? summaryMatch[1].trim() : "No abstract",
          url: idMatch[1].trim(),
          doi: doiMatch ? doiMatch[1].trim() : idMatch[1].trim(), // fallback to arXiv URL
          year: publishedMatch ? new Date(publishedMatch[1].trim()).getFullYear() : new Date().getFullYear(),
          authors: authors,
          source: "arxiv"
        });
      }
    }
    return papers;
  } catch (error) {
    console.error(`Error fetching arXiv for ${query}:`, error);
    return [];
  }
};

const seedRealData = async () => {
  try {
    console.log("Connecting to MongoDB:", MONGODB_URI);
    await mongoose.connect(MONGODB_URI);
    console.log("Connected to MongoDB successfully.");

    console.log("Adding new topics without clearing old data...");

    const dummyAnalysisRunId = new mongoose.Types.ObjectId();
    const currentYear = new Date().getFullYear();

    console.log(`Will fetch data for ${SEED_QUERIES.length} topics:`, SEED_QUERIES);

    for (const query of SEED_QUERIES) {
      console.log(`\n======================================`);
      console.log(`Fetching real data for query: "${query}"`);
      
      const topicPapers = [];
      const keywordsMap = new Map();

      // --- 1. OPENALEX DATA ---
      console.log(`[OpenAlex] Fetching...`);
      const url = `https://api.openalex.org/works?search=${encodeURIComponent(query)}&per-page=${PER_PAGE_OPENALEX}&sort=publication_date:desc`;
      const oaResponse = await axios.get(url);
      const works = oaResponse.data.results;
      
      for (const work of works) {
        // Process Journal
        let journalId = null;
        if (work.primary_location && work.primary_location.source) {
          const sourceName = work.primary_location.source.display_name;
          const issn = work.primary_location.source.issn_l || `N/A_${Math.random().toString(36).substring(7)}`;
          let journal = await Journal.findOne({ name: sourceName });
          if (!journal) {
            journal = await Journal.create({
              name: sourceName,
              issn: issn,
              impactFactor: Math.floor(Math.random() * 10) + 1,
              field: query,
              paperCount: 1
            });
          } else {
            journal.paperCount += 1;
            await journal.save();
          }
          journalId = journal._id;
        }

        // Process Authors
        const authorIds = [];
        for (const authorship of work.authorships || []) {
          const authorName = authorship.author.display_name;
          const authorOpenAlexId = authorship.author.id;
          const author = await Author.findOneAndUpdate(
            { fullName: authorName },
            {
              $setOnInsert: {
                fullName: authorName,
                openalexId: authorOpenAlexId,
                email: "unknown@example.com",
                affiliation: authorship.institutions?.[0]?.display_name || "Unknown",
                hIndex: Math.floor(Math.random() * 20),
              }
            },
            { upsert: true, new: true }
          );
          authorIds.push(author._id);
        }

        // Process Keywords
        const keywordIds = [];
        const concepts = (work.concepts || []).filter((c: any) => c.level <= 2).slice(0, 5);
        for (const concept of concepts) {
          const keywordName = concept.display_name;
          const keyword = await Keyword.findOneAndUpdate(
            { name: keywordName },
            {
              $inc: { paperCount: 1 },
              $setOnInsert: {
                normalizedText: keywordName.toLowerCase(),
                openalexId: concept.id,
                workCount: concept.works_count,
                trendScore: Math.random() * 10,
                growthRate: Math.random() * 15 - 5
              }
            },
            { upsert: true, new: true }
          );
          keywordsMap.set(keywordName, keyword);
          keywordIds.push(keyword._id);
        }

        // Process Paper
        if (work.title) {
          const doiValue = work.doi || work.id;
          let paper = await Paper.findOne({ doi: doiValue });
          if (!paper) {
            paper = await Paper.create({
              title: work.title,
              abstract: work.abstract_inverted_index ? "Abstract available on OpenAlex." : "No abstract available.",
              doi: doiValue,
              url: work.id,
              publicationYear: work.publication_year,
              citationCount: work.cited_by_count,
              authors: authorIds,
              journalId: journalId,
              keywords: keywordIds,
              source: "openalex"
            });
          }
          topicPapers.push(paper._id);
        }
      }

      // --- 2. ARXIV DATA ---
      console.log(`[arXiv] Fetching...`);
      const arxivPapers = await fetchArxivPapers(query);
      
      // Ensure we have an arXiv journal
      let arxivJournal = await Journal.findOne({ name: "arXiv" });
      if (!arxivJournal) {
        arxivJournal = await Journal.create({
          name: "arXiv",
          issn: "2331-8422", // arXiv generic ISSN
          impactFactor: 5,
          field: "Multidisciplinary",
          paperCount: 0
        });
      }

      for (const p of arxivPapers) {
        const authorIds = [];
        for (const aName of p.authors) {
          const author = await Author.findOneAndUpdate(
            { fullName: aName },
            {
              $setOnInsert: {
                fullName: aName,
                email: "unknown@arxiv.org",
                affiliation: "arXiv Contributor",
                hIndex: Math.floor(Math.random() * 10),
              }
            },
            { upsert: true, new: true }
          );
          authorIds.push(author._id);
        }

        let paper = await Paper.findOne({ doi: p.doi });
        if (!paper) {
          paper = await Paper.create({
            title: p.title,
            abstract: p.abstract,
            doi: p.doi,
            url: p.url,
            publicationYear: p.year,
            citationCount: Math.floor(Math.random() * 10),
            authors: authorIds,
            journalId: arxivJournal._id,
            keywords: [], // arXiv doesn't give explicit concepts cleanly, so we leave empty
            source: "arxiv"
          });
          arxivJournal.paperCount += 1;
        }
        topicPapers.push(paper._id);
      }
      await arxivJournal.save();

      // --- 3. CREATE TOPIC ---
      console.log(`Creating Topic: ${query}...`);
      await Topic.create({
        name: `${query} Research Trends`,
        seedKeyword: query,
        analysisRunId: dummyAnalysisRunId,
        trendStatus: "emerging",
        isEmerging: true,
        papers: topicPapers
      });

      // --- 4. CREATE PUBLICATION TRENDS ---
      console.log(`Generating Publication Trends for keywords...`);
      const trends = [];
      for (const [kName, keyword] of keywordsMap.entries()) {
        for (let year = currentYear - 5; year <= currentYear; year++) {
          trends.push({
            keywordId: keyword._id,
            analysisRunId: dummyAnalysisRunId,
            year: year,
            paperCount: Math.floor(Math.random() * 50) + 10,
            growthRate: Math.random() * 20 - 5,
            isTrending: Math.random() > 0.5
          });
        }
      }
      if (trends.length > 0) {
        await PublicationTrend.insertMany(trends);
      }
      
      // Delay to respect API rate limits (crucial for arXiv)
      await delay(3000);
    }

    console.log("✅ Multi-Source Seeding completed successfully!");
    process.exit(0);
  } catch (error) {
    console.error("❌ Seeding failed:", error);
    process.exit(1);
  }
};

seedRealData();
