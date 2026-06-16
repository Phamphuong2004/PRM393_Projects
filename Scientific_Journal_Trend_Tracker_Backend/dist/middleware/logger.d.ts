import { Request, Response, NextFunction } from "express";
/**
 * Request logging middleware
 */
export declare const requestLogger: (req: Request, res: Response, next: NextFunction) => void;
/**
 * Error logging middleware
 */
export declare const errorLogger: (error: any, req: Request, res: Response, next: NextFunction) => void;
/**
 * Get logs by date
 */
export declare const getLogsForDate: (date: string) => string[];
/**
 * Get error logs by date
 */
export declare const getErrorLogsForDate: (date: string) => any[];
/**
 * Get slow request logs
 */
export declare const getSlowRequests: () => string[];
//# sourceMappingURL=logger.d.ts.map