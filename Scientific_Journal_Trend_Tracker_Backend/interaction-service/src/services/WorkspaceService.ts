import mongoose from "mongoose";
import Workspace from "../models/Workspace";
import WorkspacePaper from "../models/WorkspacePaper";
import WorkspaceNote from "../models/WorkspaceNote";
import WorkspaceAlert from "../models/WorkspaceAlert";
// import Paper from "../models/Paper"; // Needs cross-service fetch
// import Notification from "../models/Notification"; // Needs cross-service call

import { SocketService } from "./SocketService";
import axios from "axios";

export class WorkspaceService {
  static async checkRole(workspaceId: string, userId: string, requiredRoles: string[]) {
    const workspace = await Workspace.findById(workspaceId);
    if (!workspace) throw { status: 404, message: "Workspace not found" };

    if (workspace.owner.toString() === userId) return { workspace, role: "owner" };

    const member = workspace.members.find((m: any) => m.user.toString() === userId);
    if (!member) throw { status: 403, message: "Not a member of this workspace" };
    if (member.status === "pending") throw { status: 403, message: "Invitation pending" };

    if (!requiredRoles.includes(member.role)) {
      throw { status: 403, message: `Role ${requiredRoles.join(" or ")} required` };
    }

    return { workspace, role: member.role };
  }

  static async createWorkspace(userId: string, data: any) {
    const workspace = new Workspace({
      ...data,
      owner: userId,
      members: [{ user: userId, role: "owner", status: "accepted" }],
    });
    await workspace.save();
    return workspace;
  }

  static async updateWorkspace(workspaceId: string, userId: string, data: any) {
    await this.checkRole(workspaceId, userId, ["owner", "editor"]);
    const workspace = await Workspace.findByIdAndUpdate(workspaceId, data, { new: true });
    if (!workspace) throw { status: 404, message: "Workspace not found" };
    return workspace;
  }

  static async deleteWorkspace(workspaceId: string, userId: string) {
    await this.checkRole(workspaceId, userId, ["owner"]);
    
    // Cleanup related data
    await Promise.all([
      WorkspacePaper.deleteMany({ workspace: workspaceId }),
      WorkspaceNote.deleteMany({ workspace: workspaceId }),
      WorkspaceAlert.deleteMany({ workspace: workspaceId }),
      Workspace.findByIdAndDelete(workspaceId)
    ]);
    
    return { message: "Workspace and related data deleted successfully" };
  }

  static async getWorkspaces(userId: string, page: number, limit: number) {
    const skip = (page - 1) * limit;
    const query = { $or: [{ owner: userId }, { members: { $elemMatch: { user: userId, status: { $ne: "pending" } } } }] };
    const workspaces = await Workspace.find(query).skip(skip).limit(limit).lean();
    const total = await Workspace.countDocuments(query);
    return { data: workspaces, total, page, limit, pages: Math.ceil(total / limit) };
  }

  static async getPendingInvitations(userId: string) {
    const query = { members: { $elemMatch: { user: userId, status: "pending" } } };
    const workspaces = await Workspace.find(query).lean();
    return workspaces;
  }

  static async respondToInvite(workspaceId: string, userId: string, action: "accept" | "reject") {
    const workspace = await Workspace.findById(workspaceId);
    if (!workspace) throw { status: 404, message: "Workspace not found" };

    const memberIndex = workspace.members.findIndex((m: any) => m.user.toString() === userId);
    if (memberIndex === -1) throw { status: 404, message: "Invitation not found" };

    let actionMessage = "";
    if (action === "accept") {
      workspace.members[memberIndex].status = "accepted";
      actionMessage = "accepted";
    } else {
      workspace.members.splice(memberIndex, 1);
      actionMessage = "rejected";
    }
    await workspace.save();

    // Notify workspace owner
    try {
      const { createInternalClient, SERVICES } = require("../utils/internalApiClient");
      const adminClient = createInternalClient(SERVICES.ADMIN);
      const titleText = `Workspace Invitation ${action === "accept" ? "Accepted" : "Rejected"}`;
      const messageText = `A user has ${actionMessage} your invitation to join the workspace "${workspace.name}".`;
      await adminClient.post(`/api/notifications/internal/bulk`, {
        userIds: [workspace.owner.toString()],
        title: titleText,
        message: messageText,
        type: "workspace",
        refId: workspaceId,
        refType: "Workspace"
      });
    } catch (err: any) {
      console.error("[WorkspaceService] Failed to notify owner about invitation response:", err.message);
    }

    if (action === "accept") {
      return workspace;
    } else {
      return { message: "Invitation rejected" };
    }
  }

  static async getWorkspaceById(workspaceId: string, userId: string, jwtToken?: string) {
    const { workspace, role } = await this.checkRole(workspaceId, userId, ["owner", "editor", "viewer"]);
    const workspaceObj = workspace.toObject();
    
    const { createInternalClient, SERVICES } = require("../utils/internalApiClient");
    const authClient = createInternalClient(SERVICES.AUTH, jwtToken);
    const coreClient = createInternalClient(SERVICES.CORE, jwtToken);

    // 1. Fetch Users
    try {
      const userIds = workspaceObj.members.map((m: any) => m.user.toString());
      const res = await authClient.post("/api/users/batch", { ids: userIds });
      const users = res.data;
      workspaceObj.members = workspaceObj.members.map((m: any) => {
        const u = users.find((u: any) => u._id === m.user.toString());
        return { ...m, user: u || { _id: m.user } };
      });
    } catch (err) {
      console.error("Failed to fetch users for workspace", err);
    }

    const memberCount = workspaceObj.members.length;

    // 2. Fetch Papers & Notes
    const [rawPapers, notes] = await Promise.all([
      WorkspacePaper.find({ workspace: workspaceId }).lean(),
      WorkspaceNote.countDocuments({ workspace: workspaceId }),
    ]);

    // 3. Fetch full paper details from core-service
    let papers = rawPapers;
    try {
      const paperIds = rawPapers.map(p => p.paper.toString());
      if (paperIds.length > 0) {
        const res = await coreClient.post("/api/papers/batch", { ids: paperIds });
        const corePapers = res.data;
        papers = rawPapers.map(wp => {
          const cp = corePapers.find((p: any) => p._id === wp.paper.toString());
          return { ...wp, paper: cp || { _id: wp.paper } };
        });
      }
    } catch (err) {
      console.error("Failed to fetch papers from core", err);
    }

    return {
      workspace: workspaceObj,
      role,
      papers,
      stats: { memberCount, paperCount: papers.length, noteCount: notes },
    };
  }

  static async addMember(workspaceId: string, ownerId: string, email: string, role: string, jwtToken?: string) {
    await this.checkRole(workspaceId, ownerId, ["owner"]);
    
    const { createInternalClient, SERVICES } = require("../utils/internalApiClient");
    const authClient = createInternalClient(SERVICES.AUTH, jwtToken);
    
    let user;
    try {
      const response = await authClient.get(`/api/users/search/email?email=${encodeURIComponent(email)}`);
      user = response.data;
    } catch (err: any) {
      if (err.response && err.response.status === 404) {
        throw { status: 404, message: "User not found" };
      }
      throw { status: 500, message: "Error looking up user" };
    }

    if (!user) throw { status: 404, message: "User not found" };

    const workspace = await Workspace.findById(workspaceId);
    if (!workspace) throw { status: 404, message: "Workspace not found" };

    const memberIndex = workspace.members.findIndex((m: any) => m.user.toString() === user._id.toString());
    if (memberIndex >= 0) {
      workspace.members[memberIndex].role = role as any;
    } else {
      workspace.members.push({ user: user._id as any, role: role as any, status: "pending", addedAt: new Date() });
    }
    await workspace.save();
    return workspace;
  }

  static async removeMember(workspaceId: string, ownerId: string, userIdToRemove: string) {
    const { workspace } = await this.checkRole(workspaceId, ownerId, ["owner"]);
    
    if (workspace.owner.toString() === userIdToRemove) {
      throw { status: 400, message: "Cannot remove the owner of the workspace" };
    }

    workspace.members = workspace.members.filter((m: any) => m.user.toString() !== userIdToRemove) as any;
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

      const existingPaper = null;
      // TODO: Call core-service to find paper by DOI or OpenAlex ID
      // if (paperData.doi) { ... }

      if (existingPaper) {
        paperId = (existingPaper as any)._id;
      } else {
        try {
          // TODO: Call core-service to create a new paper
          // const newPaper = new Paper(paperData);
          // await newPaper.save();
          // paperId = newPaper._id;
          paperId = new mongoose.Types.ObjectId().toString(); // Dummy for now
        } catch (error: any) {
          if (error.code === 11000) {
            throw { status: 409, message: "Paper already exists in the database. Please try adding from Local Database." };
          }
          throw error;
        }
      }
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

    // Check alerts and notify members
    const workspace = await Workspace.findById(workspaceId);
    
    // Cross-service call to core-service to get Paper details
    let paperObj: any = null;
    try {
      const CORE_SERVICE_URL = process.env.CORE_SERVICE_URL || "http://core-service:5002";
      // This endpoint doesn't require auth since we just get public paper data, or we could pass internal token if needed.
      // The current core-service GET /:id requires auth, but if it fails we just gracefully skip alerts.
      // Wait, core-service GET /api/papers/:id DOES NOT require auth according to its routes (line 92: no authMiddleware)!
      const res = await axios.get(`${CORE_SERVICE_URL}/api/papers/${paperId}`);
      paperObj = res.data;
    } catch (err: any) {
      console.error("[WorkspaceService] Failed to fetch paper from core-service:", err.message);
    }

    if (workspace && paperObj) {
      const alerts = await WorkspaceAlert.find({ workspace: workspaceId, notifyEnabled: true });
      let matchedQuery = "";
      for (const alert of alerts) {
        const query = (alert.query || "").toLowerCase();
        if (query) {
          const title = (paperObj.title || "").toLowerCase();
          const abstract = (paperObj.abstract || "").toLowerCase();
          if (title.includes(query) || abstract.includes(query)) {
            matchedQuery = alert.query;
            break;
          }
        }
      }

      if (matchedQuery) {
        const titleText = `New Papers Found!`;
        const messageText = `We found a new paper matching your alert keyword "${matchedQuery}" in workspace "${workspace.name}".`;
        
        const userIds = workspace.members.map((member: any) => member.user.toString());
        
        // Cross-service call to Admin Service to create notifications
        try {
          const ADMIN_SERVICE_URL = process.env.ADMIN_SERVICE_URL || "http://admin-service:5004";
          await axios.post(`${ADMIN_SERVICE_URL}/api/notifications/internal/bulk`, {
            internalSecret: process.env.INTERNAL_API_SECRET,
            userIds,
            title: titleText,
            message: messageText,
            type: "alert",
            refId: workspaceId,
            refType: "Workspace"
          });
        } catch (err: any) {
          console.error("[WorkspaceService] Failed to call admin-service for notifications:", err.message);
        }
      }
    }

    return wp;
  }

  static async removePaper(workspaceId: string, userId: string, paperId: string) {
    await this.checkRole(workspaceId, userId, ["owner", "editor"]);
    const result = await WorkspacePaper.findOneAndDelete({ workspace: workspaceId, paper: paperId });
    if (!result) throw { status: 404, message: "Paper not found in this workspace" };
    return { message: "Paper removed from workspace" };
  }

  static async getWorkspacePapers(workspaceId: string, userId: string, page: number, limit: number, tag?: string, jwtToken?: string) {
    await this.checkRole(workspaceId, userId, ["owner", "editor", "viewer"]);
    const skip = (page - 1) * limit;
    const query: any = { workspace: workspaceId };
    if (tag) query.tags = tag;

    const rawPapers = await WorkspacePaper.find(query)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean();
    const total = await WorkspacePaper.countDocuments(query);

    let papers = rawPapers;
    try {
      const paperIds = rawPapers.map(p => p.paper.toString());
      if (paperIds.length > 0) {
        const { createInternalClient, SERVICES } = require("../utils/internalApiClient");
        const coreClient = createInternalClient(SERVICES.CORE, jwtToken);
        const res = await coreClient.post("/api/papers/batch", { ids: paperIds });
        const corePapers = res.data;
        papers = rawPapers.map(wp => {
          const cp = corePapers.find((p: any) => p._id === wp.paper.toString());
          return { ...wp, paper: cp || { _id: wp.paper } };
        });
      }
    } catch (err) {
      console.error("Failed to fetch papers from core in getWorkspacePapers", err);
    }

    return { data: papers, total, page, limit, pages: Math.ceil(total / limit) };
  }

  static async uploadPdf(workspaceId: string, userId: string, paperId: string, filePath: string) {
    await this.checkRole(workspaceId, userId, ["owner", "editor"]);
    
    const wp = await WorkspacePaper.findOne({ workspace: workspaceId, paper: paperId });
    if (!wp) throw { status: 404, message: "Paper not found in this workspace" };

    // TODO: Cross-service update
    // const paper = await Paper.findById(paperId);
    // if (!paper) throw { status: 404, message: "Paper not found" };
    // paper.pdfUrl = filePath;
    // await paper.save();

    return { paper: { _id: paperId }, workspaceId };
  }

  static async deletePdf(workspaceId: string, userId: string, paperId: string) {
    await this.checkRole(workspaceId, userId, ["owner", "editor"]);
    
    const wp = await WorkspacePaper.findOne({ workspace: workspaceId, paper: paperId });
    if (!wp) throw { status: 404, message: "Paper not found in this workspace" };

    // TODO: Cross-service update
    // const paper = await Paper.findById(paperId);
    // if (!paper) throw { status: 404, message: "Paper not found" };
    // paper.pdfUrl = undefined; // Unset the PDF URL
    // await paper.save();

    return { message: "PDF removed successfully", paper: { _id: paperId }, workspaceId };
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

  static async updateNote(workspaceId: string, userId: string, noteId: string, data: any) {
    await this.checkRole(workspaceId, userId, ["owner", "editor"]);
    const note = await WorkspaceNote.findOneAndUpdate(
      { _id: noteId, workspace: workspaceId },
      data,
      { new: true }
    );
    if (!note) throw { status: 404, message: "Note not found" };
    return note;
  }

  static async deleteNote(workspaceId: string, userId: string, noteId: string) {
    await this.checkRole(workspaceId, userId, ["owner", "editor"]);
    const result = await WorkspaceNote.findOneAndDelete({ _id: noteId, workspace: workspaceId });
    if (!result) throw { status: 404, message: "Note not found" };
    return { message: "Note deleted" };
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

  static async deleteAlert(workspaceId: string, userId: string, alertId: string) {
    await this.checkRole(workspaceId, userId, ["owner", "editor"]);
    const result = await WorkspaceAlert.findOneAndDelete({ _id: alertId, workspace: workspaceId });
    if (!result) throw { status: 404, message: "Alert not found" };
    return { message: "Alert deleted" };
  }
}
