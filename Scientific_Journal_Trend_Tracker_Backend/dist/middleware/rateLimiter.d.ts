import { Request, Response, NextFunction } from "express";
export interface RateLimitOptions {
    windowMs: number;
    maxRequests: number;
    keyGenerator?: (req: Request) => string;
    message?: string;
    statusCode?: number;
}
/**
 * Rate limiting middleware
 * @param options Configuration options
 */
export declare const rateLimit: (options: RateLimitOptions) => (req: Request, res: Response, next: NextFunction) => void | Response<any, Record<string, any>>;
/**
 * User-based rate limiting
 */
export declare const userRateLimit: (options: RateLimitOptions) => (req: Request, res: Response, next: NextFunction) => void | Response<any, Record<string, any>>;
/**
 * Cleanup old entries from store (memory leak prevention)
 */
export declare const cleanupRateLimitStore: () => void;
/**
 * Preset rate limits
 */
export declare const rateLimits: {
    auth: {
        windowMs: number;
        maxRequests: number;
    };
    api: {
        windowMs: number;
        maxRequests: number;
    };
    read: {
        windowMs: number;
        maxRequests: number;
    };
    write: {
        windowMs: number;
        maxRequests: number;
    };
    sensitive: {
        windowMs: number;
        maxRequests: number;
    };
};
//# sourceMappingURL=rateLimiter.d.ts.map