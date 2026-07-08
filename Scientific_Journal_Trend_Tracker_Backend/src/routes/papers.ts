import { Router, Request, Response } from "express";
import {
  authMiddleware,
  roleMiddleware,
  rateLimit,
  rateLimits,
} from "../middleware";
import {
  validateCreatePaper,
  validateIdParam,
  validateInputs,
} from "../middleware";
import { PaperService } from "../services";
import { PaperController } from "../controllers/PaperController";

const router = Router();

// Apply rate limiting
router.use(rateLimit(rateLimits.read));

// Get all papers with pagination
router.get("/", async (req: Request, res: Response): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;

    const { papers, total, pages } = await PaperService.getAllPapers(
      page,
      limit,
    );

    res.json({
      papers,
      pagination: { page, limit, total, pages },
    });
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

// External Search papers
router.get(
  "/external/search",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const { q, limit, source } = req.query;

      if (!q || !String(q).trim()) {
        res.status(400).json({ message: "Search query is required" });
        return;
      }

      const parsedLimit = limit ? parseInt(limit as string) : 10;
      const result = await PaperService.searchExternalPapers(String(q), parsedLimit, source as string);

      res.json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Import external paper
router.post(
  "/import",
  authMiddleware,
  rateLimit(rateLimits.write),
  async (req: Request, res: Response): Promise<void> => {
    try {
      await PaperController.importExternalPaper(req, res);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Get paper by ID
router.get(
  "/:id",
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const paper = await PaperService.getPaperById(req.params.id);
      res.json(paper);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Create paper (admin/researcher only)
router.post(
  "/",
  authMiddleware,
  roleMiddleware(["admin", "researcher"]),
  rateLimit(rateLimits.write),
  validateCreatePaper,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const paper = await PaperService.createPaper(req.body);
      res.status(201).json(paper);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Update paper (admin only)
router.put(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const paper = await PaperService.updatePaper(req.params.id, req.body);
      res.json(paper);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Delete paper (admin only)
router.delete(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  rateLimit(rateLimits.write),
  validateIdParam,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      await PaperService.deletePaper(req.params.id);
      res.json({ message: "Paper deleted" });
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Search papers
router.get(
  "/search/query",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const { q, year, journalId, page, limit, sort } = req.query;

      if (!q || !String(q).trim()) {
        res.status(400).json({ message: "Search query is required" });
        return;
      }

      const sortValue = (sort as string) || "-publicationYear";
      const sortField = sortValue.replace(/^-/, "");
      const sortDirection = sortValue.startsWith("-") ? -1 : 1;
      const normalizedSortField =
        sortField === "citationCount" ? "citationCount" : "publicationYear";

      const result = await PaperService.searchPapers(
        q as string,
        year ? parseInt(year as string) : undefined,
        journalId as string,
        page ? parseInt(page as string) : 1,
        limit ? parseInt(limit as string) : 10,
        normalizedSortField,
        sortDirection,
      );

      res.json({
        ...result,
        pagination: {
          page: page ? parseInt(page as string) : 1,
          limit: limit ? parseInt(limit as string) : 10,
          total: result.total,
          pages: result.pages,
        },
      });
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

export default router;
