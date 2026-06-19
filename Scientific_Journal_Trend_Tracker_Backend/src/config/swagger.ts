const isProduction = process.env.NODE_ENV === "production";

const swaggerSpec = {
  openapi: "3.0.3",
  info: {
    title: "Scientific Journal Trend Tracker API",
    version: "1.0.0",
    description:
      "API documentation for Scientific Journal Trend Tracker backend",
  },
  servers: [
    {
      url: isProduction
        ? "https://prm393-projects-journal-tracking.up.railway.app"
        : "http://localhost:5000",
      description: isProduction
        ? "Production server (Railway)"
        : "Local development server",
    },
  ],
  security: [{ bearerAuth: [] }],
  tags: [
    { name: "Health" },
    { name: "Auth" },
    { name: "Papers" },
    { name: "Keywords" },
    { name: "Journals" },
    { name: "Topics" },
    { name: "Users" },
    { name: "AnalysisRuns" },
    { name: "Bookmarks" },
    { name: "Notifications" },
    { name: "Follows" },
    { name: "PublicationTrends" },
  ],
  paths: {
    "/health": {
      get: {
        tags: ["Health"],
        summary: "Health check",
        security: [],
        responses: {
          "200": {
            description: "Service is healthy",
          },
        },
      },
    },
    "/api/auth/register": {
      post: {
        tags: ["Auth"],
        summary: "Register a new user",
        security: [],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/RegisterRequest" },
            },
          },
        },
        responses: { "201": { description: "Created" } },
      },
    },
    "/api/auth/login": {
      post: {
        tags: ["Auth"],
        summary: "Login and receive JWT",
        security: [],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/LoginRequest" },
            },
          },
        },
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/auth/me": {
      get: {
        tags: ["Auth"],
        summary: "Get current user",
        security: [{ bearerAuth: [] }],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/papers": {
      get: {
        tags: ["Papers"],
        summary: "List papers",
        parameters: [
          {
            name: "page",
            in: "query",
            required: false,
            schema: { type: "integer", default: 1 },
          },
          {
            name: "limit",
            in: "query",
            required: false,
            schema: { type: "integer", default: 10 },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      post: {
        tags: ["Papers"],
        summary: "Create paper",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/PaperWriteRequest" },
            },
          },
        },
        responses: { "201": { description: "Created" } },
      },
    },
    "/api/papers/{id}": {
      get: {
        tags: ["Papers"],
        summary: "Get paper by ID",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      put: {
        tags: ["Papers"],
        summary: "Update paper",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/PaperWriteRequest" },
            },
          },
        },
        responses: { "200": { description: "OK" } },
      },
      delete: {
        tags: ["Papers"],
        summary: "Delete paper",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/papers/search/query": {
      get: {
        tags: ["Papers"],
        summary: "Search papers",
        parameters: [
          {
            name: "q",
            in: "query",
            required: false,
            schema: { type: "string" },
          },
          {
            name: "year",
            in: "query",
            required: false,
            schema: { type: "integer" },
          },
          {
            name: "journalId",
            in: "query",
            required: false,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/papers/external/search": {
      get: {
        tags: ["Papers"],
        summary: "Search papers externally (e.g. Semantic Scholar)",
        parameters: [
          {
            name: "q",
            in: "query",
            required: true,
            schema: { type: "string" },
          },
          {
            name: "limit",
            in: "query",
            required: false,
            schema: { type: "integer", default: 10 },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/keywords": {
      get: {
        tags: ["Keywords"],
        summary: "List keywords",
        parameters: [
          {
            name: "page",
            in: "query",
            required: false,
            schema: { type: "integer", default: 1 },
          },
          {
            name: "limit",
            in: "query",
            required: false,
            schema: { type: "integer", default: 20 },
          },
          {
            name: "sort",
            in: "query",
            required: false,
            schema: { type: "string", default: "-trendScore" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      post: {
        tags: ["Keywords"],
        summary: "Create keyword",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/KeywordWriteRequest" },
            },
          },
        },
        responses: { "201": { description: "Created" } },
      },
    },
    "/api/keywords/{id}": {
      get: {
        tags: ["Keywords"],
        summary: "Get keyword by ID",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      put: {
        tags: ["Keywords"],
        summary: "Update keyword",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/KeywordWriteRequest" },
            },
          },
        },
        responses: { "200": { description: "OK" } },
      },
      delete: {
        tags: ["Keywords"],
        summary: "Delete keyword",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/keywords/trends/trending": {
      get: {
        tags: ["Keywords"],
        summary: "Get trending keywords",
        parameters: [
          {
            name: "limit",
            in: "query",
            required: false,
            schema: { type: "integer", default: 20 },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/journals": {
      get: {
        tags: ["Journals"],
        summary: "List journals",
        parameters: [
          {
            name: "page",
            in: "query",
            required: false,
            schema: { type: "integer", default: 1 },
          },
          {
            name: "limit",
            in: "query",
            required: false,
            schema: { type: "integer", default: 10 },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      post: {
        tags: ["Journals"],
        summary: "Create journal",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/JournalWriteRequest" },
            },
          },
        },
        responses: { "201": { description: "Created" } },
      },
    },
    "/api/journals/{id}": {
      get: {
        tags: ["Journals"],
        summary: "Get journal by ID",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      put: {
        tags: ["Journals"],
        summary: "Update journal",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/JournalWriteRequest" },
            },
          },
        },
        responses: { "200": { description: "OK" } },
      },
      delete: {
        tags: ["Journals"],
        summary: "Delete journal",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/topics": {
      get: {
        tags: ["Topics"],
        summary: "List topics",
        parameters: [
          {
            name: "page",
            in: "query",
            required: false,
            schema: { type: "integer", default: 1 },
          },
          {
            name: "limit",
            in: "query",
            required: false,
            schema: { type: "integer", default: 10 },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      post: {
        tags: ["Topics"],
        summary: "Create topic",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/TopicWriteRequest" },
            },
          },
        },
        responses: { "201": { description: "Created" } },
      },
    },
    "/api/topics/{id}": {
      get: {
        tags: ["Topics"],
        summary: "Get topic by ID",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      put: {
        tags: ["Topics"],
        summary: "Update topic",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/TopicWriteRequest" },
            },
          },
        },
        responses: { "200": { description: "OK" } },
      },
      delete: {
        tags: ["Topics"],
        summary: "Delete topic",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/users": {
      get: {
        tags: ["Users"],
        summary: "List users",
        parameters: [
          {
            name: "page",
            in: "query",
            required: false,
            schema: { type: "integer", default: 1 },
          },
          {
            name: "limit",
            in: "query",
            required: false,
            schema: { type: "integer", default: 10 },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/users/role/{role}": {
      get: {
        tags: ["Users"],
        summary: "Get users by role",
        parameters: [
          {
            name: "role",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/users/{id}": {
      get: {
        tags: ["Users"],
        summary: "Get user by ID",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      put: {
        tags: ["Users"],
        summary: "Update user profile",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/UserUpdateRequest" },
            },
          },
        },
        responses: { "200": { description: "OK" } },
      },
      delete: {
        tags: ["Users"],
        summary: "Delete user",
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/users/{id}/change-password": {
      post: {
        tags: ["Users"],
        summary: "Change user password",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/PasswordChangeRequest" },
            },
          },
        },
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/analysis-runs": {
      get: {
        tags: ["AnalysisRuns"],
        summary: "List analysis runs",
        parameters: [
          {
            name: "page",
            in: "query",
            required: false,
            schema: { type: "integer", default: 1 },
          },
          {
            name: "limit",
            in: "query",
            required: false,
            schema: { type: "integer", default: 10 },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      post: {
        tags: ["AnalysisRuns"],
        summary: "Create analysis run",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/AnalysisRunWriteRequest" },
            },
          },
        },
        responses: { "201": { description: "Created" } },
      },
    },
    "/api/analysis-runs/{id}": {
      get: {
        tags: ["AnalysisRuns"],
        summary: "Get analysis run by ID",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      put: {
        tags: ["AnalysisRuns"],
        summary: "Update analysis run",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/AnalysisRunWriteRequest" },
            },
          },
        },
        responses: { "200": { description: "OK" } },
      },
      delete: {
        tags: ["AnalysisRuns"],
        summary: "Delete analysis run",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/analysis-runs/keyword/{keywordId}": {
      get: {
        tags: ["AnalysisRuns"],
        summary: "Get analysis runs by keyword",
        parameters: [
          {
            name: "keywordId",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/bookmarks": {
      get: {
        tags: ["Bookmarks"],
        summary: "List bookmarks",
        parameters: [
          {
            name: "page",
            in: "query",
            required: false,
            schema: { type: "integer", default: 1 },
          },
          {
            name: "limit",
            in: "query",
            required: false,
            schema: { type: "integer", default: 20 },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/bookmarks/{paperId}/check": {
      get: {
        tags: ["Bookmarks"],
        summary: "Check if paper is bookmarked",
        parameters: [
          {
            name: "paperId",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/bookmarks/{paperId}": {
      post: {
        tags: ["Bookmarks"],
        summary: "Add bookmark",
        parameters: [
          {
            name: "paperId",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      delete: {
        tags: ["Bookmarks"],
        summary: "Remove bookmark",
        parameters: [
          {
            name: "paperId",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/notifications": {
      get: {
        tags: ["Notifications"],
        summary: "List notifications",
        parameters: [
          {
            name: "page",
            in: "query",
            required: false,
            schema: { type: "integer", default: 1 },
          },
          {
            name: "limit",
            in: "query",
            required: false,
            schema: { type: "integer", default: 20 },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      delete: {
        tags: ["Notifications"],
        summary: "Clear all notifications",
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/notifications/unread/count": {
      get: {
        tags: ["Notifications"],
        summary: "Get unread notification count",
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/notifications/{id}/read": {
      put: {
        tags: ["Notifications"],
        summary: "Mark notification as read",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/notifications/all/read": {
      put: {
        tags: ["Notifications"],
        summary: "Mark all notifications as read",
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/notifications/{id}": {
      delete: {
        tags: ["Notifications"],
        summary: "Delete notification",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/follows": {
      get: {
        tags: ["Follows"],
        summary: "List follows",
        responses: { "200": { description: "OK" } },
      },
      post: {
        tags: ["Follows"],
        summary: "Follow item",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/FollowRequest" },
            },
          },
        },
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/follows/tracked-runs/{analysisRunId}": {
      get: {
        tags: ["Follows"],
        summary: "Get user tracked runs",
        responses: { "200": { description: "OK" } },
      },
      post: {
        tags: ["Follows"],
        summary: "Track an analysis run",
        requestBody: {
          required: false,
          content: {
            "application/json": {
              schema: { $ref: "#/components/schemas/TrackAnalysisRunRequest" },
            },
          },
        },
        responses: { "200": { description: "OK" } },
      },
      delete: {
        tags: ["Follows"],
        summary: "Untrack analysis run",
        parameters: [
          {
            name: "analysisRunId",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/follows/tracked-runs/{analysisRunId}/notify": {
      put: {
        tags: ["Follows"],
        summary: "Update tracked run notification setting",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                $ref: "#/components/schemas/NotificationToggleRequest",
              },
            },
          },
        },
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/follows/{targetId}": {
      delete: {
        tags: ["Follows"],
        summary: "Unfollow keyword or journal",
        parameters: [
          {
            name: "targetId",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/publication-trends": {
      get: {
        tags: ["PublicationTrends"],
        summary: "List publication trends",
        parameters: [
          {
            name: "page",
            in: "query",
            required: false,
            schema: { type: "integer", default: 1 },
          },
          {
            name: "limit",
            in: "query",
            required: false,
            schema: { type: "integer", default: 10 },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      post: {
        tags: ["PublicationTrends"],
        summary: "Create publication trend",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                $ref: "#/components/schemas/PublicationTrendWriteRequest",
              },
            },
          },
        },
        responses: { "201": { description: "Created" } },
      },
    },
    "/api/publication-trends/{id}": {
      get: {
        tags: ["PublicationTrends"],
        summary: "Get publication trend by ID",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
      put: {
        tags: ["PublicationTrends"],
        summary: "Update publication trend",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                $ref: "#/components/schemas/PublicationTrendWriteRequest",
              },
            },
          },
        },
        responses: { "200": { description: "OK" } },
      },
      delete: {
        tags: ["PublicationTrends"],
        summary: "Delete publication trend",
        parameters: [
          {
            name: "id",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/publication-trends/keyword/{keywordId}": {
      get: {
        tags: ["PublicationTrends"],
        summary: "Get trends by keyword",
        parameters: [
          {
            name: "keywordId",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/publication-trends/journal/{journalId}": {
      get: {
        tags: ["PublicationTrends"],
        summary: "Get trends by journal",
        parameters: [
          {
            name: "journalId",
            in: "path",
            required: true,
            schema: { type: "string" },
          },
        ],
        responses: { "200": { description: "OK" } },
      },
    },
    "/api/publication-trends/trending/list": {
      get: {
        tags: ["PublicationTrends"],
        summary: "Get trending publications",
        responses: { "200": { description: "OK" } },
      },
    },
  },
  components: {
    schemas: {
      RegisterRequest: {
        type: "object",
        required: ["email", "password", "fullName"],
        properties: {
          email: {
            type: "string",
            format: "email",
            example: "researcher@example.com",
          },
          password: {
            type: "string",
            format: "password",
            example: "Password123!",
          },
          fullName: {
            type: "string",
            example: "Nguyen Van A",
          },
        },
      },
      LoginRequest: {
        type: "object",
        required: ["email", "password"],
        properties: {
          email: {
            type: "string",
            format: "email",
            example: "researcher@example.com",
          },
          password: {
            type: "string",
            format: "password",
            example: "Password123!",
          },
        },
      },
      PaperWriteRequest: {
        type: "object",
        required: ["title"],
        properties: {
          title: { type: "string", example: "Trends in Scientific Publishing" },
          abstract: {
            type: "string",
            example: "A study of publication trends.",
          },
          doi: { type: "string", example: "10.1000/example-doi" },
          url: { type: "string", example: "https://example.org/paper" },
          publicationYear: { type: "integer", example: 2026 },
          publicationMonth: { type: "integer", example: 5 },
          publishedDate: { type: "string", format: "date-time" },
          citationCount: { type: "integer", example: 12 },
          externalId_openalexId: { type: "string", example: "W123456789" },
          externalId_semanticScholarId: { type: "string", example: "abc123" },
          externalId_crossref: { type: "string", example: "crossref-id" },
          authors: {
            type: "array",
            items: { type: "string" },
            example: ["664f1d...", "664f2e..."],
          },
          journalId: { type: "string", example: "664f1d..." },
          keywords: {
            type: "array",
            items: { type: "string" },
            example: ["664f3a..."],
          },
          topics: {
            type: "array",
            items: { type: "string" },
            example: ["664f4b..."],
          },
          source: { type: "string", example: "openalex" },
        },
      },
      KeywordWriteRequest: {
        type: "object",
        required: ["name"],
        properties: {
          name: { type: "string", example: "machine learning" },
          normalizedText: { type: "string", example: "machine learning" },
          openalexId: { type: "string", example: "W123456" },
          workCount: { type: "integer", example: 200 },
          embedding: { type: "array", items: { type: "number" } },
          topic: { type: "string", example: "AI" },
          canonicalKeyword: { type: "string", example: "Machine Learning" },
          aliases: {
            type: "array",
            items: { type: "string" },
            example: ["ML", "machine learning"],
          },
          paperCount: { type: "integer", example: 50 },
          citationCount: { type: "integer", example: 1200 },
          yearlyUsage: {
            type: "object",
            additionalProperties: { type: "number" },
            example: { "2024": 10, "2025": 15 },
          },
          trendScore: { type: "number", example: 35 },
          growthRate: { type: "number", example: 12.5 },
          source: { type: "string", example: "openalex" },
        },
      },
      JournalWriteRequest: {
        type: "object",
        required: ["name"],
        properties: {
          name: { type: "string", example: "Nature" },
          issn: { type: "string", example: "1476-4687" },
          publisher: { type: "string", example: "Springer Nature" },
          impactFactor: { type: "number", example: 64.8 },
          hIndex: { type: "integer", example: 300 },
          paperCount: { type: "integer", example: 5000 },
          fieldDomain: { type: "string", example: "General Science" },
          isTracked: { type: "boolean", example: true },
          source: { type: "string", example: "manual" },
          externalId: { type: "string", example: "journal-123" },
        },
      },
      TopicWriteRequest: {
        type: "object",
        required: ["name", "analysisRunId"],
        properties: {
          name: { type: "string", example: "AI in Healthcare" },
          seedKeyword: { type: "string", example: "healthcare AI" },
          analysisRunId: { type: "string", example: "664f1d..." },
          yearlyData: {
            type: "object",
            additionalProperties: { type: "number" },
            example: { "2024": 20, "2025": 25 },
          },
          trendStatus: {
            type: "string",
            enum: ["emerging", "growing", "stable", "declining"],
            example: "growing",
          },
          isEmerging: { type: "boolean", example: true },
          papers: {
            type: "array",
            items: { type: "string" },
            example: ["664f2e..."],
          },
        },
      },
      UserUpdateRequest: {
        type: "object",
        properties: {
          fullName: { type: "string", example: "Nguyen Van A" },
          institution: { type: "string", example: "University of Science" },
          bio: { type: "string", example: "Researcher in data science" },
          interests: {
            type: "array",
            items: { type: "string" },
            example: ["AI", "ML"],
          },
          avatar: { type: "string", example: "https://example.com/avatar.png" },
          isActive: { type: "boolean", example: true },
          emailVerified: { type: "boolean", example: false },
        },
      },
      PasswordChangeRequest: {
        type: "object",
        required: ["currentPassword", "newPassword"],
        properties: {
          currentPassword: {
            type: "string",
            format: "password",
            example: "OldPassword123!",
          },
          newPassword: {
            type: "string",
            format: "password",
            example: "NewPassword123!",
          },
        },
      },
      AnalysisRunWriteRequest: {
        type: "object",
        required: ["keywordId", "seedKeyword"],
        properties: {
          keywordId: { type: "string", example: "664f1d..." },
          syncLogId: { type: "string", example: "664f2e..." },
          seedKeyword: { type: "string", example: "deep learning" },
          source: { type: "string", example: "openalex" },
          startYear: { type: "integer", example: 2020 },
          endYear: { type: "integer", example: 2025 },
          status: {
            type: "string",
            enum: ["pending", "running", "completed", "failed"],
            example: "running",
          },
          yearlyData: {
            type: "object",
            additionalProperties: { type: "number" },
            example: { "2023": 10, "2024": 15 },
          },
          topicId: { type: "string", example: "664f4b..." },
        },
      },
      FollowRequest: {
        type: "object",
        required: ["targetType", "targetId"],
        properties: {
          targetType: {
            type: "string",
            enum: ["Keyword", "Journal"],
            example: "Keyword",
          },
          targetId: { type: "string", example: "664f1d..." },
          notifyEnabled: { type: "boolean", example: true },
        },
      },
      TrackAnalysisRunRequest: {
        type: "object",
        properties: {
          notifyEnabled: { type: "boolean", example: true },
        },
      },
      NotificationToggleRequest: {
        type: "object",
        required: ["notifyEnabled"],
        properties: {
          notifyEnabled: { type: "boolean", example: true },
        },
      },
      PublicationTrendWriteRequest: {
        type: "object",
        required: [
          "keywordId",
          "analysisRunId",
          "year",
          "paperCount",
          "growthRate",
        ],
        properties: {
          keywordId: { type: "string", example: "664f1d..." },
          journalId: { type: "string", example: "664f2e..." },
          analysisRunId: { type: "string", example: "664f3a..." },
          year: { type: "integer", example: 2025 },
          month: { type: "integer", example: 5 },
          paperCount: { type: "integer", example: 120 },
          previousCount: { type: "integer", example: 100 },
          growthRate: { type: "number", example: 20 },
          isTrending: { type: "boolean", example: true },
          calculatedAt: { type: "string", format: "date-time" },
        },
      },
    },
    securitySchemes: {
      bearerAuth: {
        type: "http",
        scheme: "bearer",
        bearerFormat: "JWT",
      },
    },
  },
};

export default swaggerSpec;
