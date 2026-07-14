# Backend Setup Guide

## Quick Start

### 1. Environment Setup

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your configuration
# IMPORTANT: Add your MongoDB Atlas connection string
```

Your `.env` should look like:

```
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb+srv://user:password@cluster.mongodb.net/journal_tracker?retryWrites=true&w=majority
JWT_SECRET=your_super_secret_key_change_in_production
JWT_EXPIRE=7d
BCRYPT_ROUNDS=10
FRONTEND_URL=http://localhost:5173
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Start Development Server

```bash
npm run dev
```

Server will start on `http://localhost:5000`

## MongoDB Atlas Setup

### Create MongoDB Atlas Account

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Sign up or log in
3. Create a new project
4. Create a cluster (free tier available)
5. Create database user and get connection string

### Connection String

Replace placeholders in your connection string:

- `username` - Your database user
- `password` - Your database password
- `cluster` - Your cluster name

Example:

```
mongodb+srv://admin:password123@mycluster.mongodb.net/journal_tracker?retryWrites=true&w=majority
```

## API Testing

### Using Postman

1. **Register User**

   ```
   POST http://localhost:5000/api/auth/register

   {
     "email": "user@example.com",
     "password": "password123",
     "fullName": "John Doe"
   }
   ```

2. **Login**

   ```
   POST http://localhost:5000/api/auth/login

   {
     "email": "user@example.com",
     "password": "password123"
   }
   ```

3. **Create Paper**

   ```
   POST http://localhost:5000/api/papers
   Headers: Authorization: Bearer {token}

   {
     "title": "Machine Learning Research",
     "abstract": "A study on ML algorithms...",
     "publicationYear": 2024,
     "doi": "10.1234/example"
   }
   ```

### Using cURL

```bash
# Register
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass123","fullName":"Test User"}'

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass123"}'
```

## Project Structure

```
src/
├── config/           # Configuration files
├── middleware/       # Express middleware
├── models/          # MongoDB schemas
├── routes/          # API routes
├── types/           # TypeScript types
├── utils/           # Utility functions
└── index.ts         # Main app file
```

## Common Issues

### MongoDB Connection Error

- Check connection string in `.env`
- Ensure IP is whitelisted in MongoDB Atlas
- Verify username/password

### Port Already in Use

```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID {PID} /F

# Mac/Linux
lsof -i :5000
kill -9 {PID}
```

### TypeScript Errors

```bash
# Clear and rebuild
npm run build
```

## Development Workflow

1. **Create feature branch**

   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make changes**

   ```bash
   # Files will auto-reload with npm run dev
   ```

3. **Test with Postman or cURL**

4. **Build and verify**

   ```bash
   npm run build
   ```

5. **Commit changes**
   ```bash
   git add .
   git commit -m "feat: description"
   ```

## Database Models Overview

### User

- Authentication and profile management
- Roles: admin, researcher, user
- Email verification support

### Paper

- Academic paper metadata
- Multiple external IDs (OpenAlex, Semantic Scholar, Crossref)
- Citation tracking
- Author and keyword relationships

### Keyword

- Research keywords and terms
- Trend scoring and analysis
- AI Chatbot Integration
- Yearly usage statistics

### Journal

- Academic journal information
- Impact factor tracking
- H-index
- Field domain categorization

### Topic

- Emerging research topics
- Trend analysis
- Keyword grouping
- Status tracking

### AnalysisRun

- Keyword analysis execution
- Trend calculation
- Yearly data aggregation
- Sync logging

## Next Steps

1. ✅ Backend structure created
2. ⏳ Integrate external APIs (OpenAlex, Semantic Scholar)
3. ⏳ Implement trend analysis algorithms
4. ⏳ Add notification system
5. ⏳ Create user bookmarks functionality
6. ⏳ Add real-time features with WebSocket

## Support & Debugging

### Enable Debug Logging

```bash
DEBUG=* npm run dev
```

### Check Server Health

```bash
curl http://localhost:5000/health
```

### API Documentation

```bash
curl http://localhost:5000/api
```

## Deployment

### Production Build

```bash
npm run build
npm start
```

### Docker Deployment

```bash
# Build image
docker build -t journal-tracker-backend .

# Run container
docker run -p 5000:5000 -e MONGODB_URI=your_uri journal-tracker-backend
```

For issues or questions, consult the main README.md or contact the team.
