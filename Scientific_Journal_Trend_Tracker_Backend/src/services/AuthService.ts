import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/User";
import { OAuth2Client } from "google-auth-library";
import crypto from "crypto";

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

export class AuthService {
  static async register(
    email: string,
    password: string,
    fullName: string,
    role?: string,
    institution?: string,
  ) {
    // Check if user exists
    let user = await User.findOne({ email });
    if (user) {
      throw { status: 400, message: "User already exists" };
    }

    // Hash password
    const salt = await bcrypt.genSalt(
      parseInt(process.env.BCRYPT_ROUNDS || "10"),
    );
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create user (role defaults to "researcher" via schema if not provided)
    user = new User({
      email,
      password: hashedPassword,
      fullName,
      ...(role ? { role } : {}),
      ...(institution ? { institution } : {}),
    });

    await user.save();

    // Generate token
    const token = jwt.sign(
      { userId: user._id, email: user.email, role: user.role },
      process.env.JWT_SECRET || "your-secret-key",
      { expiresIn: "7d" },
    );

    return {
      token,
      user: {
        id: user._id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        institution: user.institution,
      },
    };
  }

  static async login(email: string, password: string) {
    // Check if user exists
    const user = await User.findOne({ email });
    if (!user) {
      throw { status: 400, message: "Invalid email or password" };
    }

    // Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      throw { status: 400, message: "Invalid email or password" };
    }

    // Update last login
    user.lastLogin = new Date();
    await user.save();

    // Generate token
    const token = jwt.sign(
      { userId: user._id, email: user.email, role: user.role },
      process.env.JWT_SECRET || "your-secret-key",
      { expiresIn: "7d" },
    );

    return {
      token,
      user: {
        id: user._id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        institution: user.institution,
      },
    };
  }

  static async getCurrentUser(userId: string) {
    const user = await User.findById(userId)
      .select("-password")
      .populate(["bookmarks", "follows", "trackedRuns"]);

    if (!user) {
      throw { status: 404, message: "User not found" };
    }

    return user;
  }

  static async googleLogin(idToken: string) {
    let payload;
    try {
      const ticket = await client.verifyIdToken({
        idToken,
        audience: process.env.GOOGLE_CLIENT_ID,
      });
      payload = ticket.getPayload();
    } catch (error) {
      throw { status: 401, message: "Invalid Google ID token" };
    }

    if (!payload || !payload.email) {
      throw { status: 400, message: "Google token did not contain an email" };
    }

    const { email, name, picture } = payload;
    let user = await User.findOne({ email });

    if (!user) {
      // Create new user with a random password since they use Google Login
      const randomPassword = crypto.randomBytes(32).toString("hex");
      const salt = await bcrypt.genSalt(
        parseInt(process.env.BCRYPT_ROUNDS || "10"),
      );
      const hashedPassword = await bcrypt.hash(randomPassword, salt);

      user = new User({
        email,
        password: hashedPassword,
        fullName: name || "Google User",
        role: "student", // default role for Google users as per plan
        avatar: picture,
        emailVerified: true,
      });
      await user.save();
    } else {
      // Update avatar if provided and verify email
      if (picture && !user.avatar) {
        user.avatar = picture;
      }
      user.emailVerified = true;
      user.lastLogin = new Date();
      await user.save();
    }

    const token = jwt.sign(
      { userId: user._id, email: user.email, role: user.role },
      process.env.JWT_SECRET || "your-secret-key",
      { expiresIn: "7d" },
    );

    return {
      token,
      user: {
        id: user._id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        institution: user.institution,
        avatar: user.avatar,
      },
    };
  }

  static async validateToken(token: string) {
    try {
      const decoded = jwt.verify(
        token,
        process.env.JWT_SECRET || "your-secret-key",
      );
      return decoded;
    } catch (error) {
      throw { status: 401, message: "Invalid token" };
    }
  }
}
