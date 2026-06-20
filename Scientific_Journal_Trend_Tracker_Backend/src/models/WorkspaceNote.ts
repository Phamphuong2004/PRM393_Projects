import mongoose, { Schema, Document } from "mongoose";

export interface IWorkspaceNote extends Document {
  workspace: mongoose.Types.ObjectId;
  paper?: mongoose.Types.ObjectId;
  title: string;
  content: string;
  tags: string[];
  createdBy: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const workspaceNoteSchema = new Schema<IWorkspaceNote>(
  {
    workspace: { type: Schema.Types.ObjectId, ref: "Workspace", required: true },
    paper: { type: Schema.Types.ObjectId, ref: "Paper" },
    title: { type: String, required: true, trim: true },
    content: { type: String, required: true },
    tags: [{ type: String, trim: true }],
    createdBy: { type: Schema.Types.ObjectId, ref: "user", required: true },
  },
  { timestamps: true }
);

export default mongoose.model<IWorkspaceNote>("WorkspaceNote", workspaceNoteSchema);
