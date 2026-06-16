export declare class ExternalApiClient {
    private client;
    constructor(baseURL: string, apiKey?: string);
    searchPapers(query: string, limit?: number): Promise<any>;
    getPaperDetails(paperId: string): Promise<any>;
    getAuthorInfo(authorId: string): Promise<any>;
}
export declare const createApiClient: (source: string, apiKey?: string) => ExternalApiClient;
//# sourceMappingURL=apiClient.d.ts.map