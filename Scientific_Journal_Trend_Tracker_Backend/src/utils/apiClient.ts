import axios, { AxiosInstance } from "axios";

export class ExternalApiClient {
  private client: AxiosInstance;

  constructor(baseURL: string, apiKey?: string) {
    this.client = axios.create({
      baseURL,
      timeout: parseInt(process.env.EXTERNAL_API_TIMEOUT || "5000"),
      headers: {
        "User-Agent": "Scientific-Journal-Tracker/1.0",
        ...(apiKey && { Authorization: `Bearer ${apiKey}` }),
      },
    });
  }

  async searchPapers(query: string, limit = 50) {
    try {
      const response = await this.client.get("/search", {
        params: { query, limit },
      });
      return response.data;
    } catch (error) {
      console.error("External API search error:", error);
      throw error;
    }
  }

  async getPaperDetails(paperId: string) {
    try {
      const response = await this.client.get(`/papers/${paperId}`);
      return response.data;
    } catch (error) {
      console.error("External API details error:", error);
      throw error;
    }
  }

  async getAuthorInfo(authorId: string) {
    try {
      const response = await this.client.get(`/authors/${authorId}`);
      return response.data;
    } catch (error) {
      console.error("External API author error:", error);
      throw error;
    }
  }
}

export const createApiClient = (source: string, apiKey?: string) => {
  const baseURLs: Record<string, string> = {
    openalexo: "https://api.openalex.org/v1",
    semanticscholar: "https://api.semanticscholar.org/graph/v1",
    crossref: "https://api.crossref.org/v1",
  };

  const baseURL = baseURLs[source.toLowerCase()];
  if (!baseURL) {
    throw new Error(`Unknown API source: ${source}`);
  }

  return new ExternalApiClient(baseURL, apiKey);
};
