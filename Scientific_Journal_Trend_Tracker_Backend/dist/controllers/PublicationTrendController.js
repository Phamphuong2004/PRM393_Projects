"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PublicationTrendController = void 0;
const express_validator_1 = require("express-validator");
const PublicationTrend_1 = __importDefault(require("../models/PublicationTrend"));
class PublicationTrendController {
    static async getAllTrends(req, res) {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 10;
            const skip = (page - 1) * limit;
            const trends = await PublicationTrend_1.default.find()
                .populate("keywordId")
                .populate("journalId")
                .populate("analysisRunId")
                .skip(skip)
                .limit(limit)
                .sort({ calculatedAt: -1 });
            const total = await PublicationTrend_1.default.countDocuments();
            res.json({
                trends,
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
    static async getTrendingPublications(req, res) {
        try {
            const trends = await PublicationTrend_1.default.find({ isTrending: true })
                .populate("keywordId")
                .populate("journalId")
                .populate("analysisRunId")
                .sort({ growthRate: -1 })
                .limit(50);
            res.json(trends);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async getTrendById(req, res) {
        try {
            const trend = await PublicationTrend_1.default.findById(req.params.id)
                .populate("keywordId")
                .populate("journalId")
                .populate("analysisRunId");
            if (!trend) {
                res.status(404).json({ message: "Publication trend not found" });
                return;
            }
            res.json(trend);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async createTrend(req, res) {
        try {
            const errors = (0, express_validator_1.validationResult)(req);
            if (!errors.isEmpty()) {
                res.status(400).json({ errors: errors.array() });
                return;
            }
            const trend = new PublicationTrend_1.default(req.body);
            await trend.save();
            await trend.populate(["keywordId", "journalId", "analysisRunId"]);
            res.status(201).json(trend);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async updateTrend(req, res) {
        try {
            const trend = await PublicationTrend_1.default.findByIdAndUpdate(req.params.id, req.body, { new: true }).populate(["keywordId", "journalId", "analysisRunId"]);
            if (!trend) {
                res.status(404).json({ message: "Publication trend not found" });
                return;
            }
            res.json(trend);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async deleteTrend(req, res) {
        try {
            const trend = await PublicationTrend_1.default.findByIdAndDelete(req.params.id);
            if (!trend) {
                res.status(404).json({ message: "Publication trend not found" });
                return;
            }
            res.json({ message: "Publication trend deleted" });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async getTrendsByKeyword(req, res) {
        try {
            const trends = await PublicationTrend_1.default.find({
                keywordId: req.params.keywordId,
            })
                .populate("keywordId")
                .populate("journalId")
                .populate("analysisRunId")
                .sort({ year: -1 });
            res.json(trends);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async getTrendsByJournal(req, res) {
        try {
            const trends = await PublicationTrend_1.default.find({
                journalId: req.params.journalId,
            })
                .populate("keywordId")
                .populate("journalId")
                .populate("analysisRunId")
                .sort({ year: -1 });
            res.json(trends);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
}
exports.PublicationTrendController = PublicationTrendController;
//# sourceMappingURL=PublicationTrendController.js.map