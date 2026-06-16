# Controllers Architecture

## Overview

Controllers contain the business logic for handling requests and responses. Each controller is organized as a static class with methods for different operations.

## Controllers Available

### 1. AuthController

Handles user authentication and authorization.

**Methods:**

- `register()` - Create new user account
- `login()` - Authenticate user and return JWT token
- `getCurrentUser()` - Get authenticated user's profile

### 2. PaperController

Manages academic paper operations.

**Methods:**

- `getAllPapers()` - List papers with pagination
- `getPaperById()` - Get specific paper
- `createPaper()` - Create new paper
- `updatePaper()` - Update paper details
- `deletePaper()` - Remove paper
- `searchPapers()` - Search papers by title, abstract, year, journal

### 3. KeywordController

Manages research keywords and trends.

**Methods:**

- `getAllKeywords()` - List keywords with pagination
- `getKeywordById()` - Get specific keyword
- `createKeyword()` - Create new keyword
- `updateKeyword()` - Update keyword
- `deleteKeyword()` - Remove keyword
- `getTrendingKeywords()` - Get top trending keywords

### 4. JournalController

Manages academic journal information.

**Methods:**

- `getAllJournals()` - List journals with pagination
- `getJournalById()` - Get specific journal
- `createJournal()` - Create new journal
- `updateJournal()` - Update journal
- `deleteJournal()` - Remove journal

### 5. TopicController

Manages research topics and emerging trends.

**Methods:**

- `getAllTopics()` - List topics with pagination
- `getTopicById()` - Get specific topic
- `createTopic()` - Create new topic
- `updateTopic()` - Update topic
- `deleteTopic()` - Remove topic
- `getEmergingTopics()` - List emerging research topics

### 6. UserController

Manages user profiles and accounts (admin only for most operations).

**Methods:**

- `getAllUsers()` - List all users (admin)
- `getUserById()` - Get user profile
- `updateUserProfile()` - Update user information
- `deleteUser()` - Remove user (admin)
- `changePassword()` - Change password
- `getUsersByRole()` - List users by role (admin)

### 7. AnalysisRunController

Manages trend analysis runs.

**Methods:**

- `getAllAnalysisRuns()` - List analysis runs with pagination
- `getAnalysisRunById()` - Get specific analysis run
- `createAnalysisRun()` - Create new analysis run
- `updateAnalysisRun()` - Update analysis run
- `deleteAnalysisRun()` - Remove analysis run
- `getAnalysisRunsByKeyword()` - Get runs for specific keyword

### 8. BookmarkController

Manages user bookmarks for papers.

**Methods:**

- `getUserBookmarks()` - Get all user's bookmarks
- `checkBookmark()` - Check if paper is bookmarked
- `addBookmark()` - Add paper to bookmarks
- `removeBookmark()` - Remove paper from bookmarks

### 9. NotificationController

Manages user notifications.

**Methods:**

- `getUserNotifications()` - Get user's notifications with pagination
- `getUnreadCount()` - Get count of unread notifications
- `markAsRead()` - Mark single notification as read
- `markAllAsRead()` - Mark all notifications as read
- `deleteNotification()` - Delete single notification
- `clearAllNotifications()` - Delete all notifications

### 10. FollowController

Manages user follows and tracked analysis runs.

**Methods:**

- `getUserFollows()` - Get keywords and journals user follows
- `addFollow()` - Follow keyword or journal
- `removeFollow()` - Unfollow keyword or journal
- `getTrackedRuns()` - Get tracked analysis runs
- `trackAnalysisRun()` - Start tracking analysis run
- `untrackAnalysisRun()` - Stop tracking analysis run
- `updateTrackedRunNotification()` - Update notification settings for tracked run

### 11. PublicationTrendController

Manages publication trend analysis.

**Methods:**

- `getAllTrends()` - List trends with pagination
- `getTrendingPublications()` - Get trending publications
- `getTrendById()` - Get specific trend
- `createTrend()` - Create trend record
- `updateTrend()` - Update trend
- `deleteTrend()` - Remove trend
- `getTrendsByKeyword()` - Get trends for keyword
- `getTrendsByJournal()` - Get trends for journal

## Usage in Routes

Controllers are used in route files to handle request processing:

```typescript
import { AuthController } from "../controllers";
import { Router } from "express";

const router = Router();

router.post("/register", AuthController.register);
router.post("/login", AuthController.login);
router.get("/me", authMiddleware, AuthController.getCurrentUser);

export default router;
```

## Error Handling

All controllers follow consistent error handling patterns:

- 400 Bad Request - Validation errors
- 404 Not Found - Resource not found
- 403 Forbidden - Access denied
- 500 Server Error - Internal server error

## Pagination Support

Controllers support pagination for list endpoints:

- `page` - Page number (default: 1)
- `limit` - Items per page (default: varies by endpoint)

**Response format:**

```json
{
  "data": [],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "pages": 10
  }
}
```

## Authentication

Controllers check `req.userId` and `req.userRole` from JWT middleware:

- Routes with `authMiddleware` have authenticated user info
- Some routes require specific roles via `roleMiddleware`

## Best Practices

1. **Input Validation** - Use `express-validator` in routes before calling controllers
2. **Error Handling** - Always wrap operations in try-catch
3. **Database Queries** - Use lean() for read-only operations when possible
4. **Populating Relations** - Populate required fields for related documents
5. **Response Format** - Always send consistent JSON responses

## File Structure

```
src/
├── controllers/
│   ├── AuthController.ts
│   ├── PaperController.ts
│   ├── KeywordController.ts
│   ├── JournalController.ts
│   ├── TopicController.ts
│   ├── UserController.ts
│   ├── AnalysisRunController.ts
│   ├── BookmarkController.ts
│   ├── NotificationController.ts
│   ├── FollowController.ts
│   ├── PublicationTrendController.ts
│   └── index.ts
```

## Future Enhancements

- Add service layer for complex business logic
- Implement caching for frequently accessed data
- Add transaction support for multi-step operations
- Add event listeners for notifications
- Add queue processing for async operations
