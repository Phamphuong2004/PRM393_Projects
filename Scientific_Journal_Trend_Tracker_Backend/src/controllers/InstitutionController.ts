import { Request, Response } from "express";
import { validationResult } from "express-validator";
import { InstitutionService } from "../services/InstitutionService";

export class InstitutionController {
  static async getAll(req: Request, res: Response): Promise<void> {
    try {
      const search = req.query.search as string | undefined;
      const institutions = await InstitutionService.getAll(search);
      res.json(institutions);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message || "Server error" });
    }
  }

  static async getById(req: Request, res: Response): Promise<void> {
    try {
      const institution = await InstitutionService.getById(req.params.id);
      res.json(institution);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message || "Server error" });
    }
  }

  static async create(req: Request, res: Response): Promise<void> {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({ errors: errors.array() });
        return;
      }
      const institution = await InstitutionService.create(req.body);
      res.status(201).json(institution);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message || "Server error" });
    }
  }

  static async update(req: Request, res: Response): Promise<void> {
    try {
      const institution = await InstitutionService.update(req.params.id, req.body);
      res.json(institution);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message || "Server error" });
    }
  }

  static async delete(req: Request, res: Response): Promise<void> {
    try {
      await InstitutionService.delete(req.params.id);
      res.json({ message: "Institution deleted" });
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message || "Server error" });
    }
  }
}
