import { Request, Response } from "express";
export declare class UserController {
    static getAllUsers(req: Request, res: Response): Promise<void>;
    static getUserById(req: Request, res: Response): Promise<void>;
    static updateUserProfile(req: Request, res: Response): Promise<void>;
    static deleteUser(req: Request, res: Response): Promise<void>;
    static changePassword(req: Request, res: Response): Promise<void>;
    static getUsersByRole(req: Request, res: Response): Promise<void>;
}
//# sourceMappingURL=UserController.d.ts.map