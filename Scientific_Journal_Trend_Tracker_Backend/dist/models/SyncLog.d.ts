import mongoose, { Document } from "mongoose";
export interface ISyncLog extends Document {
    apiSource: mongoose.Types.ObjectId;
    seedKeyword: string;
    startedAt: Date;
    finishedAt?: Date;
    papersAdded: number;
    papersSkipped: number;
    papersUpdated: number;
    status: "success" | "failed" | "running";
    errorMessage?: string;
}
declare const _default: mongoose.Model<ISyncLog, {}, {}, {}, mongoose.Document<unknown, {}, ISyncLog> & ISyncLog & {
    _id: mongoose.Types.ObjectId;
}, any>;
export default _default;
//# sourceMappingURL=SyncLog.d.ts.map