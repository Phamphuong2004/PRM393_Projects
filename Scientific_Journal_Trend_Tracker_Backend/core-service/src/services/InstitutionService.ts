import Institution from "../models/Institution";

export class InstitutionService {
  static async getAll(search?: string, activeOnly: boolean = true) {
    const query: any = {};
    if (activeOnly) query.isActive = true;
    if (search) query.name = { $regex: search, $options: "i" };

    return Institution.find(query).sort({ name: 1 });
  }

  static async getById(id: string) {
    const institution = await Institution.findById(id);
    if (!institution) {
      throw { status: 404, message: "Institution not found" };
    }
    return institution;
  }

  static async create(data: any) {
    const existing = await Institution.findOne({ name: data.name });
    if (existing) {
      throw { status: 400, message: "Institution with this name already exists" };
    }

    const institution = new Institution(data);
    await institution.save();
    return institution;
  }

  static async update(id: string, data: any) {
    const institution = await Institution.findByIdAndUpdate(id, data, {
      new: true,
    });
    if (!institution) {
      throw { status: 404, message: "Institution not found" };
    }
    return institution;
  }

  static async delete(id: string) {
    const institution = await Institution.findByIdAndDelete(id);
    if (!institution) {
      throw { status: 404, message: "Institution not found" };
    }
    return institution;
  }
}
