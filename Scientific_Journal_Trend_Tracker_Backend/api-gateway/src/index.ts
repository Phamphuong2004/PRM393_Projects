import "dotenv/config";
import express from "express";
import cors from "cors";
import helmet from "helmet";
import { createProxyMiddleware } from "http-proxy-middleware";

const app = express();
const PORT = process.env.PORT || 5000;

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

// Define service URLs
// In docker-compose, these will resolve to the container names
// On Railway, these can resolve to the internal domains if set in env vars, otherwise defaults to localhost for dev
const AUTH_SERVICE_URL = process.env.AUTH_SERVICE_URL || "http://auth-service:5001";
const CORE_SERVICE_URL = process.env.CORE_SERVICE_URL || "http://core-service:5002";
const INTERACTION_SERVICE_URL = process.env.INTERACTION_SERVICE_URL || "http://interaction-service:5003";
const ADMIN_SERVICE_URL = process.env.ADMIN_SERVICE_URL || "http://admin-service:5004";

// Setup proxies
// 1. Auth Service Routes
app.use(
  ["/api/auth", "/api/users", "/api/bookmarks", "/api/follows"],
  createProxyMiddleware({
    target: AUTH_SERVICE_URL,
    changeOrigin: true,
  })
);

// 2. Core Service Routes
app.use(
  [
    "/api/papers",
    "/api/keywords",
    "/api/journals",
    "/api/institutions",
    "/api/topics",
    "/api/publication-trends",
    "/api/authors"
  ],
  createProxyMiddleware({
    target: CORE_SERVICE_URL,
    changeOrigin: true,
  })
);

// 3. Interaction Service & Socket.io Routes
app.use(
  [
    "/api/workspaces",
    "/api/chat",
    "/api/dashboard",
    "/api/analysis-runs",
    "/socket.io"
  ],
  createProxyMiddleware({
    target: INTERACTION_SERVICE_URL,
    changeOrigin: true,
    ws: true, // Enable WebSocket proxying
  })
);

// 4. Admin & Notification Service Routes
app.use(
  ["/api/notifications", "/api/admin", "/api/sync-logs"],
  createProxyMiddleware({
    target: ADMIN_SERVICE_URL,
    changeOrigin: true,
  })
);

// Health check for Gateway
app.get("/health", (req, res) => {
  res.json({ status: "OK", service: "API Gateway", timestamp: new Date().toISOString() });
});

// Start Gateway
app.listen(PORT, () => {
  console.log(`\n🚀 API Gateway running on port ${PORT}`);
  console.log(`Routes mapping:`);
  console.log(`- Auth -> ${AUTH_SERVICE_URL}`);
  console.log(`- Core -> ${CORE_SERVICE_URL}`);
  console.log(`- Interaction -> ${INTERACTION_SERVICE_URL}`);
  console.log(`- Admin -> ${ADMIN_SERVICE_URL}\n`);
});
