export declare class KeywordService {
    static getAllKeywords(page: number, limit: number, sort?: string): Promise<{
        keywords: (import("mongoose").Document<unknown, {}, import("../models/Keyword").IKeyword> & import("../models/Keyword").IKeyword & {
            _id: import("mongoose").Types.ObjectId;
        })[];
        total: number;
        pages: number;
    }>;
    static getKeywordById(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/Keyword").IKeyword> & import("../models/Keyword").IKeyword & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static createKeyword(keywordData: any): Promise<import("mongoose").Document<unknown, {}, import("../models/Keyword").IKeyword> & import("../models/Keyword").IKeyword & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static updateKeyword(id: string, keywordData: any): Promise<import("mongoose").Document<unknown, {}, import("../models/Keyword").IKeyword> & import("../models/Keyword").IKeyword & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static deleteKeyword(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/Keyword").IKeyword> & import("../models/Keyword").IKeyword & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static getTrendingKeywords(limit?: number): Promise<(import("mongoose").Document<unknown, {}, import("../models/Keyword").IKeyword> & import("../models/Keyword").IKeyword & {
        _id: import("mongoose").Types.ObjectId;
    })[]>;
    static getKeywordsByTopic(topicId: string): Promise<(import("mongoose").Document<unknown, {}, import("../models/Keyword").IKeyword> & import("../models/Keyword").IKeyword & {
        _id: import("mongoose").Types.ObjectId;
    })[]>;
    static normalizeKeyword(text: string): Promise<string>;
    static calculateTrendMetrics(keyword: any): Promise<{
        trendScore: number;
        growthRate: number;
    }>;
}
//# sourceMappingURL=KeywordService.d.ts.map