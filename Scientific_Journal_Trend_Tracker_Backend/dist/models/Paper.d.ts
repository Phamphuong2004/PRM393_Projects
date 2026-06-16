import mongoose, { Document } from "mongoose";
export interface IPaper extends Document {
    title: string;
    abstract: string;
    doi: string;
    url: string;
    publicationYear: number;
    publicationMonth?: number;
    publishedDate?: Date;
    citationCount: number;
    externalId_openalexId: string;
    externalId_semanticScholarId: string;
    externalId_crossref: string;
    authors: mongoose.Types.ObjectId[];
    journalId: mongoose.Types.ObjectId;
    keywords: mongoose.Types.ObjectId[];
    topics: mongoose.Types.ObjectId[];
    source: string;
    lastSyncedAt?: Date;
}
declare const _default: mongoose.Model<IPaper, {}, {}, {}, mongoose.Document<unknown, {}, IPaper> & IPaper & {
    _id: mongoose.Types.ObjectId;
}, any>;
export default _default;
//# sourceMappingURL=Paper.d.ts.map