import mongoose, { Document } from "mongoose";
export interface ITopic extends Document {
    name: string;
    seedKeyword: string;
    analysisRunId: mongoose.Types.ObjectId;
    yearlyData: Map<string, number>;
    trendStatus: "emerging" | "growing" | "stable" | "declining";
    isEmerging: boolean;
    papers: mongoose.Types.ObjectId[];
}
declare const _default: mongoose.Model<ITopic, {}, {}, {}, mongoose.Document<unknown, {}, ITopic> & ITopic & {
    _id: mongoose.Types.ObjectId;
}, any>;
export default _default;
//# sourceMappingURL=Topic.d.ts.map