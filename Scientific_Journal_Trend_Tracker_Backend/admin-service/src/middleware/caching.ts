import { Request, Response, NextFunction } from "express";

interface CacheEntry {
  data: any;
  timestamp: number;
  ttl: number;
}

const cache = new Map<string, CacheEntry>();

// Clear expired cache entries
export const clearExpiredCache = () => {
  const now = Date.now();
  for (const [key, entry] of cache.entries()) {
    if (now - entry.timestamp > entry.ttl) {
      cache.delete(key);
    }
  }
};

// Clear cache by pattern
export const clearCachePattern = (pattern: string) => {
  const regex = new RegExp(pattern);
  for (const key of cache.keys()) {
    if (regex.test(key)) {
      cache.delete(key);
    }
  }
};

// Clear all cache
export const clearAllCache = () => {
  cache.clear();
};

// Get cache key from request
const getCacheKey = (req: Request): string => {
  return `${req.method}:${req.originalUrl}`;
};

// Cache middleware for GET requests
export const cacheMiddleware = (ttl: number = 5 * 60 * 1000) => {
  return (req: Request, res: Response, next: NextFunction) => {
    // Only cache GET requests
    if (req.method !== "GET") {
      return next();
    }

    const cacheKey = getCacheKey(req);
    const cachedEntry = cache.get(cacheKey);

    // Check if cache is still valid
    if (cachedEntry && Date.now() - cachedEntry.timestamp < cachedEntry.ttl) {
      res.set("X-Cache", "HIT");
      return res.json(cachedEntry.data);
    }

    // Store original json function
    const originalJson = res.json.bind(res);

    // Override json function to cache the response
    res.json = function (data: any) {
      cache.set(cacheKey, {
        data,
        timestamp: Date.now(),
        ttl,
      });

      res.set("X-Cache", "MISS");
      return originalJson(data);
    };

    next();
  };
};

// Cache middleware with custom key generator
export const cacheWithKey = (
  ttl: number,
  keyGenerator: (req: Request) => string,
) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (req.method !== "GET") {
      return next();
    }

    const cacheKey = keyGenerator(req);
    const cachedEntry = cache.get(cacheKey);

    if (cachedEntry && Date.now() - cachedEntry.timestamp < cachedEntry.ttl) {
      res.set("X-Cache", "HIT");
      return res.json(cachedEntry.data);
    }

    const originalJson = res.json.bind(res);

    res.json = function (data: any) {
      cache.set(cacheKey, {
        data,
        timestamp: Date.now(),
        ttl,
      });

      res.set("X-Cache", "MISS");
      return originalJson(data);
    };

    next();
  };
};

// Manual cache setter
export const setCache = (
  key: string,
  data: any,
  ttl: number = 5 * 60 * 1000,
) => {
  cache.set(key, {
    data,
    timestamp: Date.now(),
    ttl,
  });
};

// Manual cache getter
export const getCache = (key: string) => {
  const entry = cache.get(key);
  if (entry && Date.now() - entry.timestamp < entry.ttl) {
    return entry.data;
  }
  cache.delete(key);
  return null;
};

// Periodic cache cleanup (run every 10 minutes)
setInterval(clearExpiredCache, 10 * 60 * 1000);
