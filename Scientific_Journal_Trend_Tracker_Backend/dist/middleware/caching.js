"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCache = exports.setCache = exports.cacheWithKey = exports.cacheMiddleware = exports.clearAllCache = exports.clearCachePattern = exports.clearExpiredCache = void 0;
const cache = new Map();
// Clear expired cache entries
const clearExpiredCache = () => {
    const now = Date.now();
    for (const [key, entry] of cache.entries()) {
        if (now - entry.timestamp > entry.ttl) {
            cache.delete(key);
        }
    }
};
exports.clearExpiredCache = clearExpiredCache;
// Clear cache by pattern
const clearCachePattern = (pattern) => {
    const regex = new RegExp(pattern);
    for (const key of cache.keys()) {
        if (regex.test(key)) {
            cache.delete(key);
        }
    }
};
exports.clearCachePattern = clearCachePattern;
// Clear all cache
const clearAllCache = () => {
    cache.clear();
};
exports.clearAllCache = clearAllCache;
// Get cache key from request
const getCacheKey = (req) => {
    return `${req.method}:${req.originalUrl}`;
};
// Cache middleware for GET requests
const cacheMiddleware = (ttl = 5 * 60 * 1000) => {
    return (req, res, next) => {
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
        res.json = function (data) {
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
exports.cacheMiddleware = cacheMiddleware;
// Cache middleware with custom key generator
const cacheWithKey = (ttl, keyGenerator) => {
    return (req, res, next) => {
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
        res.json = function (data) {
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
exports.cacheWithKey = cacheWithKey;
// Manual cache setter
const setCache = (key, data, ttl = 5 * 60 * 1000) => {
    cache.set(key, {
        data,
        timestamp: Date.now(),
        ttl,
    });
};
exports.setCache = setCache;
// Manual cache getter
const getCache = (key) => {
    const entry = cache.get(key);
    if (entry && Date.now() - entry.timestamp < entry.ttl) {
        return entry.data;
    }
    cache.delete(key);
    return null;
};
exports.getCache = getCache;
// Periodic cache cleanup (run every 10 minutes)
setInterval(exports.clearExpiredCache, 10 * 60 * 1000);
//# sourceMappingURL=caching.js.map