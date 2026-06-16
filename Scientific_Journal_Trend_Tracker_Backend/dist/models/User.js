"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importStar(require("mongoose"));
const userSchema = new mongoose_1.Schema({
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true,
    },
    password: {
        type: String,
        required: true,
        minlength: 6,
    },
    fullName: {
        type: String,
        required: true,
    },
    role: {
        type: String,
        enum: ["admin", "researcher", "user"],
        default: "researcher",
    },
    institution: String,
    bio: String,
    interests: [String],
    avatar: String,
    isActive: {
        type: Boolean,
        default: true,
    },
    emailVerified: {
        type: Boolean,
        default: false,
    },
    lastLogin: Date,
    bookmarks: [
        {
            type: mongoose_1.Schema.Types.ObjectId,
            ref: "Paper",
        },
    ],
    trackedRuns: [
        {
            analysisRunId: {
                type: mongoose_1.Schema.Types.ObjectId,
                ref: "AnalysisRun",
            },
            notifyEnabled: {
                type: Boolean,
                default: true,
            },
            followedAt: Date,
        },
    ],
    follows: [
        {
            targetType: {
                type: String,
                enum: ["Keyword", "Journal"],
            },
            targetId: mongoose_1.Schema.Types.ObjectId,
            notifyEnabled: {
                type: Boolean,
                default: true,
            },
        },
    ],
}, {
    timestamps: true,
});
exports.default = mongoose_1.default.model("user", userSchema);
//# sourceMappingURL=User.js.map