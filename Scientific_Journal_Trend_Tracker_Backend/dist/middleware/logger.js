"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSlowRequests = exports.getErrorLogsForDate = exports.getLogsForDate = exports.errorLogger = exports.requestLogger = void 0;
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
// Ensure logs directory exists
const logsDir = path_1.default.join(process.cwd(), "logs");
if (!fs_1.default.existsSync(logsDir)) {
    fs_1.default.mkdirSync(logsDir, { recursive: true });
}
/**
 * Request logging middleware
 */
const requestLogger = (req, res, next) => {
    const startTime = Date.now();
    // Log request info
    const method = req.method;
    const url = req.originalUrl;
    const ip = req.ip || req.socket.remoteAddress || "unknown";
    const userAgent = req.get("user-agent") || "unknown";
    // Override res.json and res.send to capture status
    const originalJson = res.json.bind(res);
    const originalSend = res.send.bind(res);
    res.json = function (data) {
        logRequest(method, url, res.statusCode, Date.now() - startTime, req.userId, req.userRole, ip, userAgent);
        return originalJson(data);
    };
    res.send = function (data) {
        logRequest(method, url, res.statusCode, Date.now() - startTime, req.userId, req.userRole, ip, userAgent);
        return originalSend(data);
    };
    next();
};
exports.requestLogger = requestLogger;
/**
 * Log request to file and console
 */
function logRequest(method, url, statusCode, responseTime, userId, userRole, ip, userAgent) {
    const log = {
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
    const logFile = path_1.default.join(logsDir, `requests-${getDateString()}.log`);
    fs_1.default.appendFileSync(logFile, JSON.stringify(log) + "\n");
    // Log to console in development
    if (process.env.NODE_ENV !== "production") {
        const color = getStatusColor(statusCode);
        console.log(`${color}[${method}] ${url} - ${statusCode} - ${responseTime}ms${"\x1b[0m"}`);
    }
    // Log slow requests
    if (responseTime > 5000) {
        const slowLogFile = path_1.default.join(logsDir, "slow-requests.log");
        fs_1.default.appendFileSync(slowLogFile, JSON.stringify(log) + "\n");
    }
}
/**
 * Get status code color for console output
 */
function getStatusColor(statusCode) {
    if (statusCode >= 500)
        return "\x1b[31m"; // Red
    if (statusCode >= 400)
        return "\x1b[33m"; // Yellow
    if (statusCode >= 300)
        return "\x1b[36m"; // Cyan
    if (statusCode >= 200)
        return "\x1b[32m"; // Green
    return "\x1b[0m"; // Default
}
/**
 * Get formatted date string for log file naming
 */
function getDateString() {
    const date = new Date();
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
}
/**
 * Error logging middleware
 */
const errorLogger = (error, req, res, next) => {
    const errorLog = {
        timestamp: new Date().toISOString(),
        method: req.method,
        url: req.originalUrl,
        ip: req.ip || req.socket.remoteAddress || "unknown",
        userId: req.userId,
        message: error.message || error.toString(),
        stack: error.stack,
        status: error.status || 500,
    };
    // Log to file
    const errorLogFile = path_1.default.join(logsDir, `errors-${getDateString()}.log`);
    fs_1.default.appendFileSync(errorLogFile, JSON.stringify(errorLog) + "\n");
    // Log to console
    console.error("\x1b[31m[ERROR]\x1b[0m", errorLog.message);
    next(error);
};
exports.errorLogger = errorLogger;
/**
 * Get logs by date
 */
const getLogsForDate = (date) => {
    const logFile = path_1.default.join(logsDir, `requests-${date}.log`);
    if (!fs_1.default.existsSync(logFile)) {
        return [];
    }
    return fs_1.default
        .readFileSync(logFile, "utf-8")
        .split("\n")
        .filter((line) => line.trim())
        .map((line) => {
        try {
            return JSON.parse(line);
        }
        catch {
            return null;
        }
    })
        .filter((log) => log !== null);
};
exports.getLogsForDate = getLogsForDate;
/**
 * Get error logs by date
 */
const getErrorLogsForDate = (date) => {
    const errorLogFile = path_1.default.join(logsDir, `errors-${date}.log`);
    if (!fs_1.default.existsSync(errorLogFile)) {
        return [];
    }
    return fs_1.default
        .readFileSync(errorLogFile, "utf-8")
        .split("\n")
        .filter((line) => line.trim())
        .map((line) => {
        try {
            return JSON.parse(line);
        }
        catch {
            return null;
        }
    })
        .filter((log) => log !== null);
};
exports.getErrorLogsForDate = getErrorLogsForDate;
/**
 * Get slow request logs
 */
const getSlowRequests = () => {
    const slowLogFile = path_1.default.join(logsDir, "slow-requests.log");
    if (!fs_1.default.existsSync(slowLogFile)) {
        return [];
    }
    return fs_1.default
        .readFileSync(slowLogFile, "utf-8")
        .split("\n")
        .filter((line) => line.trim())
        .map((line) => {
        try {
            return JSON.parse(line);
        }
        catch {
            return null;
        }
    })
        .filter((log) => log !== null);
};
exports.getSlowRequests = getSlowRequests;
//# sourceMappingURL=logger.js.map