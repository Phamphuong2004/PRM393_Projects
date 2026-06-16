import mongoose, { Document } from "mongoose";
export interface IJournal extends Document {
    name: string;
    issn: string;
    publisher: string;
    impactFactor: number;
    hIndex: number;
    paperCount: number;
    fieldDomain: string;
    isTracked: boolean;
    source: string;
    externalId: string;
    lastSyncedAt?: Date;
}
declare const _default: mongoose.Model<IJournal, {}, {}, {}, mongoose.Document<unknown, {}, IJournal> & IJournal & {
    _id: mongoose.Types.ObjectId;
}, any>;
export default _default;
//# sourceMappingURL=Journal.d.ts.map