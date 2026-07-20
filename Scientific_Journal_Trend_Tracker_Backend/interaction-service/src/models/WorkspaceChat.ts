import mongoose, { Schema, Document } from "mongoose";

export interface IWorkspaceChatMessage extends Document {
  workspace: mongoose.Types.ObjectId;
  sender: mongoose.Types.ObjectId;
  content: string;
  createdAt: Date;
  updatedAt: Date;
}

const workspaceChatMessageSchema = new Schema<IWorkspaceChatMessage>(
  {
    workspace: { type: Schema.Types.ObjectId, ref: "Workspace", required: true, index: true },
    sender: { type: Schema.Types.ObjectId, required: true },
    content: { type: String, required: true, trim: true, maxlength: 2000 },
  },
  { timestamps: true }
);

export default mongoose.model<IWorkspaceChatMessage>("WorkspaceChatMessage", workspaceChatMessageSchema);
