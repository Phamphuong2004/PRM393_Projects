import os
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv

load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI", "mongodb://localhost:27017")

# Create a singleton client
_client = AsyncIOMotorClient(MONGODB_URI)

async def get_core_db():
    return _client.get_database("core_db")

async def get_interaction_db():
    return _client.get_database("interaction_db")

async def get_auth_db():
    return _client.get_database("auth_db")
