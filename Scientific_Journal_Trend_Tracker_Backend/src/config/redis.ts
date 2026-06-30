import Redis from "ioredis";

// Use environment variable or default to localhost:6379
const redisUrl = process.env.REDIS_URL || "redis://localhost:6379";

const redisClient = new Redis(redisUrl, {
  enableOfflineQueue: false,
  maxRetriesPerRequest: 0,
  connectTimeout: 500,
  retryStrategy: (times) => {
    // Stop retrying to avoid console spam in local dev
    return null;
  },
});

redisClient.on("connect", () => {
  console.log("Connected to Redis cache");
});

redisClient.on("error", (err: any) => {
  // Hide connection refused errors to keep terminal clean in local dev
  if (err && err.message && err.message.includes("ECONNREFUSED")) {
    return;
  }
  console.error("Redis error:", err);
});

export default redisClient;
