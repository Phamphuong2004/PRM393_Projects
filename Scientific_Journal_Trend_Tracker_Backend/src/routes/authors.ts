import { Router, Request, Response } from "express";
import {
  authMiddleware,
  roleMiddleware,
  rateLimit,
  rateLimits,
} from "../middleware";
import {
  validateCreateAuthor,
  validateIdParam,
  validateInputs,
} from "../middleware";
import { AuthorService } from "../services";

const router = Router();

// Apply rate limiting
router.use(rateLimit(rateLimits.read));

// Get all authors (paginated + search)
router.get("/", async (req: Request, res: Response): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const search = req.query.search as string;

    const { authors, total, pages } = await AuthorService.getAllAuthors(
      page,
      limit,
      search
    );

    res.json({
      authors,
      pagination: { page, limit, total, pages },
    });
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// Get author by ID
router.get(
  "/:id",
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const author = await AuthorService.getAuthorById(req.params.id);
      res.json(author);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Create author (admin/researcher only)
router.post(
  "/",
  authMiddleware,
  roleMiddleware(["admin", "researcher"]),
  rateLimit(rateLimits.write),
  validateCreateAuthor,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const author = await AuthorService.createAuthor(req.body);
      res.status(201).json(author);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Update author (admin/researcher only)
router.put(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin", "researcher"]),
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const author = await AuthorService.updateAuthor(req.params.id, req.body);
      res.json(author);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Delete author (admin only)
router.delete(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      await AuthorService.deleteAuthor(req.params.id);
      res.json({ message: "Author deleted" });
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

export default router;
