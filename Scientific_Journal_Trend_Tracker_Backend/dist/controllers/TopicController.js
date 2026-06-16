"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TopicController = void 0;
const express_validator_1 = require("express-validator");
const Topic_1 = __importDefault(require("../models/Topic"));
class TopicController {
    static async getAllTopics(req, res) {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 10;
            const skip = (page - 1) * limit;
            const topics = await Topic_1.default.find()
                .populate("analysisRunId")
                .populate("papers")
                .skip(skip)
                .limit(limit)
                .sort({ createdAt: -1 });
            const total = await Topic_1.default.countDocuments();
            res.json({
                topics,
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
    static async getTopicById(req, res) {
        try {
            const topic = await Topic_1.default.findById(req.params.id)
                .populate("analysisRunId")
                .populate("papers");
            if (!topic) {
                res.status(404).json({ message: "Topic not found" });
                return;
            }
            res.json(topic);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async createTopic(req, res) {
        try {
            const errors = (0, express_validator_1.validationResult)(req);
            if (!errors.isEmpty()) {
                res.status(400).json({ errors: errors.array() });
                return;
            }
            const topic = new Topic_1.default(req.body);
            await topic.save();
            await topic.populate(["analysisRunId", "papers"]);
            res.status(201).json(topic);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async updateTopic(req, res) {
        try {
            const topic = await Topic_1.default.findByIdAndUpdate(req.params.id, req.body, {
                new: true,
            }).populate(["analysisRunId", "papers"]);
            if (!topic) {
                res.status(404).json({ message: "Topic not found" });
                return;
            }
            res.json(topic);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async deleteTopic(req, res) {
        try {
            const topic = await Topic_1.default.findByIdAndDelete(req.params.id);
            if (!topic) {
                res.status(404).json({ message: "Topic not found" });
                return;
            }
            res.json({ message: "Topic deleted" });
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
    static async getEmergingTopics(req, res) {
        try {
            const topics = await Topic_1.default.find({ isEmerging: true })
                .populate("analysisRunId")
                .populate("papers")
                .sort({ createdAt: -1 });
            res.json(topics);
        }
        catch (error) {
            console.error(error);
            res.status(500).json({ message: "Server error" });
        }
    }
}
exports.TopicController = TopicController;
//# sourceMappingURL=TopicController.js.map