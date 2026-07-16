import { Request, Response } from "express";
import { validationResult } from "express-validator";
import Paper from "../models/Paper";
import Author from "../models/Author";
import Journal from "../models/Journal";
// User import removed

export class PaperController {
  static async getAllPapers(req: Request, res: Response): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const skip = (page - 1) * limit;

      const papers = await Paper.find()
        .populate("authors")
        .populate("journalId")
        .populate("keywords")
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 });

      const total = await Paper.countDocuments();

      res.json({
        papers,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit),
        },
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getPaperById(req: Request, res: Response): Promise<void> {
    try {
      const paper = await Paper.findById(req.params.id)
        .populate("authors")
        .populate("journalId")
        .populate("keywords")
        .populate("topics");

      if (!paper) {
        res.status(404).json({ message: "Paper not found" });
        return;
      }

      res.json(paper);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async getPapersBatch(req: Request, res: Response): Promise<void> {
    try {
      const { ids } = req.body;
      if (!ids || !Array.isArray(ids)) {
        res.status(400).json({ message: "An array of ids is required" });
        return;
      }

      const papers = await Paper.find({ _id: { $in: ids } })
        .populate("authors")
        .populate("journalId")
        .populate("keywords")
        .populate("topics");

      res.json(papers);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async createPaper(req: Request, res: Response): Promise<void> {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({ errors: errors.array() });
        return;
      }

      const paper = new Paper(req.body);
      await paper.save();
      await paper.populate(["authors", "journalId", "keywords"]);

      res.status(201).json(paper);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async updatePaper(req: Request, res: Response): Promise<void> {
    try {
      const paper = await Paper.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
      }).populate(["authors", "journalId", "keywords"]);

      if (!paper) {
        res.status(404).json({ message: "Paper not found" });
        return;
      }

      res.json(paper);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async deletePaper(req: Request, res: Response): Promise<void> {
    try {
      const paper = await Paper.findByIdAndDelete(req.params.id);

      if (!paper) {
        res.status(404).json({ message: "Paper not found" });
        return;
      }

      res.json({ message: "Paper deleted" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async searchPapers(req: Request, res: Response): Promise<void> {
    try {
      const { q, year, journalId } = req.query;
      const query: any = {};

      if (q) {
        query.$or = [
          { title: { $regex: q, $options: "i" } },
          { abstract: { $regex: q, $options: "i" } },
        ];
      }

      if (year) {
        query.publicationYear = year;
      }

      if (journalId) {
        query.journalId = journalId;
      }

      const papers = await Paper.find(query)
        .populate("authors")
        .populate("journalId")
        .limit(50);

      res.json(papers);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Server error" });
    }
  }

  static async importExternalPaper(req: Request, res: Response): Promise<void> {
    try {
      const item = req.body;
      const doi = item.doi;
      let paper = null;
      if (doi) {
        paper = await Paper.findOne({ doi });
      }

      const openalexId = item.externalId_openalexId || item.externalIdOpenalexId || (item._id && String(item._id).startsWith("https://openalex.org/") ? item._id : null);

      if (!paper) {
        if (openalexId) {
          paper = await Paper.findOne({
            $or: [
              { externalId_openalexId: openalexId },
              { externalId_semanticScholarId: openalexId }
            ]
          });
        } else if (item._id) {
          paper = await Paper.findOne({
            $or: [
              { externalId_semanticScholarId: item._id },
              { externalId_crossref: item._id }
            ]
          });
        }
      }

      if (!paper) {
        // Process Journal (Venue)
        let journalId = null;
        if (item.source) {
          let journal = await Journal.findOne({ name: item.source });
          if (!journal) {
            journal = new Journal({ name: item.source, source: "Import" });
            await journal.save();
          }
          journalId = journal._id;
        }

        // Process Authors
        const authorIds = [];
        if (item.authors && Array.isArray(item.authors)) {
          for (const a of item.authors) {
            const authorName = a.fullName || a.name;
            if (!authorName) continue;
            let author = null;
            if (a.id || a.externalAuthorId) {
              author = await Author.findOne({ externalAuthorId: a.id || a.externalAuthorId });
            }
            if (!author) {
              author = await Author.findOne({ fullName: authorName });
            }
            if (!author) {
              const newAuthorData: any = {
                fullName: authorName,
              };
              const extId = a.id || a.externalAuthorId;
              if (extId) {
                newAuthorData.externalAuthorId = extId;
              }
              author = new Author(newAuthorData);
              await author.save();
            }
            authorIds.push(author._id);
          }
        }

        const paperData: any = {
          title: item.title,
          abstract: item.abstract,
          url: item.url,
          publicationYear: item.publicationYear || item.year,
          citationCount: item.citationCount || 0,
          authors: authorIds,
          ...(journalId && { journalId }),
          source: item.source || "External",
          lastSyncedAt: new Date()
        };
        if (doi) paperData.doi = doi;

        paper = new Paper(paperData);

        if (openalexId) {
          paper.externalId_openalexId = openalexId;
        } else if (item._id) {
          if (String(item._id).startsWith("http")) {
            paper.externalId_crossref = item._id;
          } else {
            paper.externalId_semanticScholarId = item._id;
          }
        }

        await paper.save();
      }

      // Add to bookmarks if userId is provided in req.user
      const userId = (req as any).userId || (req as any).user?.id;
      if (userId) {
        // Automatically bookmark the imported paper for the user via internal API call
        try {
          const axios = require("axios");
          const AUTH_SERVICE_URL = process.env.AUTH_SERVICE_URL || "http://auth-service:5001";
          await axios.post(`${AUTH_SERVICE_URL}/api/bookmarks/${paper._id}`, {}, {
            headers: {
              Authorization: req.headers.authorization
            }
          });
        } catch (bookmarkErr: any) {
          console.error("Failed to bookmark imported paper via Auth Service", bookmarkErr.message);
        }
      }

      // Populate authors, journalId, and keywords so frontend receives complete, structured data
      await paper.populate(["authors", "journalId", "keywords"]);

      res.status(201).json(paper);
    } catch (error: any) {
      console.error(error);
      res.status(500).json({ message: "Server error during import", details: error.message || String(error) });
    }
  }
}
