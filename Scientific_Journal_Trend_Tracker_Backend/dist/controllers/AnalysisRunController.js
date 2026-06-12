"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AnalysisRunController = void 0;
const express_validator_1 = require("express-validator");
const AnalysisRun_1 = __importDefault(require("../models/AnalysisRun"));
class AnalysisRunController {
    static async getAllAnalysisRuns(req, res) {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 10;
            const skip = (page - 1) * limit;
            const runs = await AnalysisRun_1.default.find()
                .populate("keywordId")
                .populate("syncLogId")
                .populate("topicId")
                .skip(skip)
                .limit(limit)
                .sort({ createdAt: -1 });
            const total = await AnalysisRun_1.default.countDocuments();
            res.json({
                runs,
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
    static async getAnalysisRunById(req, res) {
        try {
            const run = await AnalysisRun_1.default.findById(req.params.id)
                .populate("keywordId")
                .populate("syncLogId")
                .populate("topicId");
            if (!run) {
                res.status(404).json({ message: "Analysis run not found" });
                return;
            }
            res.json(run);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async createAnalysisRun(req, res) {
        try {
            const errors = (0, express_validator_1.validationResult)(req);
            if (!errors.isEmpty()) {
                res.status(400).json({ errors: errors.array() });
                return;
            }
            const run = new AnalysisRun_1.default(req.body);
            await run.save();
            await run.populate(["keywordId", "syncLogId", "topicId"]);
            res.status(201).json(run);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async updateAnalysisRun(req, res) {
        try {
            const run = await AnalysisRun_1.default.findByIdAndUpdate(req.params.id, req.body, {
                new: true,
            }).populate(["keywordId", "syncLogId", "topicId"]);
            if (!run) {
                res.status(404).json({ message: "Analysis run not found" });
                return;
            }
            res.json(run);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async deleteAnalysisRun(req, res) {
        try {
            const run = await AnalysisRun_1.default.findByIdAndDelete(req.params.id);
            if (!run) {
                res.status(404).json({ message: "Analysis run not found" });
                return;
            }
            res.json({ message: "Analysis run deleted" });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async getAnalysisRunsByKeyword(req, res) {
        try {
            const runs = await AnalysisRun_1.default.find({ keywordId: req.params.keywordId })
                .populate("keywordId")
                .populate("syncLogId")
                .populate("topicId")
                .sort({ createdAt: -1 });
            res.json(runs);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
}
exports.AnalysisRunController = AnalysisRunController;
//# sourceMappingURL=AnalysisRunController.js.map