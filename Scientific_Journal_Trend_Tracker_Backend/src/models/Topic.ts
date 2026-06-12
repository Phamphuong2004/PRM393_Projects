import mongoose, { Schema, Document } from "mongoose";

export interface ITopic extends Document {
  name: string;
  seedKeyword: string;
  analysisRunId: mongoose.Types.ObjectId;
  yearlyData: Map<string, number>;
  trendStatus: "emerging" | "growing" | "stable" | "declining";
  isEmerging: boolean;
  papers: mongoose.Types.ObjectId[];
}

const topicSchema = new Schema<ITopic>(
  {
    name: {
      type: String,
      required: true,
    },
    seedKeyword: String,
    analysisRunId: {
      type: Schema.Types.ObjectId,
      ref: "AnalysisRun",
      required: true,
    },
    yearlyData: {
      type: Map,
      of: Number,
    },
    trendStatus: {
      type: String,
      enum: ["emerging", "growing", "stable", "declining"],
      default: "stable",
    },
    isEmerging: {
      type: Boolean,
      default: false,
    },
    papers: [
      {
        type: Schema.Types.ObjectId,
        ref: "Paper",
      },
    ],
  },
  {
    timestamps: true,
  },
);

export default mongoose.model<ITopic>("Topic", topicSchema);
