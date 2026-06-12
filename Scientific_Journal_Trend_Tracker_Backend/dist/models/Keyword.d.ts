import mongoose, { Document } from "mongoose";
export interface IKeyword extends Document {
    name: string;
    normalizedText: string;
    openalexId: string;
    workCount: number;
    embedding?: number[];
    topic: string;
    canonicalKeyword: string;
    aliases: string[];
    paperCount: number;
    citationCount: number;
    yearlyUsage: Map<string, number>;
    trendScore: number;
    growthRate: number;
    source: string;
}
declare const _default: mongoose.Model<IKeyword, {}, {}, {}, mongoose.Document<unknown, {}, IKeyword> & IKeyword & {
    _id: mongoose.Types.ObjectId;
}, any>;
export default _default;
//# sourceMappingURL=Keyword.d.ts.map