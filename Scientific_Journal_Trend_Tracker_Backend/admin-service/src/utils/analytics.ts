export const getPaginationParams = (
  page: string | undefined,
  limit: string | undefined,
) => {
  const pageNum = Math.max(1, parseInt(page || "1"));
  const limitNum = Math.max(1, Math.min(100, parseInt(limit || "10")));
  const skip = (pageNum - 1) * limitNum;

  return { pageNum, limitNum, skip };
};

export const calculateTrendScore = (
  yearlyData: Map<string, number>,
): number => {
  if (!yearlyData || yearlyData.size < 2) return 0;

  const values = Array.from(yearlyData.values());
  const recentValues = values.slice(-3);
  const olderValues = values.slice(0, -3);

  if (olderValues.length === 0) return 0;

  const recentAvg =
    recentValues.reduce((a, b) => a + b, 0) / recentValues.length;
  const olderAvg = olderValues.reduce((a, b) => a + b, 0) / olderValues.length;

  return ((recentAvg - olderAvg) / olderAvg) * 100;
};

export const calculateGrowthRate = (
  startValue: number,
  endValue: number,
  years: number = 1,
): number => {
  if (startValue === 0 || years === 0) return 0;
  return ((endValue / startValue) ** (1 / years) - 1) * 100;
};

export const normalizeTrendStatus = (
  growthRate: number,
): "emerging" | "growing" | "stable" | "declining" => {
  if (growthRate > 50) return "emerging";
  if (growthRate > 10) return "growing";
  if (growthRate > -10) return "stable";
  return "declining";
};

export const isEmergingKeyword = (
  trendScore: number,
  minPaperCount: number = 5,
  paperCount: number = 999,
): boolean => {
  return trendScore > 30 && paperCount >= minPaperCount;
};
