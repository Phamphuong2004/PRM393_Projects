import mongoose, { Schema, Document } from "mongoose";

export interface IWorkspaceMember {
  user: mongoose.Types.ObjectId;
  role: "owner" | "editor" | "viewer";
  status?: "pending" | "accepted";
  addedAt: Date;
}

export interface IWorkspace extends Document {
  name: string;
  description?: string;
  visibility: "private" | "team" | "public";
  owner: mongoose.Types.ObjectId;
  members: IWorkspaceMember[];
  createdAt: Date;
  updatedAt: Date;
}

const workspaceMemberSchema = new Schema<IWorkspaceMember>({
  user: { type: Schema.Types.ObjectId, ref: "user", required: true },
  role: { type: String, enum: ["owner", "editor", "viewer"], default: "viewer" },
  status: { type: String, enum: ["pending", "accepted"], default: "accepted" },
  addedAt: { type: Date, default: Date.now },
}, { _id: false });

const workspaceSchema = new Schema<IWorkspace>(
  {
    name: { type: String, required: true, trim: true },
    description: { type: String, trim: true },
    visibility: { type: String, enum: ["private", "team", "public"], default: "private" },
    owner: { type: Schema.Types.ObjectId, ref: "user", required: true },
    members: [workspaceMemberSchema],
  },
  { timestamps: true }
);

export default mongoose.model<IWorkspace>("Workspace", workspaceSchema);
