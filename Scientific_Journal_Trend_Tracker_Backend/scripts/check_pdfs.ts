import mongoose from "mongoose";
import "dotenv/config";
import Paper from "../src/models/Paper";

async function checkPdfs() {
  try {
    await mongoose.connect(process.env.MONGODB_URI!);
    console.log("Connected to MongoDB");
    
    const papers = await Paper.find({ pdfUrl: { $exists: true, $ne: null } });
    console.log("Papers with PDF found:", papers.length);
    papers.forEach(p => {
      console.log(`Title: ${p.title}\nURL: ${p.pdfUrl}\n`);
    });
    
    await mongoose.disconnect();
  } catch (error) {
    console.error("Error:", error);
  }
}

checkPdfs();
