import mongoose, { Schema, Document } from "mongoose";

// Register dummy models to prevent MissingSchemaError on refs
if (!mongoose.models.Keyword) {
  mongoose.model("Keyword", new Schema({}));
}
if (!mongoose.models.SyncLog) {
  mongoose.model("SyncLog", new Schema({}));
}
if (!mongoose.models.Topic) {
  mongoose.model("Topic", new Schema({}));
}

export interface IAnalysisRun extends Document {
  keywordId: mongoose.Types.ObjectId;
  syncLogId: mongoose.Types.ObjectId;
  seedKeyword: string;
  source: string;
  startYear: number;
  endYear: number;
  status: "pending" | "running" | "completed" | "failed";
  yearlyData: Map<string, number>;
  topicId: mongoose.Types.ObjectId;
}

const analysisRunSchema = new Schema<IAnalysisRun>(
  {
    keywordId: {
      type: Schema.Types.ObjectId,
      ref: "Keyword",
      required: false,
    },
    syncLogId: {
      type: Schema.Types.ObjectId,
      ref: "SyncLog",
    },
    seedKeyword: String,
    source: String,
    startYear: Number,
    endYear: Number,
    status: {
      type: String,
      enum: ["pending", "running", "completed", "failed"],
      default: "pending",
    },
    yearlyData: {
      type: Map,
      of: Number,
    },
    topicId: {
      type: Schema.Types.ObjectId,
      ref: "Topic",
    },
  },
  {
    timestamps: true,
  },
);

export default mongoose.model<IAnalysisRun>("AnalysisRun", analysisRunSchema);
