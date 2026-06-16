import { Request, Response } from "express";
export declare class FollowController {
    static getUserFollows(req: Request, res: Response): Promise<void>;
    static addFollow(req: Request, res: Response): Promise<void>;
    static removeFollow(req: Request, res: Response): Promise<void>;
    static getTrackedRuns(req: Request, res: Response): Promise<void>;
    static trackAnalysisRun(req: Request, res: Response): Promise<void>;
    static untrackAnalysisRun(req: Request, res: Response): Promise<void>;
    static updateTrackedRunNotification(req: Request, res: Response): Promise<void>;
}
//# sourceMappingURL=FollowController.d.ts.map