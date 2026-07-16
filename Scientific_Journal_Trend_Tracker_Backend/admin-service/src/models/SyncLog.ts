import mongoose, { Schema, Document } from "mongoose";

export interface ISyncLog extends Document {
  apiSource: mongoose.Types.ObjectId;
  seedKeyword: string;
  startedAt: Date;
  finishedAt?: Date;
  papersAdded: number;
  papersSkipped: number;
  papersUpdated: number;
  status: "success" | "failed" | "running";
  errorMessage?: string;
}

const syncLogSchema = new Schema<ISyncLog>(
  {
    apiSource: {
      type: Schema.Types.ObjectId,
      ref: "ApiSource",
      required: true,
    },
    seedKeyword: String,
    startedAt: {
      type: Date,
      default: Date.now,
    },
    finishedAt: Date,
    papersAdded: {
      type: Number,
      default: 0,
    },
    papersSkipped: {
      type: Number,
      default: 0,
    },
    papersUpdated: {
      type: Number,
      default: 0,
    },
    status: {
      type: String,
      enum: ["success", "failed", "running"],
      default: "running",
    },
    errorMessage: String,
  },
  {
    timestamps: true,
  },
);

export default mongoose.model<ISyncLog>("SyncLog", syncLogSchema);
