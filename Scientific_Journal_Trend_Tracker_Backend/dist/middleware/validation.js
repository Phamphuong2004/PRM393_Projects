"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateInputs = exports.validatePaginationParams = exports.validateIdParam = exports.validatePaginationQuery = exports.validateChangePassword = exports.validateCreateTopic = exports.validateCreateJournal = exports.validateCreateKeyword = exports.validateCreatePaper = exports.validateLogin = exports.validateRegister = void 0;
const express_validator_1 = require("express-validator");
exports.validateRegister = [
    (0, express_validator_1.body)("email").isEmail().withMessage("Valid email is required"),
    (0, express_validator_1.body)("password")
        .isLength({ min: 6 })
        .withMessage("Password must be at least 6 characters"),
    (0, express_validator_1.body)("fullName").notEmpty().withMessage("Full name is required"),
];
exports.validateLogin = [
    (0, express_validator_1.body)("email").isEmail().withMessage("Valid email is required"),
    (0, express_validator_1.body)("password").notEmpty().withMessage("Password is required"),
];
exports.validateCreatePaper = [
    (0, express_validator_1.body)("title").notEmpty().withMessage("Paper title is required"),
    (0, express_validator_1.body)("abstract").notEmpty().withMessage("Abstract is required"),
    (0, express_validator_1.body)("publicationYear")
        .isInt({ min: 1900, max: new Date().getFullYear() })
        .withMessage("Valid publication year is required"),
];
exports.validateCreateKeyword = [
    (0, express_validator_1.body)("name").notEmpty().withMessage("Keyword name is required"),
    (0, express_validator_1.body)("normalizedText").notEmpty().withMessage("Normalized text is required"),
];
exports.validateCreateJournal = [
    (0, express_validator_1.body)("name").notEmpty().withMessage("Journal name is required"),
    (0, express_validator_1.body)("issn").notEmpty().withMessage("ISSN is required"),
    (0, express_validator_1.body)("publisher").notEmpty().withMessage("Publisher is required"),
];
exports.validateCreateTopic = [
    (0, express_validator_1.body)("name").notEmpty().withMessage("Topic name is required"),
    (0, express_validator_1.body)("seedKeyword").notEmpty().withMessage("Seed keyword is required"),
];
exports.validateChangePassword = [
    (0, express_validator_1.body)("currentPassword")
        .notEmpty()
        .withMessage("Current password is required"),
    (0, express_validator_1.body)("newPassword")
        .isLength({ min: 6 })
        .withMessage("New password must be at least 6 characters"),
];
exports.validatePaginationQuery = [
    (0, express_validator_1.query)("page")
        .optional()
        .isInt({ min: 1 })
        .withMessage("Page must be a positive integer"),
    (0, express_validator_1.query)("limit")
        .optional()
        .isInt({ min: 1, max: 100 })
        .withMessage("Limit must be between 1 and 100"),
];
exports.validateIdParam = [
    (0, express_validator_1.param)("id").isMongoId().withMessage("Invalid ID format"),
];
const validatePaginationParams = (req, res, next) => {
    const errors = (0, express_validator_1.validationResult)(req);
    if (!errors.isEmpty()) {
        res.status(400).json({ errors: errors.array() });
        return;
    }
    next();
};
exports.validatePaginationParams = validatePaginationParams;
const validateInputs = (req, res, next) => {
    const errors = (0, express_validator_1.validationResult)(req);
    if (!errors.isEmpty()) {
        res.status(400).json({ errors: errors.array() });
        return;
    }
    next();
};
exports.validateInputs = validateInputs;
//# sourceMappingURL=validation.js.map