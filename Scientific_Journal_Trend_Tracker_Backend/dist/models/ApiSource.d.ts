import mongoose, { Document } from "mongoose";
export interface IApiSource extends Document {
    name: string;
    baseUrl: string;
    apiKeyHash: string;
    fieldScope: string;
    syncFrequency: number;
    trendingThreshold: number;
    minPaperCount: number;
    isActive: boolean;
    lastSyncedAt?: Date;
}
declare const _default: mongoose.Model<IApiSource, {}, {}, {}, mongoose.Document<unknown, {}, IApiSource> & IApiSource & {
    _id: mongoose.Types.ObjectId;
}, any>;
export default _default;
//# sourceMappingURL=ApiSource.d.ts.map