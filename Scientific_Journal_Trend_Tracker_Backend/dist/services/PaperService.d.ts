export declare class PaperService {
    static getAllPapers(page: number, limit: number): Promise<{
        papers: Omit<import("mongoose").Document<unknown, {}, import("../models").IPaper> & import("../models").IPaper & {
            _id: import("mongoose").Types.ObjectId;
        }, never>[];
        total: number;
        pages: number;
    }>;
    static getPaperById(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models").IPaper> & import("../models").IPaper & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static createPaper(paperData: any): Promise<import("mongoose").Document<unknown, {}, import("../models").IPaper> & import("../models").IPaper & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static updatePaper(id: string, paperData: any): Promise<import("mongoose").Document<unknown, {}, import("../models").IPaper> & import("../models").IPaper & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static deletePaper(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models").IPaper> & import("../models").IPaper & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static searchPapers(query: string, year?: number, journalId?: string): Promise<Omit<import("mongoose").Document<unknown, {}, import("../models").IPaper> & import("../models").IPaper & {
        _id: import("mongoose").Types.ObjectId;
    }, never>[]>;
    static getPapersByCitation(minCitations: number): Promise<Omit<import("mongoose").Document<unknown, {}, import("../models").IPaper> & import("../models").IPaper & {
        _id: import("mongoose").Types.ObjectId;
    }, never>[]>;
    static getPapersByKeyword(keywordId: string): Promise<Omit<import("mongoose").Document<unknown, {}, import("../models").IPaper> & import("../models").IPaper & {
        _id: import("mongoose").Types.ObjectId;
    }, never>[]>;
}
//# sourceMappingURL=PaperService.d.ts.map