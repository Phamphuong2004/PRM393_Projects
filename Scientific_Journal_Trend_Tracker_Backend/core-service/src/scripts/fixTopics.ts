import mongoose from "mongoose";
import dotenv from "dotenv";
import Topic from "../models/Topic";
import Paper from "../models/Paper";
import path from "path";

dotenv.config({ path: path.join(__dirname, "../../../.env") });

const MONGODB_URI = process.env.MONGODB_URI 
  ? process.env.MONGODB_URI.replace("/JournalTrackerDB?", "/core_db?").replace("/?", "/core_db?")
  : "mongodb+srv://thanhtu_user:Thanhtu%40204@cluster0.h3nsaiz.mongodb.net/core_db?appName=Cluster0";

const fixData = async () => {
  try {
    console.log("Connecting to MongoDB:", MONGODB_URI);
    await mongoose.connect(MONGODB_URI);
    
    const topics = await Topic.find();
    console.log(`Found ${topics.length} topics. Fixing two-way relations...`);

    let updatedPapersCount = 0;
    for (const topic of topics) {
      if (topic.papers && topic.papers.length > 0) {
        const result = await Paper.updateMany(
          { _id: { $in: topic.papers } },
          { $addToSet: { topics: topic._id } }
        );
        updatedPapersCount += result.modifiedCount;
      }
    }

    console.log(`✅ Successfully updated ${updatedPapersCount} papers to include their topic IDs!`);
    process.exit(0);
  } catch (error) {
    console.error("❌ Fix failed:", error);
    process.exit(1);
  }
};

fixData();
