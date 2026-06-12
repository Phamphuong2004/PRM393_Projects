import { Request, Response, NextFunction } from "express";
export interface CustomError extends Error {
    status?: number;
    message: string;
}
export declare const errorHandler: (err: CustomError, req: Request, res: Response, next: NextFunction) => void;
export declare const notFoundHandler: (req: Request, res: Response) => void;
//# sourceMappingURL=errorHandler.d.ts.map