import mongoose from "mongoose";
import "dotenv/config";
import Workspace from "../src/models/Workspace";

async function checkWorkspaces() {
  try {
    await mongoose.connect(process.env.MONGODB_URI!);
    console.log("Connected to MongoDB");
    
    const workspaces = await Workspace.find({});
    console.log("Workspaces found:", workspaces.length);
    workspaces.forEach(w => {
      console.log(`ID: ${w._id}, Name: ${w.name}, Owner: ${w.owner}`);
    });
    
    await mongoose.disconnect();
  } catch (error) {
    console.error("Error:", error);
  }
}

checkWorkspaces();
