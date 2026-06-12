import { Request, Response, NextFunction } from "express";

export interface CustomError extends Error {
  status?: number;
  message: string;
}

export const errorHandler = (
  err: CustomError,
  req: Request,
  res: Response,
  next: NextFunction,
): void => {
  const status = err.status || 500;
  const message = err.message || "Internal Server Error";

  console.error(`[Error] Status: ${status}, Message: ${message}`);

  res.status(status).json({
    success: false,
    status,
    message,
    ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
  });
};

export const notFoundHandler = (req: Request, res: Response): void => {
  res.status(404).json({
    success: false,
    message: "Route not found",
  });
};
