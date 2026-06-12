import mongoose, { Schema, Document } from "mongoose";

export interface IPaper extends Document {
  title: string;
  abstract: string;
  doi: string;
  url: string;
  publicationYear: number;
  publicationMonth?: number;
  publishedDate?: Date;
  citationCount: number;
  externalId_openalexId: string;
  externalId_semanticScholarId: string;
  externalId_crossref: string;
  authors: mongoose.Types.ObjectId[];
  journalId: mongoose.Types.ObjectId;
  keywords: mongoose.Types.ObjectId[];
  topics: mongoose.Types.ObjectId[];
  source: string;
  lastSyncedAt?: Date;
}

const paperSchema = new Schema<IPaper>(
  {
    title: {
      type: String,
      required: true,
    },
    abstract: String,
    doi: {
      type: String,
      unique: true,
      sparse: true,
    },
    url: String,
    publicationYear: Number,
    publicationMonth: Number,
    publishedDate: Date,
    citationCount: {
      type: Number,
      default: 0,
    },
    externalId_openalexId: {
      type: String,
      unique: true,
      sparse: true,
    },
    externalId_semanticScholarId: {
      type: String,
      unique: true,
      sparse: true,
    },
    externalId_crossref: {
      type: String,
      unique: true,
      sparse: true,
    },
    authors: [
      {
        type: Schema.Types.ObjectId,
        ref: "Author",
      },
    ],
    journalId: {
      type: Schema.Types.ObjectId,
      ref: "Journal",
    },
    keywords: [
      {
        type: Schema.Types.ObjectId,
        ref: "Keyword",
      },
    ],
    topics: [
      {
        type: Schema.Types.ObjectId,
        ref: "Topic",
      },
    ],
    source: String,
    lastSyncedAt: Date,
  },
  {
    timestamps: true,
  },
);

export default mongoose.model<IPaper>("Paper", paperSchema);
