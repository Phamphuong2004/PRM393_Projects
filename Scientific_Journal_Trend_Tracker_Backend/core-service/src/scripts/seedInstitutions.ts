import mongoose from "mongoose";
import dotenv from "dotenv";
import Institution from "../models/Institution";
import path from "path";
import axios from "axios";

// Load environment variables
dotenv.config({ path: path.join(__dirname, "../../../.env") });

const MONGODB_URI = process.env.MONGODB_URI 
  ? process.env.MONGODB_URI.replace("/JournalTrackerDB?", "/core_db?").replace("/?", "/core_db?")
  : "mongodb+srv://thanhtu_user:Thanhtu%40204@cluster0.h3nsaiz.mongodb.net/core_db?appName=Cluster0";

const seedInstitutions = async () => {
  try {
    console.log("Connecting to MongoDB:", MONGODB_URI);
    await mongoose.connect(MONGODB_URI);
    console.log("Connected to MongoDB successfully.");

    console.log("Fetching top 50 institutions globally from OpenAlex...");
    const url = `https://api.openalex.org/institutions?sort=works_count:desc&per-page=50`;
    const response = await axios.get(url);
    const institutionsData = response.data.results;
    
    console.log(`Found ${institutionsData.length} institutions. Processing...`);

    for (const inst of institutionsData) {
      await Institution.findOneAndUpdate(
        { name: inst.display_name },
        {
          $setOnInsert: {
            name: inst.display_name,
            country: inst.country_code || "Unknown",
            city: inst.geo?.city || "Unknown",
            website: inst.homepage_url || "N/A",
            isActive: true,
          }
        },
        { upsert: true, new: true }
      );
    }

    console.log("✅ Institutions Seeding completed successfully!");
    process.exit(0);
  } catch (error) {
    console.error("❌ Seeding failed:", error);
    process.exit(1);
  }
};

seedInstitutions();
