import "dotenv/config";
import express from "express";
import cors from "cors";
import helmet from "helmet";
import { connectDB } from "./config/database";
import { errorHandler, notFoundHandler } from "./middleware/errorHandler";
import { requestLogger, errorLogger } from "./middleware/logger";
import http from "http";

// Import routes
import authRoutes from "./routes/auth";
import usersRoutes from "./routes/users";
import bookmarksRoutes from "./routes/bookmarks";
import followsRoutes from "./routes/follows";

const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 5001;

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

// Connect to MongoDB
connectDB();

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "OK", service: "Auth Service", timestamp: new Date().toISOString() });
});

// API Routes
app.use("/api/auth", authRoutes);
app.use("/api/users", usersRoutes);
app.use("/api/bookmarks", bookmarksRoutes);
app.use("/api/follows", followsRoutes);

// Error logging middleware
app.use(errorLogger);

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

// Start server
server.listen(PORT, () => {
  console.log(`\n🚀 Auth Service running on http://localhost:${PORT}`);
});

export default app;
