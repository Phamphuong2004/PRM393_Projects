import os
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv

load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI", "mongodb://localhost:27017")

# Create a singleton client
_client = AsyncIOMotorClient(MONGODB_URI)
db = _client.get_default_database(default="JournalTrackerDB")

async def get_db():
    return db
