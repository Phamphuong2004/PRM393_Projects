import { Request, Response, NextFunction } from "express";

export interface PaginationParams {
  page: number;
  limit: number;
  skip: number;
}

/**
 * Extract and validate pagination parameters from query string
 */
export const paginationMiddleware = (
  defaultLimit: number = 10,
  maxLimit: number = 100,
) => {
  return (req: Request, res: Response, next: NextFunction) => {
    let page = 1;
    let limit = defaultLimit;

    // Parse page parameter
    if (req.query.page) {
      const parsedPage = parseInt(req.query.page as string);
      if (!isNaN(parsedPage) && parsedPage > 0) {
        page = parsedPage;
      }
    }

    // Parse limit parameter
    if (req.query.limit) {
      const parsedLimit = parseInt(req.query.limit as string);
      if (!isNaN(parsedLimit) && parsedLimit > 0) {
        limit = Math.min(parsedLimit, maxLimit);
      }
    }

    const skip = (page - 1) * limit;

    // Attach to request
    (req as any).pagination = {
      page,
      limit,
      skip,
    } as PaginationParams;

    next();
  };
};

/**
 * Helper function to get pagination params from request
 */
export const getPaginationParams = (req: Request): PaginationParams => {
  return (req as any).pagination || { page: 1, limit: 10, skip: 0 };
};

/**
 * Format paginated response
 */
export const formatPaginatedResponse = <T>(
  data: T[],
  total: number,
  page: number,
  limit: number,
) => {
  return {
    data,
    pagination: {
      page,
      limit,
      total,
      pages: Math.ceil(total / limit),
      hasMore: page * limit < total,
    },
  };
};
