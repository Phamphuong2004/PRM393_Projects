import Journal from "../models/Journal";

export class JournalService {
  static async getAllJournals(page: number, limit: number) {
    const skip = (page - 1) * limit;

    const journals = await Journal.find()
      .skip(skip)
      .limit(limit)
      .sort({ name: 1 });

    const total = await Journal.countDocuments();

    return {
      journals,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  static async getJournalById(id: string) {
    const journal = await Journal.findById(id);

    if (!journal) {
      throw { status: 404, message: "Journal not found" };
    }

    return journal;
  }

  static async createJournal(journalData: any) {
    // Check if ISSN already exists
    const existing = await Journal.findOne({ issn: journalData.issn });
    if (existing) {
      throw { status: 400, message: "Journal with this ISSN already exists" };
    }

    const journal = new Journal(journalData);
    await journal.save();
    return journal;
  }

  static async updateJournal(id: string, journalData: any) {
    const journal = await Journal.findByIdAndUpdate(id, journalData, {
      new: true,
    });

    if (!journal) {
      throw { status: 404, message: "Journal not found" };
    }

    return journal;
  }

  static async deleteJournal(id: string) {
    const journal = await Journal.findByIdAndDelete(id);

    if (!journal) {
      throw { status: 404, message: "Journal not found" };
    }

    return journal;
  }

  static async getJournalsByField(fieldDomain: string) {
    const journals = await Journal.find({ fieldDomain }).sort({
      impactFactor: -1,
    });

    return journals;
  }

  static async getTrackedJournals() {
    const journals = await Journal.find({ isTracked: true }).sort({
      impactFactor: -1,
    });

    return journals;
  }

  static async getHighImpactJournals(minImpactFactor: number = 2.0) {
    const journals = await Journal.find({
      impactFactor: { $gte: minImpactFactor },
    }).sort({ impactFactor: -1 });

    return journals;
  }
}
