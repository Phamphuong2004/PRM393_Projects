import { Server as HttpServer } from "http";
import { Server, Socket } from "socket.io";
import jwt from "jsonwebtoken";

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
          
          console.log(`[Socket] Authenticated user: ${userId}, total devices: ${this.userSockets.get(userId)!.size}`);
          
          socket.emit("authenticated", { status: "success" });
        } catch (error) {
          console.error(`[Socket] Auth error:`, error);
          socket.emit("auth_error", { message: "Invalid token" });
        }
      });

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
}
