import { Request, Response, NextFunction } from "express";
import fs from "fs";
import path from "path";

// Ensure logs directory exists
const logsDir = path.join(process.cwd(), "logs");
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

interface RequestLog {
  timestamp: string;
  method: string;
  url: string;
  statusCode: number;
  responseTime: number;
  userId?: string;
  userRole?: string;
  ip: string;
  userAgent: string;
}

/**
 * Request logging middleware
 */
export const requestLogger = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const startTime = Date.now();

  // Log request info
  const method = req.method;
  const url = req.originalUrl;
  const ip = req.ip || req.socket.remoteAddress || "unknown";
  const userAgent = req.get("user-agent") || "unknown";

  // Override res.json and res.send to capture status
  const originalJson = res.json.bind(res);
  const originalSend = res.send.bind(res);

  res.json = function (data: any) {
    logRequest(
      method,
      url,
      res.statusCode,
      Date.now() - startTime,
      (req as any).userId,
      (req as any).userRole,
      ip,
      userAgent,
    );
    return originalJson(data);
  };

  res.send = function (data: any) {
    logRequest(
      method,
      url,
      res.statusCode,
      Date.now() - startTime,
      (req as any).userId,
      (req as any).userRole,
      ip,
      userAgent,
    );
    return originalSend(data);
  };

  next();
};

/**
 * Log request to file and console
 */
function logRequest(
  method: string,
  url: string,
  statusCode: number,
  responseTime: number,
  userId?: string,
  userRole?: string,
  ip?: string,
  userAgent?: string,
) {
  const log: RequestLog = {
    timestamp: new Date().toISOString(),
    method,
    url,
    statusCode,
    responseTime,
    userId,
    userRole,
    ip: ip || "unknown",
    userAgent: userAgent || "unknown",
  };

  // Log to file
  const logFile = path.join(logsDir, `requests-${getDateString()}.log`);
  fs.appendFileSync(logFile, JSON.stringify(log) + "\n");

  // Log to console in development
  if (process.env.NODE_ENV !== "production") {
    const color = getStatusColor(statusCode);
    console.log(
      `${color}[${method}] ${url} - ${statusCode} - ${responseTime}ms${"\x1b[0m"}`,
    );
  }

  // Log slow requests
  if (responseTime > 5000) {
    const slowLogFile = path.join(logsDir, "slow-requests.log");
    fs.appendFileSync(slowLogFile, JSON.stringify(log) + "\n");
  }
}

/**
 * Get status code color for console output
 */
function getStatusColor(statusCode: number): string {
  if (statusCode >= 500) return "\x1b[31m"; // Red
  if (statusCode >= 400) return "\x1b[33m"; // Yellow
  if (statusCode >= 300) return "\x1b[36m"; // Cyan
  if (statusCode >= 200) return "\x1b[32m"; // Green
  return "\x1b[0m"; // Default
}

/**
 * Get formatted date string for log file naming
 */
function getDateString(): string {
  const date = new Date();
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
}

/**
 * Error logging middleware
 */
export const errorLogger = (
  error: any,
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const errorLog = {
    timestamp: new Date().toISOString(),
    method: req.method,
    url: req.originalUrl,
    ip: req.ip || req.socket.remoteAddress || "unknown",
    userId: (req as any).userId,
    message: error.message || error.toString(),
    stack: error.stack,
    status: error.status || 500,
  };

  // Log to file
  const errorLogFile = path.join(logsDir, `errors-${getDateString()}.log`);
  fs.appendFileSync(errorLogFile, JSON.stringify(errorLog) + "\n");

  // Log to console
  console.error("\x1b[31m[ERROR]\x1b[0m", errorLog.message);

  next(error);
};

/**
 * Get logs by date
 */
export const getLogsForDate = (date: string): string[] => {
  const logFile = path.join(logsDir, `requests-${date}.log`);
  if (!fs.existsSync(logFile)) {
    return [];
  }

  return fs
    .readFileSync(logFile, "utf-8")
    .split("\n")
    .filter((line) => line.trim())
    .map((line) => {
      try {
        return JSON.parse(line);
      } catch {
        return null;
      }
    })
    .filter((log) => log !== null);
};

/**
 * Get error logs by date
 */
export const getErrorLogsForDate = (date: string) => {
  const errorLogFile = path.join(logsDir, `errors-${date}.log`);
  if (!fs.existsSync(errorLogFile)) {
    return [];
  }

  return fs
    .readFileSync(errorLogFile, "utf-8")
    .split("\n")
    .filter((line) => line.trim())
    .map((line) => {
      try {
        return JSON.parse(line);
      } catch {
        return null;
      }
    })
    .filter((log) => log !== null);
};

/**
 * Get slow request logs
 */
export const getSlowRequests = (): string[] => {
  const slowLogFile = path.join(logsDir, "slow-requests.log");
  if (!fs.existsSync(slowLogFile)) {
    return [];
  }

  return fs
    .readFileSync(slowLogFile, "utf-8")
    .split("\n")
    .filter((line) => line.trim())
    .map((line) => {
      try {
        return JSON.parse(line);
      } catch {
        return null;
      }
    })
    .filter((log) => log !== null);
};
