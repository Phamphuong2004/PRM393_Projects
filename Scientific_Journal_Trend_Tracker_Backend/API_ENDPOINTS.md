# API Endpoints Documentation

## Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user profile

## Papers

- `GET /api/papers` - Get all papers (paginated)
- `GET /api/papers/:id` - Get paper by ID
- `POST /api/papers` - Create new paper (auth required)
- `PUT /api/papers/:id` - Update paper (auth required)
- `DELETE /api/papers/:id` - Delete paper (auth required)
- `GET /api/papers/search/query` - Search papers by title/abstract

## Keywords

- `GET /api/keywords` - Get all keywords (paginated)
- `GET /api/keywords/:id` - Get keyword by ID
- `POST /api/keywords` - Create new keyword (auth required)
- `PUT /api/keywords/:id` - Update keyword (auth required)
- `DELETE /api/keywords/:id` - Delete keyword (auth required)
- `GET /api/keywords/trends/trending` - Get trending keywords

## Journals

- `GET /api/journals` - Get all journals (paginated)
- `GET /api/journals/:id` - Get journal by ID
- `POST /api/journals` - Create new journal (auth required)
- `PUT /api/journals/:id` - Update journal (auth required)
- `DELETE /api/journals/:id` - Delete journal (auth required)

## Topics

- `GET /api/topics` - Get all topics (paginated)
- `GET /api/topics/:id` - Get topic by ID
- `POST /api/topics` - Create new topic (auth required)
- `PUT /api/topics/:id` - Update topic (auth required)
- `DELETE /api/topics/:id` - Delete topic (auth required)
- `GET /api/topics/emerging/list` - Get emerging topics

## Analysis Runs

- `GET /api/analysis-runs` - Get all analysis runs (paginated)
- `GET /api/analysis-runs/:id` - Get analysis run by ID
- `POST /api/analysis-runs` - Create new analysis run (auth + researcher role)
- `PUT /api/analysis-runs/:id` - Update analysis run (auth + admin role)
- `DELETE /api/analysis-runs/:id` - Delete analysis run (auth + admin role)
- `GET /api/analysis-runs/keyword/:keywordId` - Get runs for keyword

## Publication Trends

- `GET /api/publication-trends` - Get all publication trends (paginated)
- `GET /api/publication-trends/:id` - Get trend by ID
- `POST /api/publication-trends` - Create trend (auth + admin role)
- `PUT /api/publication-trends/:id` - Update trend (auth + admin role)
- `DELETE /api/publication-trends/:id` - Delete trend (auth + admin role)
- `GET /api/publication-trends/trending/list` - Get trending publications
- `GET /api/publication-trends/keyword/:keywordId` - Get trends by keyword
- `GET /api/publication-trends/journal/:journalId` - Get trends by journal

## Users

- `GET /api/users` - Get all users (admin only, paginated)
- `GET /api/users/:id` - Get user by ID (auth required)
- `PUT /api/users/:id` - Update user profile (auth required, own profile or admin)
- `DELETE /api/users/:id` - Delete user (admin only)
- `POST /api/users/:id/change-password` - Change password (auth required, own account)
- `GET /api/users/role/:role` - Get users by role (admin only)

## Bookmarks

- `GET /api/bookmarks` - Get user's bookmarks (auth required)
- `GET /api/bookmarks/:paperId/check` - Check if paper is bookmarked (auth required)
- `POST /api/bookmarks/:paperId` - Add bookmark (auth required)
- `DELETE /api/bookmarks/:paperId` - Remove bookmark (auth required)

## Notifications

- `GET /api/notifications` - Get user's notifications (auth required, paginated)
- `GET /api/notifications/unread/count` - Get unread notification count (auth required)
- `PUT /api/notifications/:id/read` - Mark notification as read (auth required)
- `PUT /api/notifications/all/read` - Mark all as read (auth required)
- `DELETE /api/notifications/:id` - Delete notification (auth required)
- `DELETE /api/notifications` - Clear all notifications (auth required)

## Follows & Tracking

- `GET /api/follows` - Get user's follows (auth required)
- `POST /api/follows` - Follow keyword/journal (auth required)
- `DELETE /api/follows/:targetId` - Unfollow (auth required)
- `GET /api/follows/tracked-runs` - Get tracked analysis runs (auth required)
- `POST /api/follows/tracked-runs/:analysisRunId` - Track analysis run (auth required)
- `DELETE /api/follows/tracked-runs/:analysisRunId` - Untrack (auth required)
- `PUT /api/follows/tracked-runs/:analysisRunId/notify` - Update notify preference (auth required)

## Authors

- `GET /api/authors` - Get all authors (paginated, search query)
- `GET /api/authors/:id` - Get author by ID
- `POST /api/authors` - Create new author (auth + researcher/admin role)
- `PUT /api/authors/:id` - Update author (auth + researcher/admin role)
- `DELETE /api/authors/:id` - Delete author (auth + admin role)

## Sync Logs

- `GET /api/sync-logs` - Get sync execution logs (auth + admin only, paginated, status filter)
- `GET /api/sync-logs/:id` - Get sync log details (auth + admin only)
- `DELETE /api/sync-logs/:id` - Delete a sync log (auth + admin only)
- `DELETE /api/sync-logs` - Clear all sync logs (auth + admin only)

## Request Examples

### Register

```json
POST /api/auth/register
{
  "email": "user@example.com",
  "password": "password123",
  "fullName": "John Doe"
}
```

### Login

```json
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "password123"
}
```

### Create Paper

```json
POST /api/papers
Authorization: Bearer {token}
{
  "title": "Machine Learning Research",
  "abstract": "A study on ML algorithms...",
  "publicationYear": 2024,
  "doi": "10.1234/example",
  "journalId": "journal_id_here"
}
```

### Bookmark Paper

```json
POST /api/bookmarks/:paperId
Authorization: Bearer {token}
```

### Follow Keyword

```json
POST /api/follows
Authorization: Bearer {token}
{
  "targetType": "Keyword",
  "targetId": "keyword_id_here",
  "notifyEnabled": true
}
```

### Track Analysis Run

```json
POST /api/follows/tracked-runs/:analysisRunId
Authorization: Bearer {token}
{
  "notifyEnabled": true
}
```

## Response Format

### Success Response

```json
{
  "data": {...},
  "message": "Success message",
  "success": true
}
```

### Error Response

```json
{
  "success": false,
  "status": 400,
  "message": "Error description"
}
```

### Paginated Response

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "pages": 10
  }
}
```

## Authentication

All endpoints marked with (auth required) need JWT token in header:

```
Authorization: Bearer {jwt_token}
```

## Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Server Error
