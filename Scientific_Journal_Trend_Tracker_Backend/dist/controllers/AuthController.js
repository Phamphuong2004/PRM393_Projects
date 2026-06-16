"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const express_validator_1 = require("express-validator");
const User_1 = __importDefault(require("../models/User"));
class AuthController {
    static async register(req, res) {
        try {
            const errors = (0, express_validator_1.validationResult)(req);
            if (!errors.isEmpty()) {
                res.status(400).json({ errors: errors.array() });
                return;
            }
            const { email, password, fullName } = req.body;
            // Check if user exists
            let user = await User_1.default.findOne({ email });
            if (user) {
                res.status(400).json({ message: "User already exists" });
                return;
            }
            // Hash password
            const salt = await bcryptjs_1.default.genSalt(parseInt(process.env.BCRYPT_ROUNDS || "10"));
            const hashedPassword = await bcryptjs_1.default.hash(password, salt);
            // Create user
            user = new User_1.default({
                email,
                password: hashedPassword,
                fullName,
            });
            await user.save();
            // Generate token
            const token = jsonwebtoken_1.default.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET || "secret", { expiresIn: (process.env.JWT_EXPIRE || "7d") });
            res.status(201).json({
                message: "User registered successfully",
                token,
                user: {
                    id: user._id,
                    email: user.email,
                    fullName: user.fullName,
                    role: user.role,
                },
            });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async login(req, res) {
        try {
            const errors = (0, express_validator_1.validationResult)(req);
            if (!errors.isEmpty()) {
                res.status(400).json({ errors: errors.array() });
                return;
            }
            const { email, password } = req.body;
            // Check user
            const user = await User_1.default.findOne({ email });
            if (!user) {
                res.status(400).json({ message: "Invalid credentials" });
                return;
            }
            // Compare password
            const isMatch = await bcryptjs_1.default.compare(password, user.password);
            if (!isMatch) {
                res.status(400).json({ message: "Invalid credentials" });
                return;
            }
            // Update last login
            user.lastLogin = new Date();
            await user.save();
            // Generate token
            const token = jsonwebtoken_1.default.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET || "secret", { expiresIn: (process.env.JWT_EXPIRE || "7d") });
            res.json({
                message: "Logged in successfully",
                token,
                user: {
                    id: user._id,
                    email: user.email,
                    fullName: user.fullName,
                    role: user.role,
                },
            });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async getCurrentUser(req, res) {
        try {
            if (!req.userId) {
                res.status(401).json({ message: "Unauthorized" });
                return;
            }
            const user = await User_1.default.findById(req.userId)
                .select("-password")
                .populate("bookmarks")
                .populate("trackedRuns.analysisRunId")
                .populate("follows");
            if (!user) {
                res.status(404).json({ message: "User not found" });
                return;
            }
            res.json(user);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
}
exports.AuthController = AuthController;
//# sourceMappingURL=AuthController.js.map