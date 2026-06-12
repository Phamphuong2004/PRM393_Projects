export declare class PublicationTrendService {
    static getAllTrends(page: number, limit: number): Promise<{
        trends: Omit<Omit<Omit<import("mongoose").Document<unknown, {}, import("../models/PublicationTrend").IPublicationTrend> & import("../models/PublicationTrend").IPublicationTrend & {
            _id: import("mongoose").Types.ObjectId;
        }, never>, never>, never>[];
        total: number;
        pages: number;
    }>;
    static getTrendingPublications(limit?: number): Promise<Omit<Omit<Omit<import("mongoose").Document<unknown, {}, import("../models/PublicationTrend").IPublicationTrend> & import("../models/PublicationTrend").IPublicationTrend & {
        _id: import("mongoose").Types.ObjectId;
    }, never>, never>, never>[]>;
    static getTrendById(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/PublicationTrend").IPublicationTrend> & import("../models/PublicationTrend").IPublicationTrend & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static createTrend(trendData: any): Promise<import("mongoose").Document<unknown, {}, import("../models/PublicationTrend").IPublicationTrend> & import("../models/PublicationTrend").IPublicationTrend & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static updateTrend(id: string, trendData: any): Promise<import("mongoose").Document<unknown, {}, import("../models/PublicationTrend").IPublicationTrend> & import("../models/PublicationTrend").IPublicationTrend & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static deleteTrend(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/PublicationTrend").IPublicationTrend> & import("../models/PublicationTrend").IPublicationTrend & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static getTrendsByKeyword(keywordId: string): Promise<Omit<Omit<Omit<import("mongoose").Document<unknown, {}, import("../models/PublicationTrend").IPublicationTrend> & import("../models/PublicationTrend").IPublicationTrend & {
        _id: import("mongoose").Types.ObjectId;
    }, never>, never>, never>[]>;
    static getTrendsByJournal(journalId: string): Promise<Omit<Omit<Omit<import("mongoose").Document<unknown, {}, import("../models/PublicationTrend").IPublicationTrend> & import("../models/PublicationTrend").IPublicationTrend & {
        _id: import("mongoose").Types.ObjectId;
    }, never>, never>, never>[]>;
    static getTrendsByYear(year: number): Promise<Omit<Omit<Omit<import("mongoose").Document<unknown, {}, import("../models/PublicationTrend").IPublicationTrend> & import("../models/PublicationTrend").IPublicationTrend & {
        _id: import("mongoose").Types.ObjectId;
    }, never>, never>, never>[]>;
    static getTrendsByYearRange(startYear: number, endYear: number): Promise<Omit<Omit<Omit<import("mongoose").Document<unknown, {}, import("../models/PublicationTrend").IPublicationTrend> & import("../models/PublicationTrend").IPublicationTrend & {
        _id: import("mongoose").Types.ObjectId;
    }, never>, never>, never>[]>;
    static getMonthlyTrends(keywordId: string, year: number): Promise<Omit<Omit<Omit<import("mongoose").Document<unknown, {}, import("../models/PublicationTrend").IPublicationTrend> & import("../models/PublicationTrend").IPublicationTrend & {
        _id: import("mongoose").Types.ObjectId;
    }, never>, never>, never>[]>;
    static analyzeTrendGrowth(keywordId: string, startYear: number, endYear: number): Promise<{
        keywordId: string;
        startYear: number;
        endYear: number;
        trends: {
            year: number;
            paperCount: number;
            growthRate: number;
        }[];
        overallGrowthRate: number;
    }>;
    static getAllPublicationTrends: typeof PublicationTrendService.getAllTrends;
    static getPublicationTrendById: typeof PublicationTrendService.getTrendById;
    static createPublicationTrend: typeof PublicationTrendService.createTrend;
    static updatePublicationTrend: typeof PublicationTrendService.updateTrend;
    static deletePublicationTrend: typeof PublicationTrendService.deleteTrend;
}
//# sourceMappingURL=PublicationTrendService.d.ts.map