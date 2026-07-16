import mongoose, { Schema, Document } from "mongoose";

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

const journalSchema = new Schema<IJournal>(
  {
    name: {
      type: String,
      required: true,
      unique: true,
    },
    issn: {
      type: String,
      unique: true,
      sparse: true,
    },
    publisher: String,
    impactFactor: Number,
    hIndex: Number,
    paperCount: {
      type: Number,
      default: 0,
    },
    fieldDomain: String,
    isTracked: {
      type: Boolean,
      default: true,
    },
    source: String,
    externalId: String,
    lastSyncedAt: Date,
  },
  {
    timestamps: true,
  },
);

export default mongoose.model<IJournal>("Journal", journalSchema);
