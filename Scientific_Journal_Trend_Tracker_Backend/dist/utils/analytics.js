"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isEmergingKeyword = exports.normalizeTrendStatus = exports.calculateGrowthRate = exports.calculateTrendScore = exports.getPaginationParams = void 0;
const getPaginationParams = (page, limit) => {
    const pageNum = Math.max(1, parseInt(page || "1"));
    const limitNum = Math.max(1, Math.min(100, parseInt(limit || "10")));
    const skip = (pageNum - 1) * limitNum;
    return { pageNum, limitNum, skip };
};
exports.getPaginationParams = getPaginationParams;
const calculateTrendScore = (yearlyData) => {
    if (!yearlyData || yearlyData.size < 2)
        return 0;
    const values = Array.from(yearlyData.values());
    const recentValues = values.slice(-3);
    const olderValues = values.slice(0, -3);
    if (olderValues.length === 0)
        return 0;
    const recentAvg = recentValues.reduce((a, b) => a + b, 0) / recentValues.length;
    const olderAvg = olderValues.reduce((a, b) => a + b, 0) / olderValues.length;
    return ((recentAvg - olderAvg) / olderAvg) * 100;
};
exports.calculateTrendScore = calculateTrendScore;
const calculateGrowthRate = (startValue, endValue, years = 1) => {
    if (startValue === 0 || years === 0)
        return 0;
    return ((endValue / startValue) ** (1 / years) - 1) * 100;
};
exports.calculateGrowthRate = calculateGrowthRate;
const normalizeTrendStatus = (growthRate) => {
    if (growthRate > 50)
        return "emerging";
    if (growthRate > 10)
        return "growing";
    if (growthRate > -10)
        return "stable";
    return "declining";
};
exports.normalizeTrendStatus = normalizeTrendStatus;
const isEmergingKeyword = (trendScore, minPaperCount = 5, paperCount = 999) => {
    return trendScore > 30 && paperCount >= minPaperCount;
};
exports.isEmergingKeyword = isEmergingKeyword;
//# sourceMappingURL=analytics.js.map