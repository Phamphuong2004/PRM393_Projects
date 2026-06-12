"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaperService = void 0;
const models_1 = require("../models");
class PaperService {
    static async getAllPapers(page, limit) {
        const skip = (page - 1) * limit;
        const papers = await models_1.Paper.find()
            .populate(["authors", "journalId", "keywords"])
            .skip(skip)
            .limit(limit)
            .sort({ publicationYear: -1 });
        const total = await models_1.Paper.countDocuments();
        return {
            papers,
            total,
            pages: Math.ceil(total / limit),
        };
    }
    static async getPaperById(id) {
        const paper = await models_1.Paper.findById(id).populate([
            "authors",
            "journalId",
            "keywords",
        ]);
        if (!paper) {
            throw { status: 404, message: "Paper not found" };
        }
        return paper;
    }
    static async createPaper(paperData) {
        const paper = new models_1.Paper(paperData);
        await paper.save();
        await paper.populate(["authors", "journalId", "keywords"]);
        return paper;
    }
    static async updatePaper(id, paperData) {
        const paper = await models_1.Paper.findByIdAndUpdate(id, paperData, {
            new: true,
        }).populate(["authors", "journalId", "keywords"]);
        if (!paper) {
            throw { status: 404, message: "Paper not found" };
        }
        return paper;
    }
    static async deletePaper(id) {
        const paper = await models_1.Paper.findByIdAndDelete(id);
        if (!paper) {
            throw { status: 404, message: "Paper not found" };
        }
        return paper;
    }
    static async searchPapers(query, year, journalId) {
        const searchQuery = {
            $or: [
                { title: { $regex: query, $options: "i" } },
                { abstract: { $regex: query, $options: "i" } },
            ],
        };
        if (year) {
            searchQuery.publicationYear = year;
        }
        if (journalId) {
            searchQuery.journalId = journalId;
        }
        const papers = await models_1.Paper.find(searchQuery)
            .populate(["authors", "journalId", "keywords"])
            .sort({ publicationYear: -1 });
        return papers;
    }
    static async getPapersByCitation(minCitations) {
        const papers = await models_1.Paper.find({
            citationCount: { $gte: minCitations },
        })
            .populate(["authors", "journalId", "keywords"])
            .sort({ citationCount: -1 });
        return papers;
    }
    static async getPapersByKeyword(keywordId) {
        const papers = await models_1.Paper.find({
            keywords: keywordId,
        })
            .populate(["authors", "journalId", "keywords"])
            .sort({ publicationYear: -1 });
        return papers;
    }
}
exports.PaperService = PaperService;
//# sourceMappingURL=PaperService.js.map