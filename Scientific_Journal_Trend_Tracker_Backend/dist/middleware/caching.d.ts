import { Request, Response, NextFunction } from "express";
export declare const clearExpiredCache: () => void;
export declare const clearCachePattern: (pattern: string) => void;
export declare const clearAllCache: () => void;
export declare const cacheMiddleware: (ttl?: number) => (req: Request, res: Response, next: NextFunction) => void | Response<any, Record<string, any>>;
export declare const cacheWithKey: (ttl: number, keyGenerator: (req: Request) => string) => (req: Request, res: Response, next: NextFunction) => void | Response<any, Record<string, any>>;
export declare const setCache: (key: string, data: any, ttl?: number) => void;
export declare const getCache: (key: string) => any;
//# sourceMappingURL=caching.d.ts.map