import { Request, Response } from "express";
export declare class PublicationTrendController {
    static getAllTrends(req: Request, res: Response): Promise<void>;
    static getTrendingPublications(req: Request, res: Response): Promise<void>;
    static getTrendById(req: Request, res: Response): Promise<void>;
    static createTrend(req: Request, res: Response): Promise<void>;
    static updateTrend(req: Request, res: Response): Promise<void>;
    static deleteTrend(req: Request, res: Response): Promise<void>;
    static getTrendsByKeyword(req: Request, res: Response): Promise<void>;
    static getTrendsByJournal(req: Request, res: Response): Promise<void>;
}
//# sourceMappingURL=PublicationTrendController.d.ts.map