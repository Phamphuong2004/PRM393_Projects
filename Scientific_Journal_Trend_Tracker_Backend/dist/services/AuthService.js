"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const User_1 = __importDefault(require("../models/User"));
class AuthService {
    static async register(email, password, fullName) {
        // Check if user exists
        let user = await User_1.default.findOne({ email });
        if (user) {
            throw { status: 400, message: "User already exists" };
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
        const token = jsonwebtoken_1.default.sign({ userId: user._id, email: user.email, role: user.role }, process.env.JWT_SECRET || "your-secret-key", { expiresIn: "7d" });
        return {
            token,
            user: {
                id: user._id,
                email: user.email,
                fullName: user.fullName,
                role: user.role,
            },
        };
    }
    static async login(email, password) {
        // Check if user exists
        const user = await User_1.default.findOne({ email });
        if (!user) {
            throw { status: 400, message: "Invalid email or password" };
        }
        // Check password
        const isMatch = await bcryptjs_1.default.compare(password, user.password);
        if (!isMatch) {
            throw { status: 400, message: "Invalid email or password" };
        }
        // Update last login
        user.lastLogin = new Date();
        await user.save();
        // Generate token
        const token = jsonwebtoken_1.default.sign({ userId: user._id, email: user.email, role: user.role }, process.env.JWT_SECRET || "your-secret-key", { expiresIn: "7d" });
        return {
            token,
            user: {
                id: user._id,
                email: user.email,
                fullName: user.fullName,
                role: user.role,
            },
        };
    }
    static async getCurrentUser(userId) {
        const user = await User_1.default.findById(userId)
            .select("-password")
            .populate(["bookmarks", "follows", "trackedRuns"]);
        if (!user) {
            throw { status: 404, message: "User not found" };
        }
        return user;
    }
    static async validateToken(token) {
        try {
            const decoded = jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET || "your-secret-key");
            return decoded;
        }
        catch (error) {
            throw { status: 401, message: "Invalid token" };
        }
    }
}
exports.AuthService = AuthService;
//# sourceMappingURL=AuthService.js.map