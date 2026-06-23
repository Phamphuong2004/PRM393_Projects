import "dotenv/config";
import express from "express";
import path from "path";
import cors from "cors";
import helmet from "helmet";
import { connectDB } from "./config/database";
import { errorHandler, notFoundHandler } from "./middleware/errorHandler";
import { requestLogger, errorLogger } from "./middleware/logger";
import swaggerSpec from "./config/swagger";
import { initCronJobs } from "./scripts/cron";

// Import routes
import authRoutes from "./routes/auth";
import papersRoutes from "./routes/papers";
import keywordsRoutes from "./routes/keywords";
import journalsRoutes from "./routes/journals";
import institutionsRoutes from "./routes/institutions";
import topicsRoutes from "./routes/topics";
import usersRoutes from "./routes/users";
import analysisRunsRoutes from "./routes/analysisRuns";
import bookmarksRoutes from "./routes/bookmarks";
import notificationsRoutes from "./routes/notifications";
import followsRoutes from "./routes/follows";
import publicationTrendsRoutes from "./routes/publicationTrends";
import dashboardRoutes from "./routes/dashboard";
import adminRoutes from "./routes/admin";
import authorsRoutes from "./routes/authors";
import syncLogsRoutes from "./routes/syncLogs";
import workspacesRoutes from "./routes/workspaces";

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(helmet({
  crossOriginResourcePolicy: false,
}));
app.use(
  cors({
    origin: function (origin, callback) {
      callback(null, true);
    },
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization", "Accept", "Origin", "X-Requested-With"],
    credentials: true,
  }),
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded files (PDFs, etc.) as static assets
app.use("/uploads", express.static(path.join(process.cwd(), "uploads")));

// Request logging middleware
app.use(requestLogger);

// Connect to MongoDB
connectDB();

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "OK", timestamp: new Date().toISOString() });
});

// Relax CSP only for Swagger docs so CDN assets can load
app.use(["/api-docs", "/api-docs/", "/api-docs.json"], (req, res, next) => {
  res.removeHeader("Content-Security-Policy");
  res.setHeader(
    "Content-Security-Policy",
    [
      "default-src 'self'",
      "script-src 'self' 'unsafe-inline' https://unpkg.com",
      "style-src 'self' 'unsafe-inline' https://unpkg.com",
      "img-src 'self' data: https:",
      "connect-src 'self' https://unpkg.com",
      "font-src 'self' https://unpkg.com data:",
    ].join("; "),
  );
  next();
});

// Swagger docs
app.get("/api-docs.json", (req, res) => {
  res.json(swaggerSpec);
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
app.use("/api/auth", authRoutes);
app.use("/api/papers", papersRoutes);
app.use("/api/keywords", keywordsRoutes);
app.use("/api/journals", journalsRoutes);
app.use("/api/institutions", institutionsRoutes);
app.use("/api/topics", topicsRoutes);
app.use("/api/users", usersRoutes);
app.use("/api/analysis-runs", analysisRunsRoutes);
app.use("/api/bookmarks", bookmarksRoutes);
app.use("/api/notifications", notificationsRoutes);
app.use("/api/follows", followsRoutes);
app.use("/api/publication-trends", publicationTrendsRoutes);
app.use("/api/dashboard", dashboardRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/authors", authorsRoutes);
app.use("/api/sync-logs", syncLogsRoutes);
app.use("/api/workspaces", workspacesRoutes);

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
      institutions: "/api/institutions",
      topics: "/api/topics",
      users: "/api/users",
      "analysis-runs": "/api/analysis-runs",
      bookmarks: "/api/bookmarks",
      notifications: "/api/notifications",
      follows: "/api/follows",
      "publication-trends": "/api/publication-trends",
      dashboard: "/api/dashboard",
      admin: "/api/admin",
      authors: "/api/authors",
      "sync-logs": "/api/sync-logs",
      workspaces: "/api/workspaces",
    },
  });
});

// Error logging middleware
app.use(errorLogger);

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

// Start server
app.listen(PORT, () => {
  console.log(`\n🚀 Server running on http://localhost:${PORT}`);
  console.log(`📚 API docs: http://localhost:${PORT}/api\n`);
  
  // Initialize Background Tasks
  initCronJobs();
});

export default app;
