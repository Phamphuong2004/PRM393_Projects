import { Request, Response, NextFunction } from "express";
export interface PaginationParams {
    page: number;
    limit: number;
    skip: number;
}
/**
 * Extract and validate pagination parameters from query string
 */
export declare const paginationMiddleware: (defaultLimit?: number, maxLimit?: number) => (req: Request, res: Response, next: NextFunction) => void;
/**
 * Helper function to get pagination params from request
 */
export declare const getPaginationParams: (req: Request) => PaginationParams;
/**
 * Format paginated response
 */
export declare const formatPaginatedResponse: <T>(data: T[], total: number, page: number, limit: number) => {
    data: T[];
    pagination: {
        page: number;
        limit: number;
        total: number;
        pages: number;
        hasMore: boolean;
    };
};
//# sourceMappingURL=pagination.d.ts.map