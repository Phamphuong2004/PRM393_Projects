import { Router } from "express";
import { body } from "express-validator";
import { InstitutionController } from "../controllers/InstitutionController";
import { authMiddleware, roleMiddleware } from "../middleware/auth";

const router = Router();

// Public: list institutions (used by register dropdown) + get one
router.get("/", InstitutionController.getAll);
router.get("/:id", InstitutionController.getById);

// Admin only: create / update / delete
router.post(
  "/",
  authMiddleware,
  roleMiddleware(["admin"]),
  [body("name").notEmpty().withMessage("Institution name is required")],
  InstitutionController.create,
);

router.put(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  InstitutionController.update,
);

router.delete(
  "/:id",
  authMiddleware,
  roleMiddleware(["admin"]),
  InstitutionController.delete,
);

export default router;
