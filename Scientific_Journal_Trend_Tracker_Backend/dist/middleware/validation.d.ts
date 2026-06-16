import { Request, Response, NextFunction } from "express";
import { ValidationChain } from "express-validator";
export declare const validateRegister: ValidationChain[];
export declare const validateLogin: ValidationChain[];
export declare const validateCreatePaper: ValidationChain[];
export declare const validateCreateKeyword: ValidationChain[];
export declare const validateCreateJournal: ValidationChain[];
export declare const validateCreateTopic: ValidationChain[];
export declare const validateChangePassword: ValidationChain[];
export declare const validatePaginationQuery: ValidationChain[];
export declare const validateIdParam: ValidationChain[];
export declare const validatePaginationParams: (req: Request, res: Response, next: NextFunction) => void;
export declare const validateInputs: (req: Request, res: Response, next: NextFunction) => void;
//# sourceMappingURL=validation.d.ts.map