export declare const getPaginationParams: (page: string | undefined, limit: string | undefined) => {
    pageNum: number;
    limitNum: number;
    skip: number;
};
export declare const calculateTrendScore: (yearlyData: Map<string, number>) => number;
export declare const calculateGrowthRate: (startValue: number, endValue: number, years?: number) => number;
export declare const normalizeTrendStatus: (growthRate: number) => "emerging" | "growing" | "stable" | "declining";
export declare const isEmergingKeyword: (trendScore: number, minPaperCount?: number, paperCount?: number) => boolean;
//# sourceMappingURL=analytics.d.ts.map