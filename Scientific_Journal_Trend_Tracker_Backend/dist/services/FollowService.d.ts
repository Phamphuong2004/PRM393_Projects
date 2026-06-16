export declare class FollowService {
    static getUserFollows(userId: string): Promise<import("../models/User").Follow[]>;
    static addFollow(userId: string, targetType: "Keyword" | "Journal", targetId: string, notifyEnabled?: boolean): Promise<{
        message: string;
        follows: import("../models/User").Follow[];
    }>;
    static removeFollow(userId: string, targetId: string): Promise<{
        message: string;
        follows: import("../models/User").Follow[];
    }>;
    static checkIfFollowing(userId: string, targetType: string, targetId: string): Promise<{
        isFollowing: boolean;
    }>;
    static getTrackedRuns(userId: string): Promise<import("../models/User").TrackedRun[]>;
    static trackAnalysisRun(userId: string, analysisRunId: string, notifyEnabled?: boolean): Promise<{
        message: string;
        trackedRuns: import("../models/User").TrackedRun[];
    }>;
    static untrackAnalysisRun(userId: string, analysisRunId: string): Promise<{
        message: string;
        trackedRuns: import("../models/User").TrackedRun[];
    }>;
    static updateTrackedRunNotification(userId: string, analysisRunId: string, notifyEnabled: boolean): Promise<{
        message: string;
        trackedRuns: import("../models/User").TrackedRun[];
    }>;
    static getFollowStats(userId: string): Promise<{
        totalFollows: number;
        keywordFollows: number;
        journalFollows: number;
        trackedRuns: number;
    }>;
}
//# sourceMappingURL=FollowService.d.ts.map