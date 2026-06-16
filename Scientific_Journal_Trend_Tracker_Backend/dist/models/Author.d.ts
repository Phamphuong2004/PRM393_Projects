import mongoose, { Document } from "mongoose";
export interface IAuthor extends Document {
    fullName: string;
    externalAuthorId: string;
    affiliation: string;
    orcid: string;
    operalId: string;
    workCount: number;
}
declare const _default: mongoose.Model<IAuthor, {}, {}, {}, mongoose.Document<unknown, {}, IAuthor> & IAuthor & {
    _id: mongoose.Types.ObjectId;
}, any>;
export default _default;
//# sourceMappingURL=Author.d.ts.map