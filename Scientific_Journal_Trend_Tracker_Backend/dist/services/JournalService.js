"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.JournalService = void 0;
const Journal_1 = __importDefault(require("../models/Journal"));
class JournalService {
    static async getAllJournals(page, limit) {
        const skip = (page - 1) * limit;
        const journals = await Journal_1.default.find()
            .skip(skip)
            .limit(limit)
            .sort({ name: 1 });
        const total = await Journal_1.default.countDocuments();
        return {
            journals,
            total,
            pages: Math.ceil(total / limit),
        };
    }
    static async getJournalById(id) {
        const journal = await Journal_1.default.findById(id);
        if (!journal) {
            throw { status: 404, message: "Journal not found" };
        }
        return journal;
    }
    static async createJournal(journalData) {
        // Check if ISSN already exists
        const existing = await Journal_1.default.findOne({ issn: journalData.issn });
        if (existing) {
            throw { status: 400, message: "Journal with this ISSN already exists" };
        }
        const journal = new Journal_1.default(journalData);
        await journal.save();
        return journal;
    }
    static async updateJournal(id, journalData) {
        const journal = await Journal_1.default.findByIdAndUpdate(id, journalData, {
            new: true,
        });
        if (!journal) {
            throw { status: 404, message: "Journal not found" };
        }
        return journal;
    }
    static async deleteJournal(id) {
        const journal = await Journal_1.default.findByIdAndDelete(id);
        if (!journal) {
            throw { status: 404, message: "Journal not found" };
        }
        return journal;
    }
    static async getJournalsByField(fieldDomain) {
        const journals = await Journal_1.default.find({ fieldDomain }).sort({
            impactFactor: -1,
        });
        return journals;
    }
    static async getTrackedJournals() {
        const journals = await Journal_1.default.find({ isTracked: true }).sort({
            impactFactor: -1,
        });
        return journals;
    }
    static async getHighImpactJournals(minImpactFactor = 2.0) {
        const journals = await Journal_1.default.find({
            impactFactor: { $gte: minImpactFactor },
        }).sort({ impactFactor: -1 });
        return journals;
    }
}
exports.JournalService = JournalService;
//# sourceMappingURL=JournalService.js.map