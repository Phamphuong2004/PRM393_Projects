import mongoose from "mongoose";
import {
  Workspace,
  WorkspacePaper,
  WorkspaceNote,
  WorkspaceAlert,
  Paper,
} from "../models";

export class WorkspaceService {
  static async checkRole(workspaceId: string, userId: string, requiredRoles: string[]) {
    const workspace = await Workspace.findById(workspaceId);
    if (!workspace) throw { status: 404, message: "Workspace not found" };

    if (workspace.owner.toString() === userId) return { workspace, role: "owner" };

    const member = workspace.members.find((m) => m.user.toString() === userId);
    if (!member) throw { status: 403, message: "Not a member of this workspace" };

    if (!requiredRoles.includes(member.role)) {
      throw { status: 403, message: `Role ${requiredRoles.join(" or ")} required` };
    }

    return { workspace, role: member.role };
  }

  static async createWorkspace(userId: string, data: any) {
    const workspace = new Workspace({
      ...data,
      owner: userId,
      members: [{ user: userId, role: "owner" }],
    });
    await workspace.save();
    return workspace;
  }

  static async getWorkspaces(userId: string, page: number, limit: number) {
    const skip = (page - 1) * limit;
    const query = { $or: [{ owner: userId }, { "members.user": userId }] };
    const workspaces = await Workspace.find(query).skip(skip).limit(limit).lean();
    const total = await Workspace.countDocuments(query);
    return { data: workspaces, total, page, limit, pages: Math.ceil(total / limit) };
  }

  static async getWorkspaceById(workspaceId: string, userId: string) {
    const { workspace, role } = await this.checkRole(workspaceId, userId, ["owner", "editor", "viewer"]);
    await workspace.populate("members.user", "fullName email avatar");
    const memberCount = workspace.members.length;

    const [papers, notes] = await Promise.all([
      WorkspacePaper.find({ workspace: workspaceId }).populate("paper", "title doi publicationYear authors").lean(),
      WorkspaceNote.countDocuments({ workspace: workspaceId }),
    ]);

    return {
      workspace,
      role,
      papers,
      stats: { memberCount, paperCount: papers.length, noteCount: notes },
    };
  }

  static async addMember(workspaceId: string, ownerId: string, email: string, role: string) {
    await this.checkRole(workspaceId, ownerId, ["owner"]);
    const mongoose = require("mongoose");
    const User = mongoose.model("user");
    const user = await User.findOne({ email });
    if (!user) throw { status: 404, message: "User not found" };

    const workspace = await Workspace.findById(workspaceId);
    if (!workspace) throw { status: 404, message: "Workspace not found" };

    const memberIndex = workspace.members.findIndex((m) => m.user.toString() === user._id.toString());
    if (memberIndex >= 0) {
      workspace.members[memberIndex].role = role as any;
    } else {
      workspace.members.push({ user: user._id as any, role: role as any, addedAt: new Date() });
    }
    await workspace.save();
    return workspace;
  }

  static async addPaper(workspaceId: string, userId: string, data: any) {
    await this.checkRole(workspaceId, userId, ["owner", "editor"]);
    let paperId = data.paperId;

    if (!paperId && data.paper) {
      const paperData = { ...data.paper, source: data.paper.source || "manual" };

      // Remove null/empty external ID fields so sparse unique indexes are not violated
      const externalIdFields = ['externalId_openalexId', 'externalId_semanticScholarId', 'externalId_crossref'];
      for (const field of externalIdFields) {
        if (paperData[field] == null || paperData[field] === '') {
          delete paperData[field];
        }
      }

      const newPaper = new Paper(paperData);
      await newPaper.save();
      paperId = newPaper._id;
    }

    if (!paperId) throw { status: 400, message: "paperId or paper object is required" };

    const wp = new WorkspacePaper({
      workspace: workspaceId,
      paper: paperId,
      tags: data.tags || [],
      note: data.note || "",
      source: data.source || "manual",
      addedBy: userId,
    });
    await wp.save();
    return wp;
  }

  static async getWorkspacePapers(workspaceId: string, userId: string, page: number, limit: number, tag?: string) {
    await this.checkRole(workspaceId, userId, ["owner", "editor", "viewer"]);
    const skip = (page - 1) * limit;
    const query: any = { workspace: workspaceId };
    if (tag) query.tags = tag;

    const papers = await WorkspacePaper.find(query)
      .populate("paper")
      .skip(skip)
      .limit(limit)
      .lean();
    const total = await WorkspacePaper.countDocuments(query);
    return { data: papers, total, page, limit, pages: Math.ceil(total / limit) };
  }

  static async uploadPdf(workspaceId: string, userId: string, paperId: string, filePath: string) {
    await this.checkRole(workspaceId, userId, ["owner", "editor"]);
    
    const wp = await WorkspacePaper.findOne({ workspace: workspaceId, paper: paperId });
    if (!wp) throw { status: 404, message: "Paper not found in this workspace" };

    const paper = await Paper.findById(paperId);
    if (!paper) throw { status: 404, message: "Paper not found" };

    paper.pdfUrl = filePath;
    await paper.save();

    return { paper, workspaceId };
  }

  static async createNote(workspaceId: string, userId: string, data: any) {
    await this.checkRole(workspaceId, userId, ["owner", "editor"]);
    const note = new WorkspaceNote({ ...data, workspace: workspaceId, createdBy: userId });
    await note.save();
    return note;
  }

  static async getNotes(workspaceId: string, userId: string, page: number, limit: number) {
    await this.checkRole(workspaceId, userId, ["owner", "editor", "viewer"]);
    const skip = (page - 1) * limit;
    const query = { workspace: workspaceId };
    const notes = await WorkspaceNote.find(query).skip(skip).limit(limit).lean();
    const total = await WorkspaceNote.countDocuments(query);
    return { data: notes, total, page, limit, pages: Math.ceil(total / limit) };
  }

  static async createAlert(workspaceId: string, userId: string, data: any) {
    await this.checkRole(workspaceId, userId, ["owner", "editor"]);
    const alert = new WorkspaceAlert({ ...data, workspace: workspaceId, createdBy: userId });
    await alert.save();
    return alert;
  }

  static async getAlerts(workspaceId: string, userId: string) {
    await this.checkRole(workspaceId, userId, ["owner", "editor", "viewer"]);
    return await WorkspaceAlert.find({ workspace: workspaceId }).lean();
  }
}
