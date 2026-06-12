import mongoose, { Document } from "mongoose";
export interface TrackedRun {
    analysisRunId: mongoose.Types.ObjectId;
    notifyEnabled: boolean;
    followedAt: Date;
}
export interface Follow {
    targetType: "Keyword" | "Journal";
    targetId: mongoose.Types.ObjectId;
    notifyEnabled: boolean;
}
export interface IUser extends Document {
    email: string;
    password: string;
    fullName: string;
    role: "admin" | "researcher" | "user";
    institution?: string;
    bio?: string;
    interests: string[];
    avatar?: string;
    isActive: boolean;
    emailVerified: boolean;
    lastLogin?: Date;
    bookmarks: mongoose.Types.ObjectId[];
    trackedRuns: TrackedRun[];
    follows: Follow[];
    createdAt: Date;
    updatedAt: Date;
}
declare const _default: mongoose.Model<IUser, {}, {}, {}, mongoose.Document<unknown, {}, IUser> & IUser & {
    _id: mongoose.Types.ObjectId;
}, any>;
export default _default;
//# sourceMappingURL=User.d.ts.map