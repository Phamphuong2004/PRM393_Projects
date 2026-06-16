import Redis from "ioredis";

// Use environment variable or default to localhost:6379
const redisUrl = process.env.REDIS_URL || "redis://localhost:6379";

const redisClient = new Redis(redisUrl);

redisClient.on("connect", () => {
  console.log("Connected to Redis cache");
});

redisClient.on("error", (err) => {
  console.error("Redis error:", err);
});

export default redisClient;
