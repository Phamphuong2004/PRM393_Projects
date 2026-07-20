import mongoose, { Schema, Document } from "mongoose";

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

const apiSourceSchema = new Schema<IApiSource>(
  {
    name: {
      type: String,
      required: true,
      unique: true,
    },
    baseUrl: {
      type: String,
    },
    apiKeyHash: String,
    fieldScope: String,
    syncFrequency: Number,
    trendingThreshold: Number,
    minPaperCount: Number,
    isActive: {
      type: Boolean,
      default: true,
    },
    lastSyncedAt: Date,
  },
  {
    timestamps: true,
  },
);

export default mongoose.model<IApiSource>("ApiSource", apiSourceSchema);
