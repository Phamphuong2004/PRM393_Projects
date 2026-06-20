import { Request, Response } from "express";
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

  static async getWorkspaceById(req: Request, res: Response) {
    try {
      const result = await WorkspaceService.getWorkspaceById(req.params.id, req.userId as string);
      res.json({ success: true, data: result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async addMember(req: Request, res: Response) {
    try {
      const { email, role } = req.body;
      const workspace = await WorkspaceService.addMember(req.params.id, req.userId as string, email, role);
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

  static async getWorkspacePapers(req: Request, res: Response) {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const tag = req.query.tag as string;
      const result = await WorkspaceService.getWorkspacePapers(req.params.id, req.userId as string, page, limit, tag);
      res.json({ success: true, ...result });
    } catch (error: any) {
      res.status(error.status || 500).json({ success: false, message: error.message });
    }
  }

  static async uploadPdf(req: Request, res: Response) {
    try {
      if (!req.file) throw { status: 400, message: "No PDF file uploaded" };
      if (!isCloudinaryConfigured()) {
        throw { status: 500, message: "File storage is not configured. Set CLOUDINARY_* environment variables." };
      }
      // Stream the in-memory buffer to Cloudinary and store the absolute URL.
      const pdfUrl = await uploadPdfBuffer(req.file.buffer, req.file.originalname);
      const result = await WorkspaceService.uploadPdf(req.params.id, req.userId as string, req.params.paperId, pdfUrl);
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
}
