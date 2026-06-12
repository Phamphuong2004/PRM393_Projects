"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const services_1 = require("../services");
const middleware_1 = require("../middleware");
const middleware_2 = require("../middleware");
const router = (0, express_1.Router)();
// Apply rate limiting to auth endpoints
router.use((0, middleware_2.rateLimit)(middleware_2.rateLimits.auth));
// Register endpoint
router.post("/register", middleware_1.validateRegister, middleware_1.validateInputs, async (req, res) => {
    try {
        const { email, password, fullName } = req.body;
        const result = await services_1.AuthService.register(email, password, fullName);
        res.status(201).json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Login endpoint
router.post("/login", middleware_1.validateLogin, middleware_1.validateInputs, async (req, res) => {
    try {
        const { email, password } = req.body;
        const result = await services_1.AuthService.login(email, password);
        res.status(200).json(result);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
// Get current user endpoint
router.get("/me", async (req, res) => {
    try {
        if (!req.userId) {
            res.status(401).json({ message: "Not authenticated" });
            return;
        }
        const user = await services_1.AuthService.getCurrentUser(req.userId);
        res.json(user);
    }
    catch (error) {
        res.status(error.status || 500).json({ message: error.message });
    }
});
exports.default = router;
//# sourceMappingURL=auth.js.map