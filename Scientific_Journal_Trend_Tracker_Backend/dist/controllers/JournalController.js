"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.JournalController = void 0;
const express_validator_1 = require("express-validator");
const Journal_1 = __importDefault(require("../models/Journal"));
class JournalController {
    static async getAllJournals(req, res) {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 10;
            const skip = (page - 1) * limit;
            const journals = await Journal_1.default.find()
                .skip(skip)
                .limit(limit)
                .sort({ name: 1 });
            const total = await Journal_1.default.countDocuments();
            res.json({
                journals,
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
    static async getJournalById(req, res) {
        try {
            const journal = await Journal_1.default.findById(req.params.id);
            if (!journal) {
                res.status(404).json({ message: "Journal not found" });
                return;
            }
            res.json(journal);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async createJournal(req, res) {
        try {
            const errors = (0, express_validator_1.validationResult)(req);
            if (!errors.isEmpty()) {
                res.status(400).json({ errors: errors.array() });
                return;
            }
            const journal = new Journal_1.default(req.body);
            await journal.save();
            res.status(201).json(journal);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async updateJournal(req, res) {
        try {
            const journal = await Journal_1.default.findByIdAndUpdate(req.params.id, req.body, {
                new: true,
            });
            if (!journal) {
                res.status(404).json({ message: "Journal not found" });
                return;
            }
            res.json(journal);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async deleteJournal(req, res) {
        try {
            const journal = await Journal_1.default.findByIdAndDelete(req.params.id);
            if (!journal) {
                res.status(404).json({ message: "Journal not found" });
                return;
            }
            res.json({ message: "Journal deleted" });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
}
exports.JournalController = JournalController;
//# sourceMappingURL=JournalController.js.map