export declare class AnalysisRunService {
    static getAllAnalysisRuns(page: number, limit: number): Promise<{
        runs: Omit<Omit<Omit<import("mongoose").Document<unknown, {}, import("../models/AnalysisRun").IAnalysisRun> & import("../models/AnalysisRun").IAnalysisRun & {
            _id: import("mongoose").Types.ObjectId;
        }, never>, never>, never>[];
        total: number;
        pages: number;
    }>;
    static getAnalysisRunById(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/AnalysisRun").IAnalysisRun> & import("../models/AnalysisRun").IAnalysisRun & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static createAnalysisRun(runData: any): Promise<import("mongoose").Document<unknown, {}, import("../models/AnalysisRun").IAnalysisRun> & import("../models/AnalysisRun").IAnalysisRun & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static updateAnalysisRun(id: string, runData: any): Promise<import("mongoose").Document<unknown, {}, import("../models/AnalysisRun").IAnalysisRun> & import("../models/AnalysisRun").IAnalysisRun & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static deleteAnalysisRun(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/AnalysisRun").IAnalysisRun> & import("../models/AnalysisRun").IAnalysisRun & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static getAnalysisRunsByKeyword(keywordId: string): Promise<Omit<Omit<Omit<import("mongoose").Document<unknown, {}, import("../models/AnalysisRun").IAnalysisRun> & import("../models/AnalysisRun").IAnalysisRun & {
        _id: import("mongoose").Types.ObjectId;
    }, never>, never>, never>[]>;
    static getActiveAnalysisRuns(): Promise<Omit<Omit<Omit<import("mongoose").Document<unknown, {}, import("../models/AnalysisRun").IAnalysisRun> & import("../models/AnalysisRun").IAnalysisRun & {
        _id: import("mongoose").Types.ObjectId;
    }, never>, never>, never>[]>;
    static getCompletedAnalysisRuns(limit?: number): Promise<Omit<Omit<Omit<import("mongoose").Document<unknown, {}, import("../models/AnalysisRun").IAnalysisRun> & import("../models/AnalysisRun").IAnalysisRun & {
        _id: import("mongoose").Types.ObjectId;
    }, never>, never>, never>[]>;
    static startAnalysisRun(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/AnalysisRun").IAnalysisRun> & import("../models/AnalysisRun").IAnalysisRun & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static completeAnalysisRun(id: string, results: any): Promise<import("mongoose").Document<unknown, {}, import("../models/AnalysisRun").IAnalysisRun> & import("../models/AnalysisRun").IAnalysisRun & {
        _id: import("mongoose").Types.ObjectId;
    }>;
}
//# sourceMappingURL=AnalysisRunService.d.ts.map