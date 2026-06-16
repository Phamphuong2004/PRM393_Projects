import { Paper, Author, Journal, Keyword, Topic } from "../models";

type PaperSearchSortField = "publicationYear" | "citationCount";

type PaperSearchSortDirection = 1 | -1;

export class PaperService {
  static async getAllPapers(page: number, limit: number) {
    const skip = (page - 1) * limit;

    const papers = await Paper.find()
      .populate(["authors", "journalId", "keywords"])
      .skip(skip)
      .limit(limit)
      .sort({ publicationYear: -1 });

    const total = await Paper.countDocuments();

    return {
      papers,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  static async getPaperById(id: string) {
    const paper = await Paper.findById(id).populate([
      "authors",
      "journalId",
      "keywords",
    ]);

    if (!paper) {
      throw { status: 404, message: "Paper not found" };
    }

    return paper;
  }

  static async createPaper(paperData: any) {
    const paper = new Paper(paperData);
    await paper.save();
    await paper.populate(["authors", "journalId", "keywords"]);
    return paper;
  }

  static async updatePaper(id: string, paperData: any) {
    const paper = await Paper.findByIdAndUpdate(id, paperData, {
      new: true,
    }).populate(["authors", "journalId", "keywords"]);

    if (!paper) {
      throw { status: 404, message: "Paper not found" };
    }

    return paper;
  }

  static async deletePaper(id: string) {
    const paper = await Paper.findByIdAndDelete(id);

    if (!paper) {
      throw { status: 404, message: "Paper not found" };
    }

    return paper;
  }

  static async searchPapers(
    query: string,
    year?: number,
    journalId?: string,
    page: number = 1,
    limit: number = 10,
    sortField: PaperSearchSortField = "publicationYear",
    sortDirection: PaperSearchSortDirection = -1,
  ) {
    const skip = (page - 1) * limit;
    const searchCriteria: any[] = [
      { title: { $regex: query, $options: "i" } },
      { abstract: { $regex: query, $options: "i" } },
    ];

    const [matchedAuthors, matchedJournals] = await Promise.all([
      Author.find({ fullName: { $regex: query, $options: "i" } }).select("_id"),
      Journal.find({ name: { $regex: query, $options: "i" } }).select("_id"),
    ]);

    if (matchedAuthors.length > 0) {
      searchCriteria.push({
        authors: { $in: matchedAuthors.map((author) => author._id) },
      });
    }

    if (matchedJournals.length > 0) {
      searchCriteria.push({
        journalId: { $in: matchedJournals.map((journal) => journal._id) },
      });
    }

    const searchQuery: any = { $or: searchCriteria };

    if (year) {
      searchQuery.publicationYear = year;
    }

    if (journalId) {
      searchQuery.journalId = journalId;
    }

    const sort: Record<string, PaperSearchSortDirection> = {
      [sortField]: sortDirection,
    };

    const [papers, total] = await Promise.all([
      Paper.find(searchQuery)
        .populate(["authors", "journalId", "keywords"])
        .sort(sort)
        .skip(skip)
        .limit(limit),
      Paper.countDocuments(searchQuery),
    ]);

    return {
      papers,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  static async getPapersByCitation(minCitations: number) {
    const papers = await Paper.find({
      citationCount: { $gte: minCitations },
    })
      .populate(["authors", "journalId", "keywords"])
      .sort({ citationCount: -1 });

    return papers;
  }

  static async getPapersByKeyword(keywordId: string) {
    const papers = await Paper.find({
      keywords: keywordId,
    })
      .populate(["authors", "journalId", "keywords"])
      .sort({ publicationYear: -1 });

    return papers;
  }
}
