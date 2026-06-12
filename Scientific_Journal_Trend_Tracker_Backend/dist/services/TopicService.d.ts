export declare class TopicService {
    static getAllTopics(page: number, limit: number): Promise<{
        topics: Omit<Omit<import("mongoose").Document<unknown, {}, import("../models/Topic").ITopic> & import("../models/Topic").ITopic & {
            _id: import("mongoose").Types.ObjectId;
        }, never>, never>[];
        total: number;
        pages: number;
    }>;
    static getTopicById(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/Topic").ITopic> & import("../models/Topic").ITopic & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static createTopic(topicData: any): Promise<import("mongoose").Document<unknown, {}, import("../models/Topic").ITopic> & import("../models/Topic").ITopic & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static updateTopic(id: string, topicData: any): Promise<import("mongoose").Document<unknown, {}, import("../models/Topic").ITopic> & import("../models/Topic").ITopic & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static deleteTopic(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/Topic").ITopic> & import("../models/Topic").ITopic & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static getEmergingTopics(): Promise<Omit<Omit<import("mongoose").Document<unknown, {}, import("../models/Topic").ITopic> & import("../models/Topic").ITopic & {
        _id: import("mongoose").Types.ObjectId;
    }, never>, never>[]>;
    static analyzeTrendStatus(yearlyData: Map<string, number>): Promise<"emerging" | "growing" | "stable" | "declining">;
    static updateTrendStatus(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/Topic").ITopic> & import("../models/Topic").ITopic & {
        _id: import("mongoose").Types.ObjectId;
    }>;
}
//# sourceMappingURL=TopicService.d.ts.map