import mongoose, { Schema, Document } from "mongoose";

export interface IAuthor extends Document {
  fullName: string;
  externalAuthorId: string;
  affiliation: string;
  orcid: string;
  operalId: string;
  workCount: number;
}

const authorSchema = new Schema<IAuthor>(
  {
    fullName: {
      type: String,
      required: true,
    },
    externalAuthorId: {
      type: String,
      unique: true,
      sparse: true,
    },
    affiliation: String,
    orcid: {
      type: String,
      unique: true,
      sparse: true,
    },
    operalId: {
      type: String,
      unique: true,
      sparse: true,
    },
    workCount: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  },
);

export default mongoose.model<IAuthor>("Author", authorSchema);
