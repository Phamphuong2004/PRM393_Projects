import mongoose, { Schema, Document } from "mongoose";

export interface IInstitution extends Document {
  name: string;
  country?: string;
  city?: string;
  website?: string;
  isActive: boolean;
  lastSyncedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const institutionSchema = new Schema<IInstitution>(
  {
    name: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    country: { type: String, trim: true },
    city: { type: String, trim: true },
    website: { type: String, trim: true },
    isActive: {
      type: Boolean,
      default: true,
    },
    lastSyncedAt: Date,
  },
  {
    timestamps: true,
  },
);

export default mongoose.model<IInstitution>("Institution", institutionSchema);
