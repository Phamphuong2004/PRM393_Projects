import mongoose, { Schema, Document } from "mongoose";

export interface IWorkspaceAlert extends Document {
  workspace: mongoose.Types.ObjectId;
  query: string;
  frequency: "daily" | "weekly";
  notifyEnabled: boolean;
  createdBy: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const workspaceAlertSchema = new Schema<IWorkspaceAlert>(
  {
    workspace: { type: Schema.Types.ObjectId, ref: "Workspace", required: true },
    query: { type: String, required: true, trim: true },
    frequency: { type: String, enum: ["daily", "weekly"], default: "daily" },
    notifyEnabled: { type: Boolean, default: true },
    createdBy: { type: Schema.Types.ObjectId, ref: "user", required: true },
  },
  { timestamps: true }
);

export default mongoose.model<IWorkspaceAlert>("WorkspaceAlert", workspaceAlertSchema);
