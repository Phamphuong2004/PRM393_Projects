import { Request, Response, NextFunction } from "express";
import {
  body,
  param,
  query,
  validationResult,
} from "express-validator";

export const validateRegister = [
  body("email").isEmail().withMessage("Valid email is required"),
  body("password")
    .isLength({ min: 6 })
    .withMessage("Password must be at least 6 characters"),
  body("fullName").notEmpty().withMessage("Full name is required"),
  body("role")
    .optional()
    .isIn(["admin", "researcher", "student"])
    .withMessage("Role must be 'admin', 'researcher', or 'student'"),
  body("institution")
    .optional()
    .isString()
    .withMessage("Institution must be a string")
    .trim(),
];

export const validateLogin = [
  body("email").isEmail().withMessage("Valid email is required"),
  body("password").notEmpty().withMessage("Password is required"),
];

export const validateCreatePaper = [
  body("title").notEmpty().withMessage("Paper title is required"),
  body("abstract").notEmpty().withMessage("Abstract is required"),
  body("publicationYear")
    .isInt({ min: 1900, max: new Date().getFullYear() })
    .withMessage("Valid publication year is required"),
];

export const validateCreateKeyword = [
  body("name").notEmpty().withMessage("Keyword name is required"),
  body("normalizedText").notEmpty().withMessage("Normalized text is required"),
];

export const validateCreateJournal = [
  body("name").notEmpty().withMessage("Journal name is required"),
  body("issn").notEmpty().withMessage("ISSN is required"),
  body("publisher").notEmpty().withMessage("Publisher is required"),
];

export const validateCreateTopic = [
  body("name").notEmpty().withMessage("Topic name is required"),
  body("seedKeyword").notEmpty().withMessage("Seed keyword is required"),
];

export const validateCreateAuthor = [
  body("fullName").notEmpty().withMessage("Author full name is required"),
];

export const validateChangePassword = [
  body("currentPassword")
    .notEmpty()
    .withMessage("Current password is required"),
  body("newPassword")
    .isLength({ min: 6 })
    .withMessage("New password must be at least 6 characters"),
];

export const validatePaginationQuery = [
  query("page")
    .optional()
    .isInt({ min: 1 })
    .withMessage("Page must be a positive integer"),
  query("limit")
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage("Limit must be between 1 and 100"),
];

export const validateIdParam = [
  param("id").isMongoId().withMessage("Invalid ID format"),
];

export const validatePaginationParams = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(400).json({ errors: errors.array() });
    return;
  }
  next();
};

export const validateInputs = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(400).json({ errors: errors.array() });
    return;
  }
  next();
};
