import { Request, Response } from "express";
import fs from "fs";
import path from "path";
import { WorkspaceService } from "../services/WorkspaceService";
import { uploadPdfBuffer, isCloudinaryConfigured } from "../config/cloudinary";

export class WorkspaceController {
  static async createWorkspace(req: Request, res: Response) {
    try {
      const workspace = await WorkspaceService.createWorkspace(req.userId as string, req.body);
      res.status(201).json({ success: true, data: workspace });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async updateWorkspace(req: Request, res: Response) {
    try {
      const workspace = await WorkspaceService.updateWorkspace(req.params.id, req.userId as string, req.body);
      res.json({ success: true, data: workspace });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async deleteWorkspace(req: Request, res: Response) {
    try {
      const result = await WorkspaceService.deleteWorkspace(req.params.id, req.userId as string);
      res.json({ success: true, ...result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async getWorkspaces(req: Request, res: Response) {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const result = await WorkspaceService.getWorkspaces(req.userId as string, page, limit);
      res.json({ success: true, ...result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async getPendingInvitations(req: Request, res: Response) {
    try {
      const result = await WorkspaceService.getPendingInvitations(req.userId as string);
      res.json({ success: true, data: result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async respondToInvite(req: Request, res: Response) {
    try {
      const { action } = req.body;
      const result = await WorkspaceService.respondToInvite(req.params.id, req.userId as string, action);
      res.json({ success: true, data: result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async getWorkspaceById(req: Request, res: Response) {
    try {
      const result = await WorkspaceService.getWorkspaceById(req.params.id, req.userId as string, req.headers.authorization);
      res.json({ success: true, data: result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async addMember(req: Request, res: Response) {
    try {
      const { email, role } = req.body;
      const workspace = await WorkspaceService.addMember(
        req.params.id,
        req.userId as string,
        email,
        role,
        req.headers.authorization
      );
      res.json({ success: true, data: workspace });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async removeMember(req: Request, res: Response) {
    try {
      const workspace = await WorkspaceService.removeMember(req.params.id, req.userId as string, req.params.userId);
      res.json({ success: true, data: workspace });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async leaveWorkspace(req: Request, res: Response) {
    try {
      const workspace = await WorkspaceService.removeMember(req.params.id, req.userId as string, req.userId as string);
      res.json({ success: true, data: workspace });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async addPaper(req: Request, res: Response) {
    try {
      const wp = await WorkspaceService.addPaper(req.params.id, req.userId as string, req.body);
      res.status(201).json({ success: true, data: wp });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async removePaper(req: Request, res: Response) {
    try {
      const result = await WorkspaceService.removePaper(req.params.id, req.userId as string, req.params.paperId);
      res.json({ success: true, ...result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async getWorkspacePapers(req: Request, res: Response) {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const tag = req.query.tag as string;
      const result = await WorkspaceService.getWorkspacePapers(req.params.id, req.userId as string, page, limit, tag, req.headers.authorization);
      res.json({ success: true, ...result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async uploadPdf(req: Request, res: Response) {
    try {
      const file = (req as any).file;
      if (!file) throw { status: 400, message: "No PDF file uploaded" };

      let pdfUrl = "";
      if (isCloudinaryConfigured()) {
        // Stream the in-memory buffer to Cloudinary and store the absolute URL.
        pdfUrl = await uploadPdfBuffer(file.buffer, file.originalname);
      } else {
        // Fallback to local storage
        const uploadsDir = path.join(process.cwd(), "uploads");
        if (!fs.existsSync(uploadsDir)) {
          fs.mkdirSync(uploadsDir, { recursive: true });
        }
        const fileName = `${Date.now()}-${file.originalname.replace(/\s+/g, "_")}`;
        const filePath = path.join(uploadsDir, fileName);
        await fs.promises.writeFile(filePath, file.buffer);
        pdfUrl = `/uploads/${fileName}`;
      }

      const result = await WorkspaceService.uploadPdf(req.params.id, req.userId as string, req.params.paperId, pdfUrl);
      res.json({ success: true, data: result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async deletePdf(req: Request, res: Response) {
    try {
      const result = await WorkspaceService.deletePdf(req.params.id, req.userId as string, req.params.paperId);
      res.json({ success: true, data: result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async createNote(req: Request, res: Response) {
    try {
      const note = await WorkspaceService.createNote(req.params.id, req.userId as string, req.body);
      res.status(201).json({ success: true, data: note });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async getNotes(req: Request, res: Response) {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const result = await WorkspaceService.getNotes(req.params.id, req.userId as string, page, limit);
      res.json({ success: true, ...result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async updateNote(req: Request, res: Response) {
    try {
      const note = await WorkspaceService.updateNote(req.params.id, req.userId as string, req.params.noteId, req.body);
      res.json({ success: true, data: note });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async deleteNote(req: Request, res: Response) {
    try {
      const result = await WorkspaceService.deleteNote(req.params.id, req.userId as string, req.params.noteId);
      res.json({ success: true, ...result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async createAlert(req: Request, res: Response) {
    try {
      const alert = await WorkspaceService.createAlert(req.params.id, req.userId as string, req.body);
      res.status(201).json({ success: true, data: alert });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async getAlerts(req: Request, res: Response) {
    try {
      const alerts = await WorkspaceService.getAlerts(req.params.id, req.userId as string);
      res.json({ success: true, data: alerts });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async deleteAlert(req: Request, res: Response) {
    try {
      const result = await WorkspaceService.deleteAlert(req.params.id, req.userId as string, req.params.alertId);
      res.json({ success: true, ...result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }
}
