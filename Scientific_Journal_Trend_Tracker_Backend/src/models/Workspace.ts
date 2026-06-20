import mongoose, { Schema, Document } from "mongoose";

export interface IWorkspaceMember {
  user: mongoose.Types.ObjectId;
  role: "owner" | "editor" | "viewer";
  addedAt: Date;
}

export interface IWorkspace extends Document {
  name: string;
  description?: string;
  visibility: "private" | "team" | "public";
  plan: "free" | "premium";
  owner: mongoose.Types.ObjectId;
  members: IWorkspaceMember[];
  createdAt: Date;
  updatedAt: Date;
}

const workspaceMemberSchema = new Schema<IWorkspaceMember>({
  user: { type: Schema.Types.ObjectId, ref: "user", required: true },
  role: { type: String, enum: ["owner", "editor", "viewer"], default: "viewer" },
  addedAt: { type: Date, default: Date.now },
}, { _id: false });

const workspaceSchema = new Schema<IWorkspace>(
  {
    name: { type: String, required: true, trim: true },
    description: { type: String, trim: true },
    visibility: { type: String, enum: ["private", "team", "public"], default: "private" },
    plan: { type: String, enum: ["free", "premium"], default: "free" },
    owner: { type: Schema.Types.ObjectId, ref: "user", required: true },
    members: [workspaceMemberSchema],
  },
  { timestamps: true }
);

export default mongoose.model<IWorkspace>("Workspace", workspaceSchema);
