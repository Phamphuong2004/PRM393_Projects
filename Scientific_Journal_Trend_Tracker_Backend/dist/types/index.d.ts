import { Request } from "express";
export interface AuthRequest extends Request {
    userId?: string;
    userRole?: string;
}
export interface ApiResponse<T> {
    success: boolean;
    data?: T;
    message?: string;
    error?: string;
}
export interface PaginationParams {
    page: number;
    limit: number;
    skip: number;
    total: number;
    pages: number;
}
//# sourceMappingURL=index.d.ts.map