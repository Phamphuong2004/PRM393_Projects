import mongoose from "mongoose";
import dotenv from "dotenv";
import User from "../models/User";
import Journal from "../models/Journal";
import Author from "../models/Author";
import Keyword from "../models/Keyword";
import Paper from "../models/Paper";
import bcrypt from "bcryptjs";

// Load environment variables
dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI || "";

if (!MONGODB_URI) {
  console.error("MONGODB_URI is not defined in .env file");
  process.exit(1);
}

const seedData = async () => {
  try {
    console.log("Connecting to MongoDB...");
    await mongoose.connect(MONGODB_URI);
    console.log("Connected successfully!");

    console.log("Clearing existing data...");
    await User.deleteMany({});
    await Journal.deleteMany({});
    await Author.deleteMany({});
    await Keyword.deleteMany({});
    await Paper.deleteMany({});

    console.log("Creating System Administrator...");
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash("admin123", salt);
    
    const admin = await User.create({
      email: "admin@example.com",
      password: hashedPassword,
      fullName: "admin",
      role: "admin",
      isActive: true,
      emailVerified: true,
      interests: ["Data Science", "Machine Learning"]
    });

    console.log("Creating Researcher...");
    const researcher = await User.create({
      email: "researcher@example.com",
      password: hashedPassword,
      fullName: "Test Researcher",
      role: "researcher",
      isActive: true,
      emailVerified: true,
      interests: ["Artificial Intelligence", "Blockchain"]
    });

    console.log("Creating Lecturer/Student...");
    const student = await User.create({
      email: "student@example.com",
      password: hashedPassword,
      fullName: "Test Student",
      role: "user",
      isActive: true,
      emailVerified: true,
      interests: ["Computer Vision", "Deep Learning"]
    });

    console.log("Creating Journals...");
    const journal1 = await Journal.create({
      name: "Journal of Artificial Intelligence Research",
      issn: "1076-9757",
      publisher: "AI Access Foundation",
      impactFactor: 4.5,
      hIndex: 120,
      paperCount: 500,
      fieldDomain: "Computer Science",
      isTracked: true,
      source: "OpenAlex",
      externalId: "jair_001"
    });

    const journal2 = await Journal.create({
      name: "IEEE Transactions on Pattern Analysis and Machine Intelligence",
      issn: "0162-8828",
      publisher: "IEEE",
      impactFactor: 16.3,
      hIndex: 300,
      paperCount: 1200,
      fieldDomain: "Computer Science",
      isTracked: true,
      source: "OpenAlex",
      externalId: "ieee_tpami_002"
    });

    console.log("Creating Authors...");
    const author1 = await Author.create({
      fullName: "Andrew Ng",
      externalAuthorId: "auth_001",
      affiliation: "Stanford University",
      workCount: 150
    });

    const author2 = await Author.create({
      fullName: "Yann LeCun",
      externalAuthorId: "auth_002",
      affiliation: "New York University",
      workCount: 200
    });

    console.log("Creating Keywords...");
    const keyword1 = await Keyword.create({
      name: "Deep Learning",
      normalizedText: "deep learning",
      openalexId: "kw_001",
      workCount: 5000,
      paperCount: 5000,
      trendScore: 9.5,
      growthRate: 15.2,
      source: "OpenAlex"
    });

    const keyword2 = await Keyword.create({
      name: "Computer Vision",
      normalizedText: "computer vision",
      openalexId: "kw_002",
      workCount: 8000,
      paperCount: 8000,
      trendScore: 8.7,
      growthRate: 12.1,
      source: "OpenAlex"
    });

    console.log("Creating Papers...");
    await Paper.create({
      title: "ImageNet Classification with Deep Convolutional Neural Networks",
      abstract: "We trained a large, deep convolutional neural network to classify the 1.2 million high-resolution images in the ImageNet LSVRC-2010 contest into the 1000 different classes...",
      doi: "10.1145/3065386",
      publicationYear: 2012,
      citationCount: 100000,
      externalId_openalexId: "paper_001",
      authors: [author1._id, author2._id],
      journalId: journal2._id,
      keywords: [keyword1._id, keyword2._id],
      source: "OpenAlex"
    });

    await Paper.create({
      title: "Generative Adversarial Nets",
      abstract: "We propose a new framework for estimating generative models via an adversarial process...",
      doi: "10.1145/1234567",
      publicationYear: 2014,
      citationCount: 50000,
      externalId_openalexId: "paper_002",
      authors: [author2._id],
      journalId: journal1._id,
      keywords: [keyword1._id],
      source: "OpenAlex"
    });

    console.log("Data seeding completed successfully!");
    process.exit(0);
  } catch (error) {
    console.error("Error seeding data:", error);
    process.exit(1);
  }
};

seedData();


