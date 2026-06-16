"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const database_1 = require("./config/database");
const errorHandler_1 = require("./middleware/errorHandler");
const logger_1 = require("./middleware/logger");
const swagger_1 = __importDefault(require("./config/swagger"));
// Import routes
const auth_1 = __importDefault(require("./routes/auth"));
const papers_1 = __importDefault(require("./routes/papers"));
const keywords_1 = __importDefault(require("./routes/keywords"));
const journals_1 = __importDefault(require("./routes/journals"));
const topics_1 = __importDefault(require("./routes/topics"));
const users_1 = __importDefault(require("./routes/users"));
const analysisRuns_1 = __importDefault(require("./routes/analysisRuns"));
const bookmarks_1 = __importDefault(require("./routes/bookmarks"));
const notifications_1 = __importDefault(require("./routes/notifications"));
const follows_1 = __importDefault(require("./routes/follows"));
const publicationTrends_1 = __importDefault(require("./routes/publicationTrends"));
const app = (0, express_1.default)();
const PORT = process.env.PORT || 5000;
// Middleware
app.use((0, helmet_1.default)());
app.use((0, cors_1.default)({
    origin: process.env.FRONTEND_URL || "http://localhost:5173",
    credentials: true,
}));
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
// Request logging middleware
app.use(logger_1.requestLogger);
// Connect to MongoDB
(0, database_1.connectDB)();
// Health check
app.get("/health", (req, res) => {
    res.json({ status: "OK", timestamp: new Date().toISOString() });
});
// Relax CSP only for Swagger docs so CDN assets can load
app.use(["/api-docs", "/api-docs/", "/api-docs.json"], (req, res, next) => {
    res.removeHeader("Content-Security-Policy");
    res.setHeader("Content-Security-Policy", [
        "default-src 'self'",
        "script-src 'self' 'unsafe-inline' https://unpkg.com",
        "style-src 'self' 'unsafe-inline' https://unpkg.com",
        "img-src 'self' data: https:",
        "connect-src 'self' https://unpkg.com",
        "font-src 'self' https://unpkg.com data:",
    ].join("; "));
    next();
});
// Swagger docs
app.get("/api-docs.json", (req, res) => {
    res.json(swagger_1.default);
});
app.get(["/api-docs", "/api-docs/"], (req, res) => {
    res.send(`<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Scientific Journal Trend Tracker API Docs</title>
    <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
    <style>
      html, body { margin: 0; padding: 0; height: 100%; }
      #swagger-ui { min-height: 100vh; }
    </style>
  </head>
  <body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-standalone-preset.js"></script>
    <script>
      window.onload = () => {
        window.ui = SwaggerUIBundle({
          url: "/api-docs.json",
          dom_id: "#swagger-ui",
          deepLinking: true,
          presets: [SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset],
          layout: "BaseLayout",
        });
      };
    </script>
  </body>
</html>`);
});
// API Routes
app.use("/api/auth", auth_1.default);
app.use("/api/papers", papers_1.default);
app.use("/api/keywords", keywords_1.default);
app.use("/api/journals", journals_1.default);
app.use("/api/topics", topics_1.default);
app.use("/api/users", users_1.default);
app.use("/api/analysis-runs", analysisRuns_1.default);
app.use("/api/bookmarks", bookmarks_1.default);
app.use("/api/notifications", notifications_1.default);
app.use("/api/follows", follows_1.default);
app.use("/api/publication-trends", publicationTrends_1.default);
// API Documentation
app.get("/api", (req, res) => {
    res.json({
        message: "Scientific Journal Trend Tracker API",
        version: "1.0.0",
        endpoints: {
            auth: "/api/auth",
            papers: "/api/papers",
            keywords: "/api/keywords",
            journals: "/api/journals",
            topics: "/api/topics",
            users: "/api/users",
            "analysis-runs": "/api/analysis-runs",
            bookmarks: "/api/bookmarks",
            notifications: "/api/notifications",
            follows: "/api/follows",
            "publication-trends": "/api/publication-trends",
        },
    });
});
// Error logging middleware
app.use(logger_1.errorLogger);
// Error handling
app.use(errorHandler_1.notFoundHandler);
app.use(errorHandler_1.errorHandler);
// Start server
app.listen(PORT, () => {
    console.log(`\n🚀 Server running on http://localhost:${PORT}`);
    console.log(`📚 API docs: http://localhost:${PORT}/api\n`);
});
exports.default = app;
//# sourceMappingURL=index.js.map