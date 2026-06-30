import { Router, Request, Response } from "express";
import { AuthService } from "../services";
import { validateRegister, validateLogin, validateInputs, authMiddleware } from "../middleware";
import { rateLimit, rateLimits } from "../middleware";

const router = Router();

// Apply rate limiting to auth endpoints
router.use(rateLimit(rateLimits.auth));

// Register endpoint
router.post(
  "/register",
  validateRegister,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const { email, password, fullName, role, institution } = req.body;
      const result = await AuthService.register(
        email,
        password,
        fullName,
        role,
        institution,
      );
      res.status(201).json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Login endpoint
router.post(
  "/login",
  validateLogin,
  validateInputs,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const { email, password } = req.body;
      const result = await AuthService.login(email, password);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Google Login endpoint
router.post(
  "/google-login",
  async (req: Request, res: Response): Promise<void> => {
    try {
      const { idToken } = req.body;
      if (!idToken) {
        res.status(400).json({ message: "ID token is required" });
        return;
      }
      const result = await AuthService.googleLogin(idToken);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(error.status || 500).json({ message: error.message });
    }
  },
);

// Get current user endpoint
router.get("/me", authMiddleware, async (req: Request, res: Response): Promise<void> => {
  try {
    if (!req.userId) {
      res.status(401).json({ message: "Not authenticated" });
      return;
    }
    const user = await AuthService.getCurrentUser(req.userId);
    res.json(user);
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});

export default router;
