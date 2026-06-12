export declare class UserService {
    static getAllUsers(page: number, limit: number): Promise<{
        users: (import("mongoose").Document<unknown, {}, import("../models/User").IUser> & import("../models/User").IUser & {
            _id: import("mongoose").Types.ObjectId;
        })[];
        total: number;
        pages: number;
    }>;
    static getUserById(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/User").IUser> & import("../models/User").IUser & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static updateUserProfile(id: string, userData: any, requestingUserId?: string, requestingUserRole?: string): Promise<import("mongoose").Document<unknown, {}, import("../models/User").IUser> & import("../models/User").IUser & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static deleteUser(id: string): Promise<import("mongoose").Document<unknown, {}, import("../models/User").IUser> & import("../models/User").IUser & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static changePassword(id: string, currentPassword: string, newPassword: string, requestingUserId?: string): Promise<{
        message: string;
    }>;
    static getUsersByRole(role: string): Promise<(import("mongoose").Document<unknown, {}, import("../models/User").IUser> & import("../models/User").IUser & {
        _id: import("mongoose").Types.ObjectId;
    })[]>;
    static getUserStats(id: string): Promise<{
        bookmarks: number;
        follows: number;
        trackedRuns: number;
        joinedAt: Date;
        lastLogin: Date | undefined;
    }>;
    static getActiveUsers(days?: number): Promise<(import("mongoose").Document<unknown, {}, import("../models/User").IUser> & import("../models/User").IUser & {
        _id: import("mongoose").Types.ObjectId;
    })[]>;
}
//# sourceMappingURL=UserService.d.ts.map