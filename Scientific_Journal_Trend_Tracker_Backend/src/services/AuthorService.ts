import { Author } from "../models";

export class AuthorService {
  static async getAllAuthors(page: number, limit: number, search?: string) {
    const skip = (page - 1) * limit;
    
    let query: any = {};
    if (search && search.trim()) {
      query = {
        $or: [
          { fullName: { $regex: search, $options: "i" } },
          { affiliation: { $regex: search, $options: "i" } },
        ],
      };
    }

    const authors = await Author.find(query)
      .skip(skip)
      .limit(limit)
      .sort({ fullName: 1 });

    const total = await Author.countDocuments(query);

    return {
      authors,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  static async getAuthorById(id: string) {
    const author = await Author.findById(id);

    if (!author) {
      throw { status: 404, message: "Author not found" };
    }

    return author;
  }

  static async createAuthor(authorData: any) {
    // Unique check for externalAuthorId
    if (authorData.externalAuthorId) {
      const existing = await Author.findOne({ externalAuthorId: authorData.externalAuthorId });
      if (existing) {
        throw { status: 400, message: "Author with this External ID already exists" };
      }
    }

    // Unique check for orcid
    if (authorData.orcid) {
      const existing = await Author.findOne({ orcid: authorData.orcid });
      if (existing) {
        throw { status: 400, message: "Author with this ORCID already exists" };
      }
    }

    // Unique check for operalId
    if (authorData.operalId) {
      const existing = await Author.findOne({ operalId: authorData.operalId });
      if (existing) {
        throw { status: 400, message: "Author with this Operal ID already exists" };
      }
    }

    const author = new Author(authorData);
    await author.save();
    return author;
  }

  static async updateAuthor(id: string, authorData: any) {
    // Unique check for externalAuthorId if being updated
    if (authorData.externalAuthorId) {
      const existing = await Author.findOne({ 
        externalAuthorId: authorData.externalAuthorId, 
        _id: { $ne: id } 
      });
      if (existing) {
        throw { status: 400, message: "Author with this External ID already exists" };
      }
    }

    // Unique check for orcid if being updated
    if (authorData.orcid) {
      const existing = await Author.findOne({ 
        orcid: authorData.orcid, 
        _id: { $ne: id } 
      });
      if (existing) {
        throw { status: 400, message: "Author with this ORCID already exists" };
      }
    }

    // Unique check for operalId if being updated
    if (authorData.operalId) {
      const existing = await Author.findOne({ 
        operalId: authorData.operalId, 
        _id: { $ne: id } 
      });
      if (existing) {
        throw { status: 400, message: "Author with this Operal ID already exists" };
      }
    }

    const author = await Author.findByIdAndUpdate(id, authorData, {
      new: true,
      runValidators: true
    });

    if (!author) {
      throw { status: 404, message: "Author not found" };
    }

    return author;
  }

  static async deleteAuthor(id: string) {
    const author = await Author.findByIdAndDelete(id);

    if (!author) {
      throw { status: 404, message: "Author not found" };
    }

    return author;
  }
}
