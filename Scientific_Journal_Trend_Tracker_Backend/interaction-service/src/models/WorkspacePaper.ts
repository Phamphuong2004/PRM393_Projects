import mongoose, { Schema, Document } from "mongoose";

export interface IWorkspacePaper extends Document {
  workspace: mongoose.Types.ObjectId;
  paper: mongoose.Types.ObjectId;
  tags: string[];
  note?: string;
  source: string;
  pdfUrl?: string;
  addedBy: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const workspacePaperSchema = new Schema<IWorkspacePaper>(
  {
    workspace: { type: Schema.Types.ObjectId, ref: "Workspace", required: true },
    paper: { type: Schema.Types.ObjectId, ref: "Paper", required: true },
    tags: [{ type: String, trim: true }],
    note: { type: String, trim: true },
    source: { type: String, default: "manual" },
    pdfUrl: { type: String },
    addedBy: { type: Schema.Types.ObjectId, ref: "user", required: true },
  },
  { timestamps: true }
);

workspacePaperSchema.index({ workspace: 1, paper: 1 }, { unique: true });

export default mongoose.model<IWorkspacePaper>("WorkspacePaper", workspacePaperSchema);
