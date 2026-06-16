# Scientific Journal Trend Tracker Backend - Architecture Documentation

## Overview

This backend implements a **service-oriented, layered architecture** with clear separation of concerns across four main layers:

1. **Routes Layer** - HTTP request handling and routing
2. **Controllers Layer** - Business logic orchestration (currently in place for reference)
3. **Services Layer** - Core business logic and data operations
4. **Data Access Layer** - MongoDB models and persistence

## Architecture Layers

### 1. Routes Layer (`src/routes/`)

**Responsibility**: HTTP request/response handling, middleware composition, request validation.

Each route file follows a consistent pattern:

```typescript
// Routes delegate to services, apply middleware, handle responses
router.get("/", async (req, res) => {
  try {
    const result = await ServiceName.method();
    res.json(result);
  } catch (error: any) {
    res.status(error.status || 500).json({ message: error.message });
  }
});
```

**Routes Overview**:

- `auth.ts` - Authentication (register, login, getCurrentUser)
- `papers.ts` - Academic papers (CRUD + search)
- `keywords.ts` - Research keywords (CRUD + trending)
- `journals.ts` - Journal metadata (CRUD)
- `topics.ts` - Research topics (CRUD + emerging)
- `users.ts` - User management (CRUD + password change + role filtering)
- `analysisRuns.ts` - Analysis execution tracking (CRUD + by keyword)
- `bookmarks.ts` - User bookmarks (CRUD)
- `notifications.ts` - User notifications (CRUD + unread count)
- `follows.ts` - Follow relationships (CRUD + tracked runs)
- `publicationTrends.ts` - Publication trend analysis (CRUD + by keyword/journal)

### 2. Services Layer (`src/services/`)

**Responsibility**: Business logic, data validation, service orchestration, error handling.

Each service encapsulates domain-specific logic as a static class:

#### Service Files and Methods:

**AuthService**

- `register(email, password, name, role)` - User registration with password hashing
- `login(email, password)` - Authentication with JWT token generation
- `getCurrentUser(userId)` - Retrieve authenticated user profile
- `validateToken(token)` - JWT token validation

**PaperService**

- `getAllPapers(page, limit)` - Paginated paper listing
- `getPaperById(id)` - Retrieve single paper
- `createPaper(data)` - Create new paper record
- `updatePaper(id, data)` - Update paper metadata
- `deletePaper(id)` - Remove paper from system
- `searchPapers(query, year, journalId)` - Advanced paper search
- `getPapersByCitation(paperId)` - Papers citing a given paper
- `getPapersByKeyword(keywordId)` - Papers tagged with keyword

**KeywordService**

- `getAllKeywords(page, limit, sort)` - Paginated keyword listing
- `getTrendingKeywords(limit)` - Top trending keywords
- `getKeywordById(id)` - Retrieve keyword details
- `createKeyword(data)` - Create new keyword
- `updateKeyword(id, data)` - Update keyword metadata
- `deleteKeyword(id)` - Remove keyword
- `calculateTrendMetrics()` - Compute trend scores
- `normalizeKeyword(keyword)` - Text normalization

**JournalService**

- `getAllJournals()` - List all journals
- `getJournalsByField(field)` - Filter by research field
- `getTrackedJournals(userId)` - User-followed journals
- `getHighImpactJournals(minImpactFactor)` - Filter by impact factor
- `getJournalById(id)` - Retrieve journal details
- `createJournal(data)` - Create new journal record
- `updateJournal(id, data)` - Update journal metadata

**TopicService**

- `getEmergingTopics()` - Identify emerging research areas
- `analyzeTrendStatus(yearlyData)` - Trend analysis
- `updateTrendStatus(id, status)` - Update trend classification
- `getTopicById(id)` - Retrieve topic details
- `getAllTopics(page, limit)` - Paginated listing
- `createTopic(data)` - Create new topic
- `updateTopic(id, data)` - Update topic metadata
- `deleteTopic(id)` - Remove topic

**UserService**

- `getAllUsers(page, limit)` - User listing (admin only)
- `getUserById(id)` - Retrieve user profile
- `updateUserProfile(id, data, requestingUserId, requestingRole)` - Update user data
- `deleteUser(id)` - Remove user account
- `changePassword(id, currentPassword, newPassword, requestingUserId)` - Password change with verification
- `getUsersByRole(role)` - Filter users by role
- `getUserStats()` - User account statistics
- `getActiveUsers(days)` - Recently active users

**AnalysisRunService**

- `getAllAnalysisRuns(page, limit)` - Paginated analysis execution list
- `getAnalysisRunById(id)` - Retrieve analysis details
- `createAnalysisRun(data)` - Start new analysis
- `updateAnalysisRun(id, data)` - Update analysis metadata
- `deleteAnalysisRun(id)` - Cancel/remove analysis
- `getAnalysisRunsByKeyword(keywordId)` - Analyses for specific keyword
- `getActiveAnalysisRuns()` - In-progress analyses
- `getCompletedAnalysisRuns()` - Finished analyses
- `completeAnalysisRun(id, results)` - Mark analysis complete with results

**BookmarkService**

- `getUserBookmarks(userId, page, limit)` - Paginated bookmarks
- `checkBookmark(userId, paperId)` - Check bookmark status
- `addBookmark(userId, paperId)` - Create bookmark
- `removeBookmark(userId, paperId)` - Delete bookmark
- `getBookmarkCount(userId)` - Count user bookmarks

**NotificationService**

- `getUserNotifications(userId, page, limit)` - Paginated notifications
- `getUnreadCount(userId)` - Unread notification count
- `getUnreadNotifications(userId)` - Filter unread
- `markAsRead(notificationId)` - Mark single as read
- `markAllAsRead(userId)` - Mark all as read
- `deleteNotification(id)` - Remove notification
- `clearAllNotifications(userId)` - Clear all user notifications
- `bulkCreateNotifications(notificationArray)` - Batch create
- `getNotificationsByType(userId, type)` - Filter by type

**FollowService**

- `getUserFollows(userId)` - User's follows
- `addFollow(userId, targetType, targetId, notifyEnabled)` - Follow keyword/journal
- `removeFollow(userId, targetId)` - Unfollow
- `checkIfFollowing(userId, targetType, targetId)` - Verify follow status
- `getTrackedRuns(userId)` - User's tracked analysis runs
- `trackAnalysisRun(userId, analysisRunId, notifyEnabled)` - Track new run
- `untrackAnalysisRun(userId, analysisRunId)` - Stop tracking
- `updateTrackedRunNotification(userId, analysisRunId, notifyEnabled)` - Toggle notifications
- `getFollowStats(userId)` - Count of follows/tracked runs

**PublicationTrendService**

- `getAllPublicationTrends(page, limit)` - Paginated trends
- `getTrendingPublications()` - Top 50 trending publications
- `getPublicationTrendById(id)` - Retrieve trend details
- `createPublicationTrend(data)` - Create new trend record
- `updatePublicationTrend(id, data)` - Update trend metadata
- `deletePublicationTrend(id)` - Remove trend record
- `getTrendsByKeyword(keywordId)` - Trends for keyword
- `getTrendsByJournal(journalId)` - Trends for journal
- `getTrendsByYearRange(startYear, endYear)` - Year-based filtering
- `analyzeTrendGrowth(keywordId, startYear, endYear)` - Growth rate calculation

### 3. Middleware Layer (`src/middleware/`)

**Responsibility**: Cross-cutting concerns (authentication, validation, rate limiting, caching, logging).

#### Middleware Modules:

**validation.ts** - Input validation with express-validator

- `validateRegister` - Registration input validation
- `validateLogin` - Login credentials validation
- `validateCreatePaper`, `validateCreateKeyword`, etc. - Entity-specific validators
- `validateChangePassword` - Password change validation
- `validatePaginationQuery` - Pagination parameter validation
- `validateIdParam` - MongoDB ID validation
- `validateInputs()` - Middleware that processes validation results

**caching.ts** - Response caching with TTL and patterns

- `cacheMiddleware(ttl)` - Cache with fixed TTL
- `cacheWithKey(ttl, keyGenerator)` - Cache with custom key
- `setCache(key, value, ttl)` - Manual cache set
- `getCache(key)` - Manual cache get
- `clearExpiredCache()` - Cleanup expired entries (auto-runs every 10 min)
- `clearCachePattern(pattern)` - Clear by pattern

**rateLimiter.ts** - Request rate limiting with presets

- Presets:
  - `auth` - 5 requests per 15 minutes (strict for sensitive operations)
  - `api` - 100 requests per 15 minutes (default)
  - `read` - 200 requests per 15 minutes (GET operations)
  - `write` - 50 requests per 15 minutes (POST/PUT/DELETE)
  - `sensitive` - 10 requests per 1 hour (password changes)
- Features: X-RateLimit-\* headers, Retry-After header, IP-based tracking

**logger.ts** - File-based request/error logging

- `requestLogger()` - Log all requests with timing
- `errorLogger()` - Log errors with stack traces
- `getLogsForDate(date)` - Retrieve daily logs
- `getErrorLogsForDate(date)` - Retrieve daily error logs
- `getSlowRequests()` - Requests exceeding 5s threshold
- Daily rotation: `logs/requests-YYYY-MM-DD.log`, `logs/errors-YYYY-MM-DD.log`

**pagination.ts** - Pagination parameter handling

- `paginationMiddleware(defaultLimit, maxLimit)` - Extract pagination params
- `getPaginationParams()` - Get validated params
- `formatPaginatedResponse(items, total, page, limit)` - Format response with metadata

**auth.ts** - Authentication and authorization

- `authMiddleware` - Verify JWT token (existing)
- `roleMiddleware(['role1', 'role2'])` - Role-based access control (existing)

### 4. Data Access Layer (`src/models/`)

**Responsibility**: MongoDB schema definition and data persistence.

**11 Models**:

- User - User accounts with roles (admin, researcher, user)
- Paper - Academic papers with metadata
- Keyword - Research keywords with trend scores
- Journal - Journal metadata with impact factors
- Topic - Research topics with trend status
- AnalysisRun - Analysis execution records
- Bookmark - User paper bookmarks
- Notification - User notifications
- Follow - User follows (keywords/journals)
- PublicationTrend - Publication trend analytics
- SyncLog - Data synchronization logs

## Middleware Stack Application

### Global Middleware (Applied in `src/index.ts`)

1. Helmet - Security headers
2. CORS - Cross-origin resource sharing
3. Body parser - JSON/form data parsing
4. Request Logger - HTTP request logging
5. Error Logger - Error logging
6. Error Handler - Centralized error handling

### Route-Level Middleware Application

**Authentication Routes** (`/api/auth`)

```
rateLimit(auth: 5/15min)
  → validateRegister/validateLogin
  → validateInputs
```

**Read-Heavy Routes** (`/api/papers`, `/api/keywords`)

```
rateLimit(read: 200/15min)
  → Optional: authMiddleware + roleMiddleware for write operations
  → rateLimit(write: 50/15min) on POST/PUT/DELETE
```

**Write-Protected Routes** (`/api/users`, `/api/topics`)

```
authMiddleware
  → roleMiddleware(['admin', 'researcher']) for POST
  → roleMiddleware(['admin']) for PUT/DELETE
  → rateLimit(write)
  → validateInputs
```

**Sensitive Operations** (`/api/users/:id/change-password`)

```
authMiddleware
  → rateLimit(sensitive: 10/1hr)
  → validateChangePassword
  → validateInputs
```

**Public Read Operations**

```
rateLimit(read)
  → Service delegation
```

## Error Handling Strategy

### Service Layer Error Format

Services throw errors with standard structure:

```typescript
throw {
  status: 400 | 401 | 403 | 404 | 500,
  message: "Descriptive error message",
};
```

### Route Layer Error Handling

Routes catch service errors and format responses:

```typescript
try {
  result = await Service.method();
  res.json(result);
} catch (error: any) {
  res.status(error.status || 500).json({ message: error.message });
}
```

### Error Handler Middleware

Global error handler catches any uncaught exceptions:

- Logs error details
- Returns 500 status with error message
- Prevents server crashes

## Request Flow Example

### Create a Paper (POST `/api/papers`)

1. **Routes Layer**: `papers.ts`
   - Match POST / endpoint
   - Apply `authMiddleware` (verify JWT)
   - Apply `roleMiddleware(['admin', 'researcher'])` (check role)
   - Apply `rateLimit(rateLimits.write)` (check rate limits)
   - Apply `validateCreatePaper` (validate input)
   - Apply `validateInputs` (process validation errors)

2. **Services Layer**: `PaperService.createPaper(data)`
   - Validate paper data
   - Check author exists
   - Check journal exists
   - Create paper record in MongoDB
   - Populate relationships
   - Return populated paper

3. **Response**
   - HTTP 201 Created with paper object
   - Or HTTP 400/401/403/500 with error message

## Rate Limiting Strategy

```
API Tier          Requests    Window    Use Case
─────────────────────────────────────────────────────────
auth              5           15 min    Registration, login
api (default)     100         15 min    General API calls
read              200         15 min    GET operations
write             50          15 min    POST/PUT/DELETE
sensitive         10          1 hour    Password changes
```

## Caching Strategy

**Candidates for Caching**:

- Trending keywords (5 min TTL)
- High-impact journals (10 min TTL)
- Publication trends (10 min TTL)
- User profile (5 min TTL)

**Not Cached**:

- Authentication endpoints
- Write operations
- Real-time user data
- Notifications

## Security Features

1. **Authentication**: JWT tokens (via `authMiddleware`)
2. **Authorization**: Role-based access control (`roleMiddleware`)
3. **Input Validation**: Express-validator schemas
4. **Rate Limiting**: 5 presets for different operation types
5. **Security Headers**: Helmet middleware
6. **CORS**: Configured for frontend origin
7. **Password Hashing**: bcryptjs with 10-round salting

## Monitoring & Logging

### Request Logging

- All requests logged with:
  - Timestamp
  - Method, path, status code
  - Response time
  - Request ID
  - User ID (if authenticated)

### Error Logging

- All errors logged with:
  - Stack trace
  - Error message
  - Request context
  - User ID (if applicable)

### Slow Request Tracking

- Requests exceeding 5 second threshold logged separately
- Helps identify performance bottlenecks

### Log Files

- Daily rotation
- Location: `logs/requests-YYYY-MM-DD.log`, `logs/errors-YYYY-MM-DD.log`

## Scalability Considerations

### Current Design Supports:

- **Horizontal Scaling**: Stateless services can be deployed across multiple instances
- **Caching**: Reduces database load for frequently accessed data
- **Rate Limiting**: Prevents abuse and resource exhaustion
- **Pagination**: Limits data transfer per request

### Future Enhancements:

- Redis for distributed caching
- Message queue (RabbitMQ/Kafka) for async operations
- Database indexing optimization
- GraphQL API layer for flexible queries
- API versioning (v1, v2, etc.)
- WebSocket support for real-time notifications

## Testing Strategy

### Unit Testing

- Service layer methods with mock data
- Validation logic verification
- Error handling scenarios

### Integration Testing

- Route → Service → Model integration
- End-to-end API tests
- Middleware composition tests

### Load Testing

- Rate limit enforcement verification
- Caching effectiveness measurement
- Slow request identification

## Deployment Checklist

- [ ] Set environment variables (MONGODB_URI, JWT_SECRET, PORT, etc.)
- [ ] Configure logging directories
- [ ] Set up MongoDB connection
- [ ] Configure CORS origin for frontend
- [ ] Enable rate limiting in production
- [ ] Enable caching for read-heavy operations
- [ ] Set up monitoring/alerting
- [ ] Configure SSL/HTTPS
- [ ] Set up backup strategy for MongoDB

## API Endpoint Summary

| Method | Endpoint                         | Auth | Role              | Rate Limit |
| ------ | -------------------------------- | ---- | ----------------- | ---------- |
| POST   | `/api/auth/register`             | ✗    | -                 | auth       |
| POST   | `/api/auth/login`                | ✗    | -                 | auth       |
| GET    | `/api/auth/me`                   | ✓    | -                 | api        |
| GET    | `/api/papers`                    | ✗    | -                 | read       |
| POST   | `/api/papers`                    | ✓    | admin, researcher | write      |
| PUT    | `/api/papers/:id`                | ✓    | admin             | write      |
| DELETE | `/api/papers/:id`                | ✓    | admin             | write      |
| POST   | `/api/users/:id/change-password` | ✓    | -                 | sensitive  |
| ...    | ...                              | ...  | ...               | ...        |

## Conclusion

This architecture provides:

- **Clear separation of concerns** between routes, services, and data access
- **Consistent error handling** throughout the application
- **Comprehensive middleware stack** for security, validation, and monitoring
- **Enterprise-ready codebase** with logging, rate limiting, and caching
- **Easy to test and maintain** with service-based business logic

All 11 routes now follow the established pattern, making the codebase consistent, predictable, and easy to extend.
