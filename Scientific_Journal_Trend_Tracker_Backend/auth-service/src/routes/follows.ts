import { Router } from "express";
import { authMiddleware, rateLimit, rateLimits } from "../middleware";
import { FollowController } from "../controllers/FollowController";

const router = Router();

// Apply rate limiting
router.use(authMiddleware);
router.use(rateLimit(rateLimits.api));

router.get("/", FollowController.getUserFollows);
router.post("/", FollowController.followTarget);
router.delete("/", FollowController.unfollowTarget);
router.get("/check", FollowController.checkFollow);
router.get("/feed", FollowController.getDashboardFeed);

export default router;
