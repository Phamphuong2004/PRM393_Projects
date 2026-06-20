import { Router } from "express";
import { WorkspaceController } from "../controllers/WorkspaceController";
import { authMiddleware, uploadPaperPdf } from "../middleware";

const router = Router();

// Apply auth middleware to all workspace routes
router.use(authMiddleware);

router.post("/", WorkspaceController.createWorkspace);
router.get("/", WorkspaceController.getWorkspaces);
router.get("/:id", WorkspaceController.getWorkspaceById);
router.post("/:id/members", WorkspaceController.addMember);
router.post("/:id/papers", WorkspaceController.addPaper);
router.post("/:id/papers/:paperId/pdf", uploadPaperPdf.single("pdf"), WorkspaceController.uploadPdf);
router.get("/:id/papers", WorkspaceController.getWorkspacePapers);
// router.get("/:id/trends", WorkspaceController.getTrends); // To be implemented if needed
router.post("/:id/notes", WorkspaceController.createNote);
router.get("/:id/notes", WorkspaceController.getNotes);
router.post("/:id/alerts", WorkspaceController.createAlert);
router.get("/:id/alerts", WorkspaceController.getAlerts);

export default router;
