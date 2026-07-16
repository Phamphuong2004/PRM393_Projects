import mongoose, { Schema, Document } from "mongoose";

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

const keywordSchema = new Schema<IKeyword>(
  {
    name: {
      type: String,
      required: true,
      unique: true,
    },
    normalizedText: String,
    openalexId: {
      type: String,
      unique: true,
      sparse: true,
    },
    workCount: {
      type: Number,
      default: 0,
    },
    embedding: [Number],
    topic: String,
    canonicalKeyword: String,
    aliases: [String],
    paperCount: {
      type: Number,
      default: 0,
    },
    citationCount: {
      type: Number,
      default: 0,
    },
    yearlyUsage: {
      type: Map,
      of: Number,
    },
    trendScore: Number,
    growthRate: Number,
    source: String,
  },
  {
    timestamps: true,
  },
);

export default mongoose.model<IKeyword>("Keyword", keywordSchema);
