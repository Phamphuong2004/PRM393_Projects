import mongoose, { Schema, Document } from "mongoose";

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

const publicationTrendSchema = new Schema<IPublicationTrend>(
  {
    keywordId: {
      type: Schema.Types.ObjectId,
      ref: "Keyword",
      required: true,
    },
    journalId: {
      type: Schema.Types.ObjectId,
      ref: "Journal",
    },
    analysisRunId: {
      type: Schema.Types.ObjectId,
      ref: "AnalysisRun",
      required: true,
    },
    year: {
      type: Number,
      required: true,
    },
    month: Number,
    paperCount: {
      type: Number,
      required: true,
    },
    previousCount: Number,
    growthRate: {
      type: Number,
      required: true,
    },
    isTrending: {
      type: Boolean,
      default: false,
    },
    calculatedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  },
);

export default mongoose.model<IPublicationTrend>(
  "PublicationTrend",
  publicationTrendSchema,
);
