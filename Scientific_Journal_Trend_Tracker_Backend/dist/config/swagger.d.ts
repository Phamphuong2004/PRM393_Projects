declare const swaggerSpec: {
    openapi: string;
    info: {
        title: string;
        version: string;
        description: string;
    };
    servers: {
        url: string;
        description: string;
    }[];
    tags: {
        name: string;
    }[];
    paths: {
        "/health": {
            get: {
                tags: string[];
                summary: string;
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/auth/register": {
            post: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "201": {
                        description: string;
                    };
                };
            };
        };
        "/api/auth/login": {
            post: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/auth/me": {
            get: {
                tags: string[];
                summary: string;
                security: {
                    bearerAuth: never[];
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/papers": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                        default: number;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            post: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "201": {
                        description: string;
                    };
                };
            };
        };
        "/api/papers/{id}": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            put: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            delete: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/papers/search/query": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/keywords": {
            get: {
                tags: string[];
                summary: string;
                parameters: ({
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                        default: number;
                    };
                } | {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                        default: string;
                    };
                })[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            post: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "201": {
                        description: string;
                    };
                };
            };
        };
        "/api/keywords/{id}": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            put: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            delete: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/keywords/trends/trending": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                        default: number;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/journals": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                        default: number;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            post: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "201": {
                        description: string;
                    };
                };
            };
        };
        "/api/journals/{id}": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            put: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            delete: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/topics": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                        default: number;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            post: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "201": {
                        description: string;
                    };
                };
            };
        };
        "/api/topics/{id}": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            put: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            delete: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/users": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                        default: number;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/users/role/{role}": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/users/{id}": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            put: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            delete: {
                tags: string[];
                summary: string;
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/users/{id}/change-password": {
            post: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/analysis-runs": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                        default: number;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            post: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "201": {
                        description: string;
                    };
                };
            };
        };
        "/api/analysis-runs/{id}": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            put: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            delete: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/analysis-runs/keyword/{keywordId}": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/bookmarks": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                        default: number;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/bookmarks/{paperId}/check": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/bookmarks/{paperId}": {
            post: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            delete: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/notifications": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                        default: number;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            delete: {
                tags: string[];
                summary: string;
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/notifications/unread/count": {
            get: {
                tags: string[];
                summary: string;
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/notifications/{id}/read": {
            put: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/notifications/all/read": {
            put: {
                tags: string[];
                summary: string;
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/notifications/{id}": {
            delete: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/follows": {
            get: {
                tags: string[];
                summary: string;
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            post: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/follows/tracked-runs/{analysisRunId}": {
            get: {
                tags: string[];
                summary: string;
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            post: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            delete: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/follows/tracked-runs/{analysisRunId}/notify": {
            put: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/follows/{targetId}": {
            delete: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/publication-trends": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                        default: number;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            post: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "201": {
                        description: string;
                    };
                };
            };
        };
        "/api/publication-trends/{id}": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            put: {
                tags: string[];
                summary: string;
                requestBody: {
                    required: boolean;
                    content: {
                        "application/json": {
                            schema: {
                                $ref: string;
                            };
                        };
                    };
                };
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
            delete: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/publication-trends/keyword/{keywordId}": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/publication-trends/journal/{journalId}": {
            get: {
                tags: string[];
                summary: string;
                parameters: {
                    name: string;
                    in: string;
                    required: boolean;
                    schema: {
                        type: string;
                    };
                }[];
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
        "/api/publication-trends/trending/list": {
            get: {
                tags: string[];
                summary: string;
                responses: {
                    "200": {
                        description: string;
                    };
                };
            };
        };
    };
    components: {
        schemas: {
            RegisterRequest: {
                type: string;
                required: string[];
                properties: {
                    email: {
                        type: string;
                        format: string;
                        example: string;
                    };
                    password: {
                        type: string;
                        format: string;
                        example: string;
                    };
                    fullName: {
                        type: string;
                        example: string;
                    };
                };
            };
            LoginRequest: {
                type: string;
                required: string[];
                properties: {
                    email: {
                        type: string;
                        format: string;
                        example: string;
                    };
                    password: {
                        type: string;
                        format: string;
                        example: string;
                    };
                };
            };
            PaperWriteRequest: {
                type: string;
                required: string[];
                properties: {
                    title: {
                        type: string;
                        example: string;
                    };
                    abstract: {
                        type: string;
                        example: string;
                    };
                    doi: {
                        type: string;
                        example: string;
                    };
                    url: {
                        type: string;
                        example: string;
                    };
                    publicationYear: {
                        type: string;
                        example: number;
                    };
                    publicationMonth: {
                        type: string;
                        example: number;
                    };
                    publishedDate: {
                        type: string;
                        format: string;
                    };
                    citationCount: {
                        type: string;
                        example: number;
                    };
                    externalId_openalexId: {
                        type: string;
                        example: string;
                    };
                    externalId_semanticScholarId: {
                        type: string;
                        example: string;
                    };
                    externalId_crossref: {
                        type: string;
                        example: string;
                    };
                    authors: {
                        type: string;
                        items: {
                            type: string;
                        };
                        example: string[];
                    };
                    journalId: {
                        type: string;
                        example: string;
                    };
                    keywords: {
                        type: string;
                        items: {
                            type: string;
                        };
                        example: string[];
                    };
                    topics: {
                        type: string;
                        items: {
                            type: string;
                        };
                        example: string[];
                    };
                    source: {
                        type: string;
                        example: string;
                    };
                };
            };
            KeywordWriteRequest: {
                type: string;
                required: string[];
                properties: {
                    name: {
                        type: string;
                        example: string;
                    };
                    normalizedText: {
                        type: string;
                        example: string;
                    };
                    openalexId: {
                        type: string;
                        example: string;
                    };
                    workCount: {
                        type: string;
                        example: number;
                    };
                    embedding: {
                        type: string;
                        items: {
                            type: string;
                        };
                    };
                    topic: {
                        type: string;
                        example: string;
                    };
                    canonicalKeyword: {
                        type: string;
                        example: string;
                    };
                    aliases: {
                        type: string;
                        items: {
                            type: string;
                        };
                        example: string[];
                    };
                    paperCount: {
                        type: string;
                        example: number;
                    };
                    citationCount: {
                        type: string;
                        example: number;
                    };
                    yearlyUsage: {
                        type: string;
                        additionalProperties: {
                            type: string;
                        };
                        example: {
                            "2024": number;
                            "2025": number;
                        };
                    };
                    trendScore: {
                        type: string;
                        example: number;
                    };
                    growthRate: {
                        type: string;
                        example: number;
                    };
                    source: {
                        type: string;
                        example: string;
                    };
                };
            };
            JournalWriteRequest: {
                type: string;
                required: string[];
                properties: {
                    name: {
                        type: string;
                        example: string;
                    };
                    issn: {
                        type: string;
                        example: string;
                    };
                    publisher: {
                        type: string;
                        example: string;
                    };
                    impactFactor: {
                        type: string;
                        example: number;
                    };
                    hIndex: {
                        type: string;
                        example: number;
                    };
                    paperCount: {
                        type: string;
                        example: number;
                    };
                    fieldDomain: {
                        type: string;
                        example: string;
                    };
                    isTracked: {
                        type: string;
                        example: boolean;
                    };
                    source: {
                        type: string;
                        example: string;
                    };
                    externalId: {
                        type: string;
                        example: string;
                    };
                };
            };
            TopicWriteRequest: {
                type: string;
                required: string[];
                properties: {
                    name: {
                        type: string;
                        example: string;
                    };
                    seedKeyword: {
                        type: string;
                        example: string;
                    };
                    analysisRunId: {
                        type: string;
                        example: string;
                    };
                    yearlyData: {
                        type: string;
                        additionalProperties: {
                            type: string;
                        };
                        example: {
                            "2024": number;
                            "2025": number;
                        };
                    };
                    trendStatus: {
                        type: string;
                        enum: string[];
                        example: string;
                    };
                    isEmerging: {
                        type: string;
                        example: boolean;
                    };
                    papers: {
                        type: string;
                        items: {
                            type: string;
                        };
                        example: string[];
                    };
                };
            };
            UserUpdateRequest: {
                type: string;
                properties: {
                    fullName: {
                        type: string;
                        example: string;
                    };
                    institution: {
                        type: string;
                        example: string;
                    };
                    bio: {
                        type: string;
                        example: string;
                    };
                    interests: {
                        type: string;
                        items: {
                            type: string;
                        };
                        example: string[];
                    };
                    avatar: {
                        type: string;
                        example: string;
                    };
                    isActive: {
                        type: string;
                        example: boolean;
                    };
                    emailVerified: {
                        type: string;
                        example: boolean;
                    };
                };
            };
            PasswordChangeRequest: {
                type: string;
                required: string[];
                properties: {
                    currentPassword: {
                        type: string;
                        format: string;
                        example: string;
                    };
                    newPassword: {
                        type: string;
                        format: string;
                        example: string;
                    };
                };
            };
            AnalysisRunWriteRequest: {
                type: string;
                required: string[];
                properties: {
                    keywordId: {
                        type: string;
                        example: string;
                    };
                    syncLogId: {
                        type: string;
                        example: string;
                    };
                    seedKeyword: {
                        type: string;
                        example: string;
                    };
                    source: {
                        type: string;
                        example: string;
                    };
                    startYear: {
                        type: string;
                        example: number;
                    };
                    endYear: {
                        type: string;
                        example: number;
                    };
                    status: {
                        type: string;
                        enum: string[];
                        example: string;
                    };
                    yearlyData: {
                        type: string;
                        additionalProperties: {
                            type: string;
                        };
                        example: {
                            "2023": number;
                            "2024": number;
                        };
                    };
                    topicId: {
                        type: string;
                        example: string;
                    };
                };
            };
            FollowRequest: {
                type: string;
                required: string[];
                properties: {
                    targetType: {
                        type: string;
                        enum: string[];
                        example: string;
                    };
                    targetId: {
                        type: string;
                        example: string;
                    };
                    notifyEnabled: {
                        type: string;
                        example: boolean;
                    };
                };
            };
            TrackAnalysisRunRequest: {
                type: string;
                properties: {
                    notifyEnabled: {
                        type: string;
                        example: boolean;
                    };
                };
            };
            NotificationToggleRequest: {
                type: string;
                required: string[];
                properties: {
                    notifyEnabled: {
                        type: string;
                        example: boolean;
                    };
                };
            };
            PublicationTrendWriteRequest: {
                type: string;
                required: string[];
                properties: {
                    keywordId: {
                        type: string;
                        example: string;
                    };
                    journalId: {
                        type: string;
                        example: string;
                    };
                    analysisRunId: {
                        type: string;
                        example: string;
                    };
                    year: {
                        type: string;
                        example: number;
                    };
                    month: {
                        type: string;
                        example: number;
                    };
                    paperCount: {
                        type: string;
                        example: number;
                    };
                    previousCount: {
                        type: string;
                        example: number;
                    };
                    growthRate: {
                        type: string;
                        example: number;
                    };
                    isTrending: {
                        type: string;
                        example: boolean;
                    };
                    calculatedAt: {
                        type: string;
                        format: string;
                    };
                };
            };
        };
        securitySchemes: {
            bearerAuth: {
                type: string;
                scheme: string;
                bearerFormat: string;
            };
        };
    };
};
export default swaggerSpec;
//# sourceMappingURL=swagger.d.ts.map