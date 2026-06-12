import mongoose, { Document } from "mongoose";
export interface IAnalysisRun extends Document {
    keywordId: mongoose.Types.ObjectId;
    syncLogId: mongoose.Types.ObjectId;
    seedKeyword: string;
    source: string;
    startYear: number;
    endYear: number;
    status: "pending" | "running" | "completed" | "failed";
    yearlyData: Map<string, number>;
    topicId: mongoose.Types.ObjectId;
}
declare const _default: mongoose.Model<IAnalysisRun, {}, {}, {}, mongoose.Document<unknown, {}, IAnalysisRun> & IAnalysisRun & {
    _id: mongoose.Types.ObjectId;
}, any>;
export default _default;
//# sourceMappingURL=AnalysisRun.d.ts.map