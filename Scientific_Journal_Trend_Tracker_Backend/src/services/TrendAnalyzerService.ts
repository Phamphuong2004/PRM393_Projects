import axios from "axios";
import Paper from "../models/Paper";
import { IKeyword } from "../models/Keyword";

export class TrendAnalyzerService {
  static async analyzeRelatedKeywords(keyword: string, source: string, startYear: number = 2018) {
    if (source === "OpenAlex") {
      return this.analyzeFromOpenAlex(keyword, startYear);
    } else {
      return this.analyzeFromLocal(keyword, startYear);
    }
  }

  static async analyzeFromOpenAlex(keyword: string, startYear: number) {
    try {
      // Step 1: Get top 10 related keywords
      const groupRes = await axios.get(`https://api.openalex.org/works`, {
        params: {
          search: keyword,
          group_by: "keywords.id",
          per_page: 15,
        }
      });

      let topKeywords = groupRes.data.group_by
        .filter((item: any) => item.key_display_name.toLowerCase() !== keyword.toLowerCase())
        .slice(0, 10)
        .map((item: any) => ({
          id: item.key,
          keyword: item.key_display_name,
          total: item.count,
        }));

      // Step 2: Fetch yearly trends for each keyword
      const promises = topKeywords.map((kw: any) =>
        axios.get(`https://api.openalex.org/works`, {
          params: {
            search: keyword,
            filter: `keywords.id:${kw.id}`,
            group_by: "publication_year",
          }
        }).then(res => ({
          keyword: kw.keyword,
          yearlyCounts: res.data.group_by,
        }))
      );

      const yearlyResults = await Promise.all(promises);

      // Fetch top 100 extracted publications for reference
      const papersRes = await axios.get(`https://api.openalex.org/works`, {
        params: {
          search: keyword,
          sort: "cited_by_count:desc",
          per_page: 100,
        }
      });

      const extractedPublications = papersRes.data.results.map((item: any) => ({
        _id: item.id,
        title: item.title,
        publicationYear: item.publication_year,
        citationCount: item.cited_by_count || 0,
        authors: item.authorships?.map((a: any) => ({ fullName: a.author.display_name })) || [],
        url: item.doi || item.id,
      }));

      // Step 3: Format the data as [{ year: 2020, key1: 5, key2: 10 }]
      const trendsMap: { [year: number]: any } = {};
      const currentYear = new Date().getFullYear();

      for (let y = startYear; y <= currentYear; y++) {
        trendsMap[y] = { year: y };
        topKeywords.forEach((kw: any) => {
          trendsMap[y][kw.keyword] = 0;
        });
      }

      yearlyResults.forEach((result: any) => {
        result.yearlyCounts.forEach((yc: any) => {
          const year = parseInt(yc.key);
          if (year >= startYear && year <= currentYear) {
            if (!trendsMap[year]) {
              trendsMap[year] = { year };
            }
            trendsMap[year][result.keyword] = yc.count;
          }
        });
      });

      return {
        topKeywords: topKeywords.map((k: any) => ({ keyword: k.keyword })),
        trends: Object.values(trendsMap).sort((a: any, b: any) => a.year - b.year),
        extractedPublications,
      };

    } catch (error: any) {
      console.error("OpenAlex Analysis Error:", error.message);
      throw { status: 500, message: "Failed to analyze from OpenAlex" };
    }
  }

  static async analyzeFromLocal(keyword: string, startYear: number) {
    try {
      // Step 1: Query local papers
      const papers = await Paper.find({
        $or: [
          { title: new RegExp(keyword, "i") },
          { abstract: new RegExp(keyword, "i") }
        ]
      })
      .populate("authors")
      .populate<{ keywords: IKeyword[] }>("keywords")
      .sort({ citationCount: -1 })
      .limit(100); // Fetch top 100 most cited

      // Step 2: Count related keywords
      const keywordFreq: { [name: string]: number } = {};
      
      papers.forEach(p => {
        if (!p.keywords) return;
        p.keywords.forEach(kw => {
          const kwName = kw.name;
          if (kwName.toLowerCase() !== keyword.toLowerCase()) {
            keywordFreq[kwName] = (keywordFreq[kwName] || 0) + 1;
          }
        });
      });

      // Get Top 10
      const topKeywords = Object.entries(keywordFreq)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 10)
        .map(([name, count]) => ({ keyword: name }));

      const topKeywordNames = topKeywords.map(k => k.keyword);

      // Step 3: Compute trend per year
      const trendsMap: { [year: number]: any } = {};
      const currentYear = new Date().getFullYear();

      for (let y = startYear; y <= currentYear; y++) {
        trendsMap[y] = { year: y };
        topKeywordNames.forEach(name => {
          trendsMap[y][name] = 0;
        });
      }

      papers.forEach(p => {
        const year = p.publicationYear;
        if (year && year >= startYear && year <= currentYear) {
          if (!trendsMap[year]) trendsMap[year] = { year };
          if (p.keywords) {
            p.keywords.forEach(kw => {
              if (topKeywordNames.includes(kw.name)) {
                trendsMap[year][kw.name] = (trendsMap[year][kw.name] || 0) + 1;
              }
            });
          }
        }
      });

      const extractedPublications = papers.map(p => ({
        _id: p._id,
        title: p.title,
        publicationYear: p.publicationYear,
        citationCount: p.citationCount,
        authors: p.authors || [],
        url: p.url,
      }));

      return {
        topKeywords,
        trends: Object.values(trendsMap).sort((a: any, b: any) => a.year - b.year),
        extractedPublications,
      };

    } catch (error: any) {
      console.error("Local Analysis Error:", error.message);
      throw { status: 500, message: "Failed to analyze from local database" };
    }
  }
}
