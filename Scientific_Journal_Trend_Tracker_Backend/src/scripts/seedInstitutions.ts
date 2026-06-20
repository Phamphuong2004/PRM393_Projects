import mongoose from "mongoose";
import dotenv from "dotenv";
import Institution from "../models/Institution";

// Load environment variables
dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI || "";

if (!MONGODB_URI) {
  console.error("MONGODB_URI is not defined in .env file");
  process.exit(1);
}

// 12 well-known universities in Vietnam.
const institutions = [
  { name: "FPT University", country: "Vietnam", city: "Hanoi", website: "https://www.fpt.edu.vn" },
  { name: "Vietnam National University, Hanoi (VNU)", country: "Vietnam", city: "Hanoi", website: "https://vnu.edu.vn" },
  { name: "Vietnam National University, Ho Chi Minh City (VNU-HCM)", country: "Vietnam", city: "Ho Chi Minh City", website: "https://vnuhcm.edu.vn" },
  { name: "Hanoi University of Science and Technology (HUST)", country: "Vietnam", city: "Hanoi", website: "https://hust.edu.vn" },
  { name: "Ho Chi Minh City University of Technology (HCMUT)", country: "Vietnam", city: "Ho Chi Minh City", website: "https://hcmut.edu.vn" },
  { name: "National Economics University (NEU)", country: "Vietnam", city: "Hanoi", website: "https://neu.edu.vn" },
  { name: "University of Economics Ho Chi Minh City (UEH)", country: "Vietnam", city: "Ho Chi Minh City", website: "https://ueh.edu.vn" },
  { name: "Foreign Trade University (FTU)", country: "Vietnam", city: "Hanoi", website: "https://ftu.edu.vn" },
  { name: "University of Danang (UDN)", country: "Vietnam", city: "Da Nang", website: "https://udn.vn" },
  { name: "Can Tho University (CTU)", country: "Vietnam", city: "Can Tho", website: "https://www.ctu.edu.vn" },
  { name: "Ton Duc Thang University (TDTU)", country: "Vietnam", city: "Ho Chi Minh City", website: "https://tdtu.edu.vn" },
  { name: "Posts and Telecommunications Institute of Technology (PTIT)", country: "Vietnam", city: "Hanoi", website: "https://ptit.edu.vn" },
];

const seedInstitutions = async () => {
  try {
    console.log("Connecting to MongoDB...");
    await mongoose.connect(MONGODB_URI);
    console.log("Connected successfully!");

    // Replace the whole institution catalog (only touches this collection).
    await Institution.deleteMany({});
    await Institution.insertMany(institutions);

    const total = await Institution.countDocuments();
    console.log(`Done. Institution catalog replaced. Total in DB: ${total}`);
    process.exit(0);
  } catch (error) {
    console.error("Error seeding institutions:", error);
    process.exit(1);
  }
};

seedInstitutions();
