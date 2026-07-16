import Paper from "../models/Paper";
import Author from "../models/Author";
import Journal from "../models/Journal";
import axios from "axios";

type PaperSearchSortField = "publicationYear" | "citationCount";

type PaperSearchSortDirection = 1 | -1;

function reconstructOpenAlexAbstract(invertedIndex: any): string | null {
  if (!invertedIndex) return null;
  const wordPositions: { word: string; pos: number }[] = [];
  for (const [word, positions] of Object.entries(invertedIndex)) {
    for (const pos of (positions as number[])) {
      wordPositions.push({ word, pos });
    }
  }
  wordPositions.sort((a, b) => a.pos - b.pos);
  return wordPositions.map(wp => wp.word).join(' ');
}

export class PaperService {
  static async getAllPapers(page: number, limit: number, year?: number, sortValue?: string) {
    const skip = (page - 1) * limit;

    const query: any = {};
    if (year) {
      query.publicationYear = year;
    }

    let sort: any = { publicationYear: -1 };
    if (sortValue && sortValue !== 'relevance') {
      const sortField = sortValue.replace(/^-/, "");
      const sortDirection = sortValue.startsWith("-") ? -1 : 1;
      const normalizedSortField = sortField === "citationCount" ? "citationCount" : "publicationYear";
      sort = { [normalizedSortField]: sortDirection };
    }

    const papers = await Paper.find(query)
      .populate(["authors", "journalId", "keywords"])
      .skip(skip)
      .limit(limit)
      .sort(sort);

    const total = await Paper.countDocuments(query);

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

  static async searchExternalPapers(query: string, limit: number = 10, source: string = "Semantic Scholar", page: number = 1, year?: number, sortValue?: string) {
    if (source === "OpenAlex") {
      try {
        const params: any = { search: query, "per-page": limit, page };
        if (year) params.filter = `publication_year:${year}`;
        if (sortValue && sortValue !== 'relevance') {
          if (sortValue === "-publicationYear") params.sort = "publication_year:desc";
          else if (sortValue === "publicationYear") params.sort = "publication_year:asc";
          else if (sortValue === "-citationCount") params.sort = "cited_by_count:desc";
          else if (sortValue === "citationCount") params.sort = "cited_by_count:asc";
        }

        const response = await axios.get(`https://api.openalex.org/works`, {
          params
        });
        
        const papers = response.data.results.map((item: any) => ({
          _id: item.id,
          title: item.title,
          abstract: reconstructOpenAlexAbstract(item.abstract_inverted_index),
          doi: item.doi?.replace('https://doi.org/', ''),
          url: item.doi || item.id,
          publicationYear: item.publication_year,
          citationCount: item.cited_by_count || 0,
          source: item.primary_location?.source?.display_name || "OpenAlex",
          externalId_openalexId: item.id,
          authors: item.authorships?.map((a: any) => ({ fullName: a.author.display_name })) || []
        }));
        
        return {
          papers,
          total: response.data.meta.count || papers.length,
          pages: Math.ceil((response.data.meta.count || papers.length) / limit)
        };
      } catch (error: any) {
        throw { status: 500, message: "Failed to fetch from OpenAlex: " + error.message };
      }
    } else if (source === "Crossref") {
      try {
        const params: any = { query, rows: limit, offset: (page - 1) * limit };
        if (year) params.filter = `from-pub-date:${year}-01-01,until-pub-date:${year}-12-31`;
        if (sortValue && sortValue !== 'relevance') {
          params.order = sortValue.startsWith("-") ? "desc" : "asc";
          if (sortValue.includes("publicationYear")) params.sort = "published";
          else if (sortValue.includes("citationCount")) params.sort = "is-referenced-by-count";
        }

        const response = await axios.get(`https://api.crossref.org/works`, {
          params
        });
        
        const items = response.data.message.items || [];
        const papers = items.map((item: any) => ({
          _id: item.DOI || Math.random().toString(),
          title: item.title?.[0] || "Unknown Title",
          abstract: item.abstract?.replace(/<[^>]*>?/gm, ''), // strip xml/html tags
          doi: item.DOI,
          url: item.URL,
          publicationYear: item.published?.["date-parts"]?.[0]?.[0] || item.created?.["date-parts"]?.[0]?.[0],
          citationCount: item["is-referenced-by-count"] || 0,
          source: item["container-title"]?.[0] || "Crossref",
          authors: item.author?.map((a: any) => ({ fullName: `${a.given || ''} ${a.family || ''}`.trim() })) || []
        }));
        
        return {
          papers,
          total: response.data.message["total-results"] || papers.length,
          pages: Math.ceil((response.data.message["total-results"] || papers.length) / limit)
        };
      } catch (error: any) {
        throw { status: 500, message: "Failed to fetch from Crossref: " + error.message };
      }
    } else if (source === "IEEE Xplore" || source === "Exa Research") {
       return { papers: [], total: 0, pages: 1 };
    }

    // Default: Semantic Scholar
    const apiKey = process.env.SEMANTIC_SCHOLAR_API_KEY;
    const maxRetries = 3;
    let delay = 1000;

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        const params: any = {
            query,
            limit,
            offset: (page - 1) * limit,
            fields: "title,abstract,url,year,externalIds,authors,citationCount,venue"
        };
        if (year) params.year = year;

        const response = await axios.get(`https://api.semanticscholar.org/graph/v1/paper/search`, {
          params,
          headers: {
            ...(apiKey && { "x-api-key": apiKey })
          },
          validateStatus: () => true
        });

        if (response.status === 429) {
          console.warn(`[Semantic Scholar API] 429 Too Many Requests (attempt ${attempt}/${maxRetries}). Retrying...`);
          const retryAfter = response.headers["retry-after"];
          const waitTime = retryAfter ? parseInt(retryAfter) * 1000 : delay;
          await new Promise(resolve => setTimeout(resolve, waitTime));
          delay *= 2;
          continue;
        }

        if (response.status !== 200) {
          throw { 
            status: response.status, 
            message: `External API error: ${response.data?.message || response.statusText || response.status}` 
          };
        }

        const rawData = response.data.data || [];
        const papers = rawData.map((item: any) => ({
          _id: item.paperId,
          title: item.title,
          abstract: item.abstract,
          doi: item.externalIds?.DOI,
          url: item.url,
          publicationYear: item.year,
          citationCount: item.citationCount || 0,
          source: item.venue || "Semantic Scholar",
          authors: item.authors?.map((a: any) => ({ fullName: a.name })) || []
        }));

        return {
          papers,
          total: response.data.total || papers.length,
          pages: Math.ceil((response.data.total || papers.length) / limit)
        };
      } catch (error: any) {
        if (error.status) throw error;
        
        if (attempt === maxRetries) {
          throw { status: 500, message: "Failed to fetch external papers: " + error.message };
        }
        
        console.warn(`[Semantic Scholar API] Error (attempt ${attempt}/${maxRetries}): ${error.message}. Retrying...`);
        await new Promise(resolve => setTimeout(resolve, delay));
        delay *= 2;
      }
    }
    
    throw { status: 429, message: "External API error: Too Many Requests (Rate limit exceeded after retries)" };
  }
}
