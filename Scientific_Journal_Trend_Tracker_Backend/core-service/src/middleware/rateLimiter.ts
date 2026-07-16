import { Request, Response, NextFunction } from "express";

interface RateLimitStore {
  [key: string]: {
    requests: number;
    resetTime: number;
  };
}

const store: RateLimitStore = {};

export interface RateLimitOptions {
  windowMs: number; // Time window in milliseconds
  maxRequests: number; // Max requests per time window
  keyGenerator?: (req: Request) => string; // Custom key generator (default: IP address)
  message?: string; // Custom error message
  statusCode?: number; // Custom status code
}

/**
 * Rate limiting middleware
 * @param options Configuration options
 */
export const rateLimit = (options: RateLimitOptions) => {
  const {
    windowMs,
    maxRequests,
    keyGenerator = defaultKeyGenerator,
    message = "Too many requests, please try again later.",
    statusCode = 429,
  } = options;

  return (req: Request, res: Response, next: NextFunction) => {
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
      res.set(
        "Retry-After",
        Math.ceil((store[key].resetTime - now) / 1000).toString(),
      );
      return res.status(statusCode).json({
        message,
        retryAfter: store[key].resetTime - now,
      });
    }

    // Add rate limit info to response headers
    res.set("X-RateLimit-Limit", maxRequests.toString());
    res.set(
      "X-RateLimit-Remaining",
      (maxRequests - store[key].requests).toString(),
    );
    res.set("X-RateLimit-Reset", store[key].resetTime.toString());

    next();
  };
};

/**
 * Default key generator using IP address
 */
function defaultKeyGenerator(req: Request): string {
  return (req.ip || req.socket.remoteAddress || "unknown") as string;
}

/**
 * User-based rate limiting
 */
export const userRateLimit = (options: RateLimitOptions) => {
  return rateLimit({
    ...options,
    keyGenerator: (req: Request) => {
      // Use user ID if authenticated, otherwise use IP
      return (
        (req as any).userId || req.ip || req.socket.remoteAddress || "unknown"
      );
    },
  });
};

/**
 * Cleanup old entries from store (memory leak prevention)
 */
export const cleanupRateLimitStore = () => {
  const now = Date.now();
  for (const key in store) {
    if (now > store[key].resetTime + 60000) {
      // Keep 1 minute after reset for tracking
      delete store[key];
    }
  }
};

/**
 * Preset rate limits
 */
export const rateLimits = {
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
setInterval(cleanupRateLimitStore, 30 * 60 * 1000);
