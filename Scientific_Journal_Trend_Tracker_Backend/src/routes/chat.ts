import { Router, Request, Response } from "express";
import { authMiddleware, rateLimit, rateLimits } from "../middleware";
import { ChatSession } from "../models";

const router = Router();

// Apply rate limiting for chat requests
router.use(rateLimit(rateLimits.api));

// Get all chat sessions for user
router.get(
  "/sessions",
  authMiddleware,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const sessions = await ChatSession.find({ user: req.userId })
        .sort({ updatedAt: -1 })
        .select("-messages");
      res.json(sessions);
    } catch (error: any) {
      res.status(500).json({ message: "Error fetching sessions", error: error.message });
    }
  }
);

// Get specific chat session
router.get(
  "/sessions/:id",
  authMiddleware,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const session = await ChatSession.findOne({ _id: req.params.id, user: req.userId });
      if (!session) {
        res.status(404).json({ message: "Session not found" });
        return;
      }
      res.json(session);
    } catch (error: any) {
      res.status(500).json({ message: "Error fetching session", error: error.message });
    }
  }
);

// Delete specific chat session
router.delete(
  "/sessions/:id",
  authMiddleware,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const session = await ChatSession.findOneAndDelete({ _id: req.params.id, user: req.userId });
      if (!session) {
        res.status(404).json({ message: "Session not found" });
        return;
      }
      res.json({ message: "Session deleted successfully" });
    } catch (error: any) {
      res.status(500).json({ message: "Error deleting session", error: error.message });
    }
  }
);

// Endpoint to handle AI Chat interactions
router.post(
  "/ask",
  authMiddleware,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const { question, files, sessionId } = req.body;
      const userId = req.userId;

      if (!question) {
        res.status(400).json({ message: "Question is required." });
        return;
      }

      let session: any = null;
      let chat_history: any[] = [];
      if (sessionId) {
        session = await ChatSession.findOne({ _id: sessionId, user: userId });
        if (session) {
          chat_history = session.messages.map((m: any) => ({ role: m.role, content: m.content }));
          session.messages.push({ role: "user", content: question, files: files || [], createdAt: new Date() });
          await session.save();
        }
      }

      if (!session) {
        session = new ChatSession({
          user: userId,
          title: question.substring(0, 30) + (question.length > 30 ? "..." : ""),
          messages: [{ role: "user", content: question, files: files || [], createdAt: new Date() }]
        });
        await session.save();
      }

      // Forward request to Python AI Microservice
      const aiServiceUrl = process.env.AI_SERVICE_URL || "http://localhost:8000";
      const response = await fetch(`${aiServiceUrl}/api/v1/chat/ask`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          question: question,
          user_id: userId,
          files: files || [],
          chat_history: chat_history
        }),
      });

      if (!response.ok) {
        throw new Error(`AI Service returned ${response.status}: ${response.statusText}`);
      }

      const data: any = await response.json();
      
      // Save AI response to session
      session.messages.push({ role: "assistant", content: data.answer || "No response generated.", createdAt: new Date() });
      await session.save();

      res.json({ ...data, sessionId: session._id });
    } catch (error: any) {
      console.error("AI Chat Proxy Error:", error);
      res.status(500).json({ message: "Failed to communicate with AI Service.", error: error.message });
    }
  }
);

export default router;
