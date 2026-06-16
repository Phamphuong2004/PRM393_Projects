import jwt from "jsonwebtoken";
export declare class AuthService {
    static register(email: string, password: string, fullName: string): Promise<{
        token: string;
        user: {
            id: any;
            email: string;
            fullName: string;
            role: "admin" | "researcher" | "user";
        };
    }>;
    static login(email: string, password: string): Promise<{
        token: string;
        user: {
            id: any;
            email: string;
            fullName: string;
            role: "admin" | "researcher" | "user";
        };
    }>;
    static getCurrentUser(userId: string): Promise<import("mongoose").Document<unknown, {}, import("../models/User").IUser> & import("../models/User").IUser & {
        _id: import("mongoose").Types.ObjectId;
    }>;
    static validateToken(token: string): Promise<string | jwt.JwtPayload>;
}
//# sourceMappingURL=AuthService.d.ts.map