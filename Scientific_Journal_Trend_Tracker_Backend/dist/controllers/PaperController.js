"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaperController = void 0;
const express_validator_1 = require("express-validator");
const Paper_1 = __importDefault(require("../models/Paper"));
class PaperController {
    static async getAllPapers(req, res) {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 10;
            const skip = (page - 1) * limit;
            const papers = await Paper_1.default.find()
                .populate("authors")
                .populate("journalId")
                .populate("keywords")
                .skip(skip)
                .limit(limit)
                .sort({ createdAt: -1 });
            const total = await Paper_1.default.countDocuments();
            res.json({
                papers,
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
    static async getPaperById(req, res) {
        try {
            const paper = await Paper_1.default.findById(req.params.id)
                .populate("authors")
                .populate("journalId")
                .populate("keywords")
                .populate("topics");
            if (!paper) {
                res.status(404).json({ message: "Paper not found" });
                return;
            }
            res.json(paper);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async createPaper(req, res) {
        try {
            const errors = (0, express_validator_1.validationResult)(req);
            if (!errors.isEmpty()) {
                res.status(400).json({ errors: errors.array() });
                return;
            }
            const paper = new Paper_1.default(req.body);
            await paper.save();
            await paper.populate(["authors", "journalId", "keywords"]);
            res.status(201).json(paper);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async updatePaper(req, res) {
        try {
            const paper = await Paper_1.default.findByIdAndUpdate(req.params.id, req.body, {
                new: true,
            }).populate(["authors", "journalId", "keywords"]);
            if (!paper) {
                res.status(404).json({ message: "Paper not found" });
                return;
            }
            res.json(paper);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async deletePaper(req, res) {
        try {
            const paper = await Paper_1.default.findByIdAndDelete(req.params.id);
            if (!paper) {
                res.status(404).json({ message: "Paper not found" });
                return;
            }
            res.json({ message: "Paper deleted" });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async searchPapers(req, res) {
        try {
            const { q, year, journalId } = req.query;
            const query = {};
            if (q) {
                query.$or = [
                    { title: { $regex: q, $options: "i" } },
                    { abstract: { $regex: q, $options: "i" } },
                ];
            }
            if (year) {
                query.publicationYear = year;
            }
            if (journalId) {
                query.journalId = journalId;
            }
            const papers = await Paper_1.default.find(query)
                .populate("authors")
                .populate("journalId")
                .limit(50);
            res.json(papers);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
}
exports.PaperController = PaperController;
//# sourceMappingURL=PaperController.js.map