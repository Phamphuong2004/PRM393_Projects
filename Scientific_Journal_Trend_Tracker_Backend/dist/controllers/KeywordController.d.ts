import { Request, Response } from "express";
export declare class KeywordController {
    static getAllKeywords(req: Request, res: Response): Promise<void>;
    static getKeywordById(req: Request, res: Response): Promise<void>;
    static createKeyword(req: Request, res: Response): Promise<void>;
    static updateKeyword(req: Request, res: Response): Promise<void>;
    static deleteKeyword(req: Request, res: Response): Promise<void>;
    static getTrendingKeywords(req: Request, res: Response): Promise<void>;
}
//# sourceMappingURL=KeywordController.d.ts.map