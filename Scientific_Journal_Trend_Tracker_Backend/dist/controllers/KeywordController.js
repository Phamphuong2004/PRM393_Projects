"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.KeywordController = void 0;
const express_validator_1 = require("express-validator");
const Keyword_1 = __importDefault(require("../models/Keyword"));
class KeywordController {
    static async getAllKeywords(req, res) {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 20;
            const skip = (page - 1) * limit;
            const sort = req.query.sort || "-trendScore";
            const keywords = await Keyword_1.default.find().skip(skip).limit(limit).sort(sort);
            const total = await Keyword_1.default.countDocuments();
            res.json({
                keywords,
                pagination: {
                    page,
                    limit,
                    total,
                    pages: Math.ceil(total / limit),
                },
            });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async getKeywordById(req, res) {
        try {
            const keyword = await Keyword_1.default.findById(req.params.id);
            if (!keyword) {
                res.status(404).json({ message: "Keyword not found" });
                return;
            }
            res.json(keyword);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async createKeyword(req, res) {
        try {
            const errors = (0, express_validator_1.validationResult)(req);
            if (!errors.isEmpty()) {
                res.status(400).json({ errors: errors.array() });
                return;
            }
            const keyword = new Keyword_1.default(req.body);
            await keyword.save();
            res.status(201).json(keyword);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async updateKeyword(req, res) {
        try {
            const keyword = await Keyword_1.default.findByIdAndUpdate(req.params.id, req.body, {
                new: true,
            });
            if (!keyword) {
                res.status(404).json({ message: "Keyword not found" });
                return;
            }
            res.json(keyword);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async deleteKeyword(req, res) {
        try {
            const keyword = await Keyword_1.default.findByIdAndDelete(req.params.id);
            if (!keyword) {
                res.status(404).json({ message: "Keyword not found" });
                return;
            }
            res.json({ message: "Keyword deleted" });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async getTrendingKeywords(req, res) {
        try {
            const keywords = await Keyword_1.default.find().sort({ trendScore: -1 }).limit(20);
            res.json(keywords);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
}
exports.KeywordController = KeywordController;
//# sourceMappingURL=KeywordController.js.map