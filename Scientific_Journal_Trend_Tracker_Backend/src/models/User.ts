import mongoose, { Schema, Document } from "mongoose";

export interface TrackedRun {
  analysisRunId: mongoose.Types.ObjectId;
  notifyEnabled: boolean;
  followedAt: Date;
}

export interface Follow {
  targetType: "Keyword" | "Journal";
  targetId: mongoose.Types.ObjectId;
  notifyEnabled: boolean;
}

export interface IUser extends Document {
  email: string;
  password: string;
  fullName: string;
  role: "admin" | "researcher" | "student";
  institution?: string;
  bio?: string;
  interests: string[];
  avatar?: string;
  isActive: boolean;
  emailVerified: boolean;
  lastLogin?: Date;
  bookmarks: mongoose.Types.ObjectId[];
  trackedRuns: TrackedRun[];
  follows: Follow[];
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    password: {
      type: String,
      required: true,
      minlength: 6,
    },
    fullName: {
      type: String,
      required: true,
    },
    role: {
      type: String,
      enum: ["admin", "researcher", "student"],
      default: "researcher",
    },
    institution: String,
    bio: String,
    interests: [String],
    avatar: String,
    isActive: {
      type: Boolean,
      default: true,
    },
    emailVerified: {
      type: Boolean,
      default: false,
    },
    lastLogin: Date,
    bookmarks: [
      {
        type: Schema.Types.ObjectId,
        ref: "Paper",
      },
    ],
    trackedRuns: [
      {
        analysisRunId: {
          type: Schema.Types.ObjectId,
          ref: "AnalysisRun",
        },
        notifyEnabled: {
          type: Boolean,
          default: true,
        },
        followedAt: Date,
      },
    ],
    follows: [
      {
        targetType: {
          type: String,
          enum: ["Keyword", "Journal"],
        },
        targetId: Schema.Types.ObjectId,
        notifyEnabled: {
          type: Boolean,
          default: true,
        },
      },
    ],
  },
  {
    timestamps: true,
  },
);

export default mongoose.model<IUser>("user", userSchema);


