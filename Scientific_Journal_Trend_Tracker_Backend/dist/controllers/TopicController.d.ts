import { Request, Response } from "express";
export declare class TopicController {
    static getAllTopics(req: Request, res: Response): Promise<void>;
    static getTopicById(req: Request, res: Response): Promise<void>;
    static createTopic(req: Request, res: Response): Promise<void>;
    static updateTopic(req: Request, res: Response): Promise<void>;
    static deleteTopic(req: Request, res: Response): Promise<void>;
    static getEmergingTopics(req: Request, res: Response): Promise<void>;
}
//# sourceMappingURL=TopicController.d.ts.map