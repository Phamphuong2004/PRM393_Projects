import { Router } from "express";
import { WorkspaceController } from "../controllers/WorkspaceController";
import { authMiddleware, uploadPaperPdf } from "../middleware";

const router = Router();

// Apply auth middleware to all workspace routes
router.use(authMiddleware);

router.post("/", WorkspaceController.createWorkspace);
router.get("/", WorkspaceController.getWorkspaces);
router.put("/:id", WorkspaceController.updateWorkspace);
router.delete("/:id", WorkspaceController.deleteWorkspace);
router.get("/:id", WorkspaceController.getWorkspaceById);
router.post("/:id/members", WorkspaceController.addMember);
router.delete("/:id/members/:userId", WorkspaceController.removeMember);
router.post("/:id/papers", WorkspaceController.addPaper);
router.delete("/:id/papers/:paperId", WorkspaceController.removePaper);
router.post("/:id/papers/:paperId/pdf", uploadPaperPdf.single("pdf"), WorkspaceController.uploadPdf);
router.delete("/:id/papers/:paperId/pdf", WorkspaceController.deletePdf);
router.get("/:id/papers", WorkspaceController.getWorkspacePapers);
// router.get("/:id/trends", WorkspaceController.getTrends); // To be implemented if needed
router.post("/:id/notes", WorkspaceController.createNote);
router.get("/:id/notes", WorkspaceController.getNotes);
router.put("/:id/notes/:noteId", WorkspaceController.updateNote);
router.delete("/:id/notes/:noteId", WorkspaceController.deleteNote);
router.post("/:id/alerts", WorkspaceController.createAlert);
router.get("/:id/alerts", WorkspaceController.getAlerts);
router.delete("/:id/alerts/:alertId", WorkspaceController.deleteAlert);

export default router;
