"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createApiClient = exports.ExternalApiClient = void 0;
const axios_1 = __importDefault(require("axios"));
class ExternalApiClient {
    constructor(baseURL, apiKey) {
        this.client = axios_1.default.create({
            baseURL,
            timeout: parseInt(process.env.EXTERNAL_API_TIMEOUT || "5000"),
            headers: {
                "User-Agent": "Scientific-Journal-Tracker/1.0",
                ...(apiKey && { Authorization: `Bearer ${apiKey}` }),
            },
        });
    }
    async searchPapers(query, limit = 50) {
        try {
            const response = await this.client.get("/search", {
                params: { query, limit },
            });
            return response.data;
        }
        catch (error) {
            console.error("External API search error:", error);
            throw error;
        }
    }
    async getPaperDetails(paperId) {
        try {
            const response = await this.client.get(`/papers/${paperId}`);
            return response.data;
        }
        catch (error) {
            console.error("External API details error:", error);
            throw error;
        }
    }
    async getAuthorInfo(authorId) {
        try {
            const response = await this.client.get(`/authors/${authorId}`);
            return response.data;
        }
        catch (error) {
            console.error("External API author error:", error);
            throw error;
        }
    }
}
exports.ExternalApiClient = ExternalApiClient;
const createApiClient = (source, apiKey) => {
    const baseURLs = {
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
exports.createApiClient = createApiClient;
//# sourceMappingURL=apiClient.js.map