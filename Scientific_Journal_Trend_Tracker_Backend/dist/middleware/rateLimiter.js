"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.rateLimits = exports.cleanupRateLimitStore = exports.userRateLimit = exports.rateLimit = void 0;
const store = {};
/**
 * Rate limiting middleware
 * @param options Configuration options
 */
const rateLimit = (options) => {
    const { windowMs, maxRequests, keyGenerator = defaultKeyGenerator, message = "Too many requests, please try again later.", statusCode = 429, } = options;
    return (req, res, next) => {
        const key = keyGenerator(req);
        const now = Date.now();
        // Initialize store entry if not exists
        if (!store[key]) {
            store[key] = {
                requests: 1,
                resetTime: now + windowMs,
            };
            return next();
        }
        // Reset if window expired
        if (now > store[key].resetTime) {
            store[key] = {
                requests: 1,
                resetTime: now + windowMs,
            };
            return next();
        }
        // Increment requests
        store[key].requests++;
        // Check limit
        if (store[key].requests > maxRequests) {
            res.set("Retry-After", Math.ceil((store[key].resetTime - now) / 1000).toString());
            return res.status(statusCode).json({
                message,
                retryAfter: store[key].resetTime - now,
            });
        }
        // Add rate limit info to response headers
        res.set("X-RateLimit-Limit", maxRequests.toString());
        res.set("X-RateLimit-Remaining", (maxRequests - store[key].requests).toString());
        res.set("X-RateLimit-Reset", store[key].resetTime.toString());
        next();
    };
};
exports.rateLimit = rateLimit;
/**
 * Default key generator using IP address
 */
function defaultKeyGenerator(req) {
    return (req.ip || req.socket.remoteAddress || "unknown");
}
/**
 * User-based rate limiting
 */
const userRateLimit = (options) => {
    return (0, exports.rateLimit)({
        ...options,
        keyGenerator: (req) => {
            // Use user ID if authenticated, otherwise use IP
            return (req.userId || req.ip || req.socket.remoteAddress || "unknown");
        },
    });
};
exports.userRateLimit = userRateLimit;
/**
 * Cleanup old entries from store (memory leak prevention)
 */
const cleanupRateLimitStore = () => {
    const now = Date.now();
    for (const key in store) {
        if (now > store[key].resetTime + 60000) {
            // Keep 1 minute after reset for tracking
            delete store[key];
        }
    }
};
exports.cleanupRateLimitStore = cleanupRateLimitStore;
/**
 * Preset rate limits
 */
exports.rateLimits = {
    // Strict limit for auth endpoints
    auth: {
        windowMs: 15 * 60 * 1000, // 15 minutes
        maxRequests: 9999, // Disabled for testing
    },
    // Standard limit for API endpoints
    api: {
        windowMs: 15 * 60 * 1000, // 15 minutes
        maxRequests: 9999,
    },
    // Loose limit for read-only endpoints
    read: {
        windowMs: 15 * 60 * 1000, // 15 minutes
        maxRequests: 9999,
    },
    // Strict limit for write operations
    write: {
        windowMs: 15 * 60 * 1000, // 15 minutes
        maxRequests: 9999,
    },
    // Very strict for sensitive operations
    sensitive: {
        windowMs: 60 * 60 * 1000, // 1 hour
        maxRequests: 9999,
    },
};
// Periodic cleanup (every 30 minutes)
setInterval(exports.cleanupRateLimitStore, 30 * 60 * 1000);
//# sourceMappingURL=rateLimiter.js.map