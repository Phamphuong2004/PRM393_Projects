"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatPaginatedResponse = exports.getPaginationParams = exports.paginationMiddleware = void 0;
/**
 * Extract and validate pagination parameters from query string
 */
const paginationMiddleware = (defaultLimit = 10, maxLimit = 100) => {
    return (req, res, next) => {
        let page = 1;
        let limit = defaultLimit;
        // Parse page parameter
        if (req.query.page) {
            const parsedPage = parseInt(req.query.page);
            if (!isNaN(parsedPage) && parsedPage > 0) {
                page = parsedPage;
            }
        }
        // Parse limit parameter
        if (req.query.limit) {
            const parsedLimit = parseInt(req.query.limit);
            if (!isNaN(parsedLimit) && parsedLimit > 0) {
                limit = Math.min(parsedLimit, maxLimit);
            }
        }
        const skip = (page - 1) * limit;
        // Attach to request
        req.pagination = {
            page,
            limit,
            skip,
        };
        next();
    };
};
exports.paginationMiddleware = paginationMiddleware;
/**
 * Helper function to get pagination params from request
 */
const getPaginationParams = (req) => {
    return req.pagination || { page: 1, limit: 10, skip: 0 };
};
exports.getPaginationParams = getPaginationParams;
/**
 * Format paginated response
 */
const formatPaginatedResponse = (data, total, page, limit) => {
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
exports.formatPaginatedResponse = formatPaginatedResponse;
//# sourceMappingURL=pagination.js.map