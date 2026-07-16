import { Router, Request, Response } from "express";
import {
  authMiddleware,
  roleMiddleware,
  rateLimit,
  rateLimits,
} from "../middleware";
import {
  validateCreateTopic,
  validateIdParam,
  validateInputs,
} from "../middleware";
import { TopicService } from "../services/TopicService";

const router = Router();

// Apply rate limiting
router.use(rateLimit(rateLimits.read));

// Get all topics with pagination
router.get("/", async (req: Request, res: Response): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;

    const { topics, total, pages } = await TopicService.getAllTopics(
      page,
      limit,
    );

    res.json({
      topics,
      pagination: { page, limit, total, pages },
    });
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// Get topic by ID
router.get(
  "/:id",
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const topic = await TopicService.getTopicById(req.params.id);
      res.json(topic);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Create topic (admin/researcher only)
router.post(
  "/",
  authMiddleware,
  roleMiddleware(["admin", "researcher"]),
  rateLimit(rateLimits.write),
  validateCreateTopic,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const topic = await TopicService.createTopic(req.body);
      res.status(201).json(topic);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Get emerging topics
router.get(
  "/emerging/list",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const topics = await TopicService.getEmergingTopics();
      res.json(topics);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Update topic (admin only)
router.put(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const topic = await TopicService.updateTopic(req.params.id, req.body);
      res.json(topic);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Delete topic (admin only)
router.delete(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      await TopicService.deleteTopic(req.params.id);
      res.json({ message: "Topic deleted" });
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

export default router;


