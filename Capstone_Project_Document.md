# MINISTRY OF EDUCATION AND TRAINING
# FPT UNIVERSITY

## Capstone Project Document
# SCIENTIFIC JOURNAL TREND TRACKER

**Group Members**
- Đặng Thanh Tú - Fulltask - SE184093
- Phạm Đức Thanh Phương - Fulltask - [Student code]
- Trần Đình Phong - Fulltask - [Student code]
- Nguyễn Thành Lợi - Fulltask - [Student code]

**Supervisor:** Nguyễn Xuân Huy
**Ext Supervisor:** 
**Capstone Project code:** 

*- Hanoi, 07/2026 -*

---

## Table of Contents
Acknowledgement
Definition and Acronyms
I. Project Introduction
II. Project Management Plan
III. Software Requirement Specification
IV. Software Design Description
V. Software Testing Documentation
VI. Release Package & User Guides
VII. Appendix

---

## Acknowledgement
We would like to express our deepest gratitude to our supervisor, Mr. Nguyễn Xuân Huy, for his continuous guidance, valuable feedback, and encouragement throughout the development of this Capstone Project. We also extend our thanks to FPT University for providing us with the necessary knowledge and environment to complete this project.

## Definition and Acronyms

| Acronym | Definition |
|---------|------------|
| API | Application Programming Interface |
| JWT | JSON Web Token |
| CORS | Cross-Origin Resource Sharing |
| DOI | Digital Object Identifier |
| ERD | Entity Relationship Diagram |
| GUI | Graphical User Interface |
| PM | Project Manager |
| SDD | Software Design Description |
| SPMP | Software Project Management Plan |
| SRS | Software Requirement Specification |
| UAT | User Acceptance Test |
| UC | Use Case |

---

## I. Project Introduction

### 1. Overview

**1.1 Project Information**
- **Project Name:** Scientific Journal Trend Tracker
- **Project Code:** [Your Project Code]
- **Group Name:** [Your Group Name]

**1.2 Project Team**
- **Đặng Thanh Tú (SE184093):** Developer / Fulltask
- **Phạm Đức Thanh Phương:** Developer / Fulltask
- **Trần Đình Phong:** Developer / Fulltask
- **Nguyễn Thành Lợi:** Developer / Fulltask
- **Supervisor:** Nguyễn Xuân Huy

### 2. Product Background
With the rapid growth of scientific research globally, researchers and students face significant challenges in tracking the latest publication trends, discovering relevant papers efficiently, and organizing collaborative literature reviews. Currently, finding related papers and discussing them often requires switching between multiple unconnected platforms. The "Scientific Journal Trend Tracker" is proposed to solve this problem by offering a unified ecosystem that tracks research trends, enables real-time collaboration, and manages scientific data in a single mobile application.

### 3. Existing Systems
- **Google Scholar:** Excellent for finding papers but lacks collaborative workspaces and real-time discussion features.
- **ResearchGate / Mendeley:** Good for networking and reference management, but they can be complex and lack a dedicated "Workspace" feature for real-time team collaboration and specialized trend tracking.

### 4. Business Opportunity
Academic institutions, researchers, and university students constantly need tools to streamline their literature review and research processes. By providing a modern, mobile-first Flutter application backed by a highly scalable Microservices architecture, our product targets academic users looking for an integrated "research assistant". The inclusion of real-time collaborative Workspaces and Chat sets it apart from traditional academic search engines.

### 5. Software Product Vision
To be the most accessible and collaborative platform for the academic community, allowing researchers to seamlessly discover scientific literature, track emerging publication trends by keywords, and collaborate efficiently in real-time Workspaces. 

### 6. Project Scope & Limitations
- **Scope:** 
  - User Authentication & Authorization.
  - Discovering and browsing Papers, Journals, Keywords, and Authors.
  - Personal features: Bookmarks and Following topics/journals.
  - Real-time Collaboration: Creating Workspaces, pinning papers, and real-time Chat via WebSockets.
  - Admin Dashboard for system statistics.
- **Limitations:** 
  - The system will not host the full-text PDF files directly to avoid copyright infringement; it will store metadata and DOIs.
  - The system will not generate automatic citation formats (like APA, IEEE) in the current version.

---

## II. Project Management Plan

### 1. Overview

**1.1 Scope & Estimation**

| Feature | Complexity | Estimated Effort (Man-day) |
|---------|------------|----------------------------|
| Authentication & User Management | Medium | 10 |
| Core Data Service (Papers, Trends) | Complex | 20 |
| Real-time Workspaces & Chat | Complex | 25 |
| Admin Dashboard | Simple | 7 |
| Mobile App (Flutter GUI & Integration) | Complex | 30 |

**1.2 Project Objectives**
- **Quality:** Ensure 95% API uptime and real-time message delivery within 1 second.
- **Time:** Complete all modules and integration testing within the 14-week Capstone duration.
- **Cost/Effort:** Distributed evenly across UI design, backend microservices development, and testing.

**1.3 Project Risks**

| Risk | Impact | Mitigation Strategy |
|------|--------|---------------------|
| Microservice Communication Failure | High | Implement robust internal API clients with retry mechanisms and error handling. |
| Real-time connection (WebSocket) drops | Medium| Implement Socket.io automatic reconnection and state recovery. |
| Database bottlenecks on Core Service | High | Use MongoDB `$in` for batch queries (Batch API) to solve N+1 query problems. |

### 2. Management Approach

**2.1 Project Process**
The team applies the **Agile/Scrum** software development methodology. The project is divided into multiple Sprints (each lasting 2 weeks). Daily stand-up meetings are conducted to track progress and resolve blockers.

**2.2 Quality Management**
- Conduct peer code reviews before merging pull requests.
- API testing using Postman.
- Mobile UI testing on both Android and iOS emulators.

**2.3 Training Plan**
- Week 1: Training on Flutter UI state management and Node.js Express.
- Week 2: Deep dive into Microservices architecture and internal API security (JWT & Internal Secrets).

### 3. Project Deliverables
- Scientific Journal Trend Tracker - Mobile Application (Flutter).
- Backend Source Code (5 Microservices).
- Project Documentation (SRS, SDD, Test Reports).

### 4. Responsibility Assignments
*(All members participate as Fulltask developers. Specific module assignments are tracked in Jira/Trello)*
- **API Gateway & Auth:** [Assignee]
- **Core Service:** [Assignee]
- **Interaction (Workspaces/Chat):** [Assignee]
- **Frontend App:** [Assignee]

### 5. Project Communications
- **Internal:** Zalo/Discord for daily chat, Google Meet for online meetings.
- **Task Tracking:** Trello or Jira.
- **Source Code Management:** GitHub.

### 6. Configuration Management
- **Document Management:** Google Drive.
- **Source Code Management:** Git Flow branching strategy (Main, Develop, Feature branches).
- **Tools:** VS Code, Android Studio, Postman, MongoDB Compass, Docker.

---

## III. Software Requirement Specification

### 1. Product Overview
The Scientific Journal Trend Tracker consists of a robust backend split into 5 microservices (API Gateway, Auth, Core, Interaction, Admin) and a mobile frontend built with Flutter. It is designed to scale and handle complex cross-service data queries efficiently using Batch APIs and secure internal client communication.

### 2. User Requirements
- **Researcher (User):** Can search papers, view trends, bookmark papers, follow topics, create workspaces, and chat.
- **Admin:** Can manage users, view system-wide analytics (Total users, papers, journals), and monitor sync logs.

### 3. Functional Requirements

**3.1 System Functional Overview**
- **Auth Module:** Register, Login, JWT Generation, Follows, Bookmarks.
- **Core Module:** Paper/Journal CRUD, Keyword Tracking, Trend Analysis.
- **Interaction Module:** Real-time WebSockets, Workspace Management, Chat messaging.
- **Admin Module:** Aggregated Dashboard via API Composition (`Promise.allSettled`).

**3.2 User Authentication**
- **3.2.1 Register/Login:** User authenticates. Auth Service returns JWT.
- **3.2.2 Manage Bookmarks:** User saves paper IDs. Auth service fetches paper details from Core Service via Batch API (`/api/papers/batch`).

**3.3 Collaborative Workspaces**
- **3.3.1 Create Workspace:** Users can create collaborative rooms.
- **3.3.2 Workspace Details:** Interaction Service aggregates data by querying Auth Service (for user profiles) and Core Service (for pinned papers) using internal secured APIs.
- **3.3.3 Real-time Chat:** Users can send messages in Workspaces. Handled via `Socket.io` on port 5000 (proxied via Gateway).

**3.4 Admin Dashboard**
- **3.4.1 View Statistics:** Admin Service calls Auth and Core services simultaneously to gather system counts.

### 4. Non-Functional Requirements
- **4.1 External Interfaces:** The API Gateway acts as the single entry point (Port 5000) for the Flutter app.
- **4.2 Quality Attributes:**
  - **Performance:** Batch API calls must be used across microservices to prevent network congestion (solving N+1 query problem).
  - **Security:** Cross-service communication must be verified using the `x-internal-secret` header.

### 5. Requirement Appendix
**5.1 Business Rules**
- Services must NEVER access each other's databases directly. All cross-service data fetching must go through `internalApiClient.ts`.

---

## IV. Software Design Description

### 1. System Design

**1.1 System Architecture**
The system uses a **Microservices Architecture**:
1. **API Gateway:** Proxies requests to appropriate microservices. Handles CORS.
2. **Auth Service:** Manages `User` collection. Handles authentication.
3. **Core Service:** Manages `Paper`, `Journal`, `Keyword`, `Institution`, `PublicationTrend`.
4. **Interaction Service:** Manages `Workspace`, `Chat`. Runs Socket.io server.
5. **Admin Service:** System administration and dashboard.

**1.2 Package Diagram (Frontend)**
- `lib/features/auth`
- `lib/features/home`
- `lib/features/dashboard`
- `lib/features/workspaces`
- `lib/features/chat`
- `lib/features/admin`
- `lib/features/public`

### 2. Database Design
Each Microservice maintains its own independent MongoDB database to ensure loose coupling:
- **Auth DB:** `Users` (Contains basic info, array of bookmarked paper IDs).
- **Core DB:** `Papers`, `Journals`, `Keywords`, `Authors`, `PublicationTrends`.
- **Interaction DB:** `Workspaces` (Contains member IDs, pinned paper IDs), `Chats`.

### 3. Detailed Design

**3.1 Interaction - Workspace Data Retrieval**
To load a Workspace, the code implements API Composition:
1. Interaction Service receives `GET /api/workspaces/:id`.
2. Identifies member IDs and pinned paper IDs.
3. Uses `internalApiClient` to call Auth Service (to get Member Profiles).
4. Uses `internalApiClient` to call Core Service (to get Paper Details via Batch API).
5. Merges data and returns to Frontend.

---

## V. Software Testing Documentation

### 1. Scope of Testing
- **Unit Testing:** Backend service logic (Internal API clients, Token generation, Batch queries).
- **Integration Testing:** Gateway routing and cross-service communication (Authentication headers validation).
- **System Testing:** Flutter app E2E testing (UI navigation, WebSocket chat real-time capability).

### 2. Test Strategy
- **2.1 Testing Types:** Functional Testing, API Security Testing, Real-time WebSocket Load Testing.
- **2.2 Test Levels:** Component Level (Services isolated), Integration Level (Services combined), System Level (App + Gateway).
- **2.3 Supporting Tools:** Postman (API Testing), Flutter Test (UI).

### 3. Test Plan
- **3.1 Human Resources:** All team members perform testing for their assigned modules.
- **3.2 Test Environment:** Localhost Docker containers for databases and Node.js servers.

---

## VI. Release Package & User Guides

### 1. Deliverable Package

| No. | Deliverable Item | Description |
|-----|------------------|-------------|
| 1 | Source Codes | Flutter App & 5 Backend Microservices |
| 2 | Final Report Document | This Capstone Document |
| 3 | Presentation Slide | Final defense slide deck |

### 2. Installation Guides
**2.1 System Requirements**
- Node.js v18+
- MongoDB
- Flutter SDK v3.10+

**2.2 Installation Instruction**
1. Start MongoDB instances.
2. Configure `.env` files for each microservice (ensure `INTERNAL_API_SECRET` matches across services).
3. Run `npm install` and `npm run dev` in API Gateway, Auth, Core, Interaction, and Admin services.
4. Run `flutter pub get` and `flutter run` in the frontend directory.

### 3. User Manual

**3.1 Overview**
The application allows users to discover scientific papers, view trends, bookmark favorites, and collaborate with peers via Workspaces.

**3.2 Workflow 1: Collaborative Workspace**
1. User navigates to the "Workspaces" tab.
2. Taps "+" to create a new workspace.
3. Invites other members.
4. Pins discovered papers to the workspace.
5. Uses the integrated chat feature to discuss findings in real-time.

---

## VII. Appendix
**1. References**
- Node.js Microservices Best Practices.
- Flutter Documentation.
- Express Gateway & Socket.io integration guides.
