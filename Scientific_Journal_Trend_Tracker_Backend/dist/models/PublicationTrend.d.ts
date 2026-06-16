import mongoose, { Document } from "mongoose";
export interface IPublicationTrend extends Document {
    keywordId: mongoose.Types.ObjectId;
    journalId?: mongoose.Types.ObjectId;
    analysisRunId: mongoose.Types.ObjectId;
    year: number;
    month?: number;
    paperCount: number;
    previousCount?: number;
    growthRate: number;
    isTrending: boolean;
    calculatedAt: Date;
    createdAt: Date;
    updatedAt: Date;
}
declare const _default: mongoose.Model<IPublicationTrend, {}, {}, {}, mongoose.Document<unknown, {}, IPublicationTrend> & IPublicationTrend & {
    _id: mongoose.Types.ObjectId;
}, any>;
export default _default;
//# sourceMappingURL=PublicationTrend.d.ts.map