import { Server as HttpServer } from "http";
import { Server, Socket } from "socket.io";
import jwt from "jsonwebtoken";

export class SocketService {
  private static io: Server;
  // Map of userId -> socketId
  private static userSockets: Map<string, string> = new Map();

  static init(server: HttpServer) {
    this.io = new Server(server, {
      cors: {
        origin: "*", // allow all origins or restrict to flutter app's origins
        methods: ["GET", "POST"],
      },
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
          this.userSockets.set(decoded.userId, socket.id);
          console.log(`[Socket] Authenticated user: ${decoded.userId}`);
          
          socket.emit("authenticated", { status: "success" });
        } catch (error) {
          console.error(`[Socket] Auth error:`, error);
          socket.emit("auth_error", { message: "Invalid token" });
        }
      });

      socket.on("disconnect", () => {
        // Remove user from map
        for (const [userId, socketId] of this.userSockets.entries()) {
          if (socketId === socket.id) {
            this.userSockets.delete(userId);
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
    
    const socketId = this.userSockets.get(userId.toString());
    if (socketId) {
      this.io.to(socketId).emit("new_notification", notificationData);
      console.log(`[Socket] Sent notification to user ${userId}`);
    }
  }
}
