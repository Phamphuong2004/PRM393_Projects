import "dotenv/config";
import express from "express";
import cors from "cors";
import helmet from "helmet";
import { connectDB } from "./config/database";
import { errorHandler, notFoundHandler } from "./middleware/errorHandler";
import { requestLogger, errorLogger } from "./middleware/logger";
import http from "http";
import { SocketService } from "./services/SocketService";

// Import routes
import workspacesRoutes from "./routes/workspaces";
import chatRoutes from "./routes/chat";
import analysisRunsRoutes from "./routes/analysisRuns";
import dashboardRoutes from "./routes/dashboard";
import { AnalysisWorker } from "./workers/AnalysisWorker";

const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 5003;

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
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Request logging middleware
app.use(requestLogger);

// Initialize Socket.io
SocketService.init(server as any);

// Connect to MongoDB
connectDB();

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "OK", service: "Interaction Service", timestamp: new Date().toISOString() });
});

// API Routes
app.use("/api/workspaces", workspacesRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/analysis-runs", analysisRunsRoutes);
app.use("/api/dashboard", dashboardRoutes);

// Error logging middleware
app.use(errorLogger);

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

// Start Background Workers
AnalysisWorker.start();

// Start server
server.listen(PORT, () => {
  console.log(`\n🚀 Interaction Service running on http://localhost:${PORT}`);
});

export default app;
