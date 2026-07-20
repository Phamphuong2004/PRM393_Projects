import { Server as HttpServer } from "http";
import { Server, Socket } from "socket.io";
import jwt from "jsonwebtoken";
import Redis from "ioredis";

export class SocketService {
  private static io: Server;
  // Map of userId -> Set of socketIds
  private static userSockets: Map<string, Set<string>> = new Map();

  static init(server: HttpServer) {
    this.io = new Server(server, {
      cors: {
        origin: "*", // allow all origins or restrict to flutter app's origins
        methods: ["GET", "POST"],
      },
    });

    // Initialize Redis subscriber
    const redisUrl = process.env.REDIS_URL || "redis://localhost:6379";
    const redisSubscriber = new Redis(redisUrl);
    
    redisSubscriber.subscribe("realtime_notifications", (err, count) => {
      if (err) {
        console.error("[Socket] Redis Subscribe Error:", err);
      } else {
        console.log(`[Socket] Subscribed to ${count} Redis channel(s)`);
      }
    });

    redisSubscriber.on("message", (channel, message) => {
      if (channel === "realtime_notifications") {
        try {
          const data = JSON.parse(message);
          this.sendNotificationToUser(data.userId, data.notification);
        } catch (error) {
          console.error("[Socket] Failed to parse Redis message:", error);
        }
      }
    });

    this.io.on("connection", (socket: Socket) => {
      console.log(`[Socket] New connection: ${socket.id}`);

      // Handle Authentication event
      socket.on("authenticate", (token: string) => {
        try {
          const decoded = jwt.verify(
            token,
            process.env.JWT_SECRET || "your-secret-key"
          ) as { userId: string };

          // Register user's socket
          const userId = decoded.userId.toString();
          if (!this.userSockets.has(userId)) {
            this.userSockets.set(userId, new Set());
          }
          this.userSockets.get(userId)!.add(socket.id);
          
          // Store userId on the socket object for later use
          (socket as any).userId = userId;

          console.log(`[Socket] Authenticated user: ${userId}, total devices: ${this.userSockets.get(userId)!.size}`);
          
          socket.emit("authenticated", { status: "success" });
        } catch (error) {
          console.error(`[Socket] Auth error:`, error);
          socket.emit("auth_error", { message: "Invalid token" });
        }
      });

      // ─── Workspace Chat Rooms ──────────────────────────────────────────────────

      socket.on("join_workspace", (workspaceId: string) => {
        const room = `workspace:${workspaceId}`;
        socket.join(room);
        console.log(`[Socket] Socket ${socket.id} joined room ${room}`);
        socket.emit("joined_workspace", { workspaceId });
      });

      socket.on("leave_workspace", (workspaceId: string) => {
        const room = `workspace:${workspaceId}`;
        socket.leave(room);
        console.log(`[Socket] Socket ${socket.id} left room ${room}`);
      });

      // ─────────────────────────────────────────────────────────────────────────

      socket.on("disconnect", () => {
        // Remove user from map
        for (const [userId, sockets] of this.userSockets.entries()) {
          if (sockets.has(socket.id)) {
            sockets.delete(socket.id);
            if (sockets.size === 0) {
              this.userSockets.delete(userId);
            }
            console.log(`[Socket] User disconnected: ${userId}`);
            break;
          }
        }
      });
    });
  }

  static getIO() {
    if (!this.io) {
      throw new Error("Socket.io not initialized!");
    }
    return this.io;
  }

  static sendNotificationToUser(userId: string, notificationData: any) {
    if (!this.io) return;
    
    const sockets = this.userSockets.get(userId.toString());
    if (sockets && sockets.size > 0) {
      for (const socketId of sockets) {
        this.io.to(socketId).emit("new_notification", notificationData);
      }
      console.log(`[Socket] Sent notification to user ${userId} on ${sockets.size} devices`);
    }
  }

  /**
   * Broadcast a new chat message to all sockets in the workspace room.
   * The sender will also receive it (for multi-device sync).
   */
  static broadcastChatMessage(workspaceId: string, message: any) {
    if (!this.io) return;
    const room = `workspace:${workspaceId}`;
    this.io.to(room).emit("new_chat_message", message);
    console.log(`[Socket] Broadcast chat message to room ${room}`);
  }
}
