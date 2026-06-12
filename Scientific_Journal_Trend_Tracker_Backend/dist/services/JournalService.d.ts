export declare class JournalService {
    static getAllJournals(page: number, limit: number): Promise<{
        journals: (import("mongoose").Document<unknown, {}, import("../models/Journal").IJournal> & import("../models/Journal").IJournal & {
            _id: import("mongoose").Types.ObjectId;
        })[];
        total: number;
        pages: number;
    }>;
    static getJournalById(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/Journal").IJournal> & import("../models/Journal").IJournal & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static createJournal(journalData: any): Promise<import("mongoose").Document<unknown, {}, import("../models/Journal").IJournal> & import("../models/Journal").IJournal & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static updateJournal(id: string, journalData: any): Promise<import("mongoose").Document<unknown, {}, import("../models/Journal").IJournal> & import("../models/Journal").IJournal & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static deleteJournal(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/Journal").IJournal> & import("../models/Journal").IJournal & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static getJournalsByField(fieldDomain: string): Promise<(import("mongoose").Document<unknown, {}, import("../models/Journal").IJournal> & import("../models/Journal").IJournal & {
        _id: import("mongoose").Types.ObjectId;
    })[]>;
    static getTrackedJournals(): Promise<(import("mongoose").Document<unknown, {}, import("../models/Journal").IJournal> & import("../models/Journal").IJournal & {
        _id: import("mongoose").Types.ObjectId;
    })[]>;
    static getHighImpactJournals(minImpactFactor?: number): Promise<(import("mongoose").Document<unknown, {}, import("../models/Journal").IJournal> & import("../models/Journal").IJournal & {
        _id: import("mongoose").Types.ObjectId;
    })[]>;
}
//# sourceMappingURL=JournalService.d.ts.map