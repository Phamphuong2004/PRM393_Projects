export declare class BookmarkService {
    static getUserBookmarks(userId: string, page?: number, limit?: number): Promise<{
        bookmarks: import("mongoose").Types.ObjectId[];
        total: number;
        pages: number;
    }>;
    static checkBookmark(userId: string, paperId: string): Promise<{
        isBookmarked: boolean;
    }>;
    static addBookmark(userId: string, paperId: string): Promise<{
        message: string;
        bookmarks: import("mongoose").Types.ObjectId[];
    }>;
    static removeBookmark(userId: string, paperId: string): Promise<{
        message: string;
        bookmarks: import("mongoose").Types.ObjectId[];
    }>;
    static clearAllBookmarks(userId: string): Promise<{
        message: string;
    }>;
    static getBookmarkCount(userId: string): Promise<{
        count: number;
    }>;
}
//# sourceMappingURL=BookmarkService.d.ts.map