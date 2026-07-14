# Scientific Journal Trend Tracker Backend

Backend API for the Scientific Journal Trend Tracker application built with Node.js, Express, TypeScript, and MongoDB.

## Features

✅ **User Authentication** - JWT-based authentication with registration and login
✅ **Paper Management** - CRUD operations for academic papers with search functionality
✅ **Keyword Tracking** - Track research keywords and trending topics
✅ **Journal Management** - Manage academic journals and their metadata
✅ **Topic Analysis** - Analyze emerging research topics and trends
✅ **Author Management** - CRUD operations for authors and metadata tracking
✅ **Sync Log Tracking** - Log execution and errors for external API integrations
✅ **MongoDB Integration** - Full MongoDB Atlas support with Mongoose ODM

## Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Language**: TypeScript
- **Database**: MongoDB Atlas
- **Authentication**: JWT
- **Validation**: express-validator
- **Security**: bcryptjs, helmet, cors

## Installation

### Prerequisites

- Node.js (v16 or higher)
- npm or yarn
- MongoDB Atlas account

### Setup

1. **Clone and navigate to project**

```bash
cd Scientific_Journal_Trend_Tracker_Backend
```

2. **Install dependencies**

```bash
npm install
```

3. **Configure environment variables**

```bash
cp .env.example .env
```

Update `.env` with your MongoDB Atlas connection string:

```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/journal_tracker?retryWrites=true&w=majority
JWT_SECRET=your_secure_secret_key
JWT_EXPIRE=7d
PORT=5000
FRONTEND_URL=http://localhost:5173
```

4. **Start development server**

```bash
npm run dev
```

Server will run on `http://localhost:5000`

## Available Scripts

```bash
# Development with hot reload
npm run dev

# Build TypeScript
npm run build

# Start production server
npm start

# Run tests
npm test

# Lint code
npm run lint
```

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user profile

### Papers

- `GET /api/papers` - Get all papers (paginated)
- `GET /api/papers/:id` - Get paper by ID
- `POST /api/papers` - Create new paper
- `PUT /api/papers/:id` - Update paper
- `DELETE /api/papers/:id` - Delete paper
- `GET /api/papers/search/query` - Search papers

### Keywords

- `GET /api/keywords` - Get all keywords (paginated)
- `GET /api/keywords/:id` - Get keyword by ID
- `POST /api/keywords` - Create new keyword
- `PUT /api/keywords/:id` - Update keyword
- `DELETE /api/keywords/:id` - Delete keyword
- `GET /api/keywords/trends/trending` - Get trending keywords

### Journals

- `GET /api/journals` - Get all journals (paginated)
- `GET /api/journals/:id` - Get journal by ID
- `POST /api/journals` - Create new journal
- `PUT /api/journals/:id` - Update journal
- `DELETE /api/journals/:id` - Delete journal

### Topics

- `GET /api/topics` - Get all topics (paginated)
- `GET /api/topics/:id` - Get topic by ID
- `POST /api/topics` - Create new topic
- `PUT /api/topics/:id` - Update topic
- `DELETE /api/topics/:id` - Delete topic
- `GET /api/topics/emerging/list` - Get emerging topics

### Authors

- `GET /api/authors` - Get all authors (paginated, search query)
- `GET /api/authors/:id` - Get author by ID
- `POST /api/authors` - Create new author (auth required)
- `PUT /api/authors/:id` - Update author (auth required)
- `DELETE /api/authors/:id` - Delete author (auth + admin)

### Sync Logs

- `GET /api/sync-logs` - Get sync execution logs (auth + admin only, paginated)
- `GET /api/sync-logs/:id` - Get sync log details (auth + admin only)
- `DELETE /api/sync-logs/:id` - Delete a sync log (auth + admin only)
- `DELETE /api/sync-logs` - Clear all sync logs (auth + admin only)

## Database Models

### User

- Email, password, full name
- Role-based access (admin, researcher, user)
- Profile information

### Paper

- Title, abstract, DOI
- Publication metadata
- Author and journal references
- Citation tracking

### Keyword

- Trend analysis
- AI Chatbot Integration
- Growth rate tracking
- Yearly usage statistics

### Journal

- ISSN, impact factor
- Paper count tracking
- Field domain categorization

### Topic

- Seed keywords
- Trend status
- Yearly trend data
- Paper associations

### AnalysisRun

- Keyword analysis tracking
- Yearly trend data
- Sync log references

### SyncLog

- API source synchronization
- Paper addition/update tracking
- Error logging

### ApiSource

- External API configuration
- Sync frequency settings
- Field scope definition

## Project Structure

```
src/
├── config/
│   └── database.ts          # MongoDB connection
├── middleware/
│   ├── auth.ts              # JWT authentication
│   └── errorHandler.ts      # Error handling
├── models/
│   ├── User.ts
│   ├── Paper.ts
│   ├── Keyword.ts
│   ├── Journal.ts
│   ├── Topic.ts
│   ├── AnalysisRun.ts
│   ├── SyncLog.ts
│   ├── ApiSource.ts
│   ├── Notification.ts
│   ├── PublicationTrend.ts
│   └── index.ts
├── routes/
│   ├── auth.ts
│   ├── papers.ts
│   ├── keywords.ts
│   ├── journals.ts
│   └── topics.ts
└── index.ts                 # Express app setup
```

## Development Workflow

1. **Create feature branch**

```bash
git checkout -b feature/your-feature-name
```

2. **Make changes and test**

```bash
npm run dev
```

3. **Build and verify**

```bash
npm run build
```

4. **Commit and push**

```bash
git add .
git commit -m "feat: describe your changes"
git push origin feature/your-feature-name
```

## Deployment

### Prepare for production

```bash
npm run build
npm start
```

### Environment Variables for Production

- Change `NODE_ENV` to `production`
- Update `JWT_SECRET` to a strong random string
- Set `MONGODB_URI` to production database
- Update `FRONTEND_URL` to production frontend URL

## Error Handling

The API uses consistent error responses:

```json
{
  "success": false,
  "status": 400,
  "message": "Error description"
}
```

## Security

✅ Passwords hashed with bcryptjs
✅ JWT token-based authentication
✅ CORS enabled for frontend origin
✅ Helmet security headers
✅ Input validation with express-validator
✅ MongoDB connection with credentials

## Next Steps

1. Implement analysis run endpoints
2. Add external API integration (OpenAlex, Semantic Scholar)
3. Create notification system
4. Add user bookmarks functionality
5. Implement trend analysis algorithms
6. Add GraphQL API support

## Contributing

1. Follow TypeScript best practices
2. Use proper error handling
3. Add input validation
4. Test endpoints before committing
5. Update documentation

## License

ISC

## Support

For issues and questions, please contact the development team.
