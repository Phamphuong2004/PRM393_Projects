import { Request, Response } from "express";
export declare class PaperController {
    static getAllPapers(req: Request, res: Response): Promise<void>;
    static getPaperById(req: Request, res: Response): Promise<void>;
    static createPaper(req: Request, res: Response): Promise<void>;
    static updatePaper(req: Request, res: Response): Promise<void>;
    static deletePaper(req: Request, res: Response): Promise<void>;
    static searchPapers(req: Request, res: Response): Promise<void>;
}
//# sourceMappingURL=PaperController.d.ts.map