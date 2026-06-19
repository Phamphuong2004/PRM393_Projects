import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/User";

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
