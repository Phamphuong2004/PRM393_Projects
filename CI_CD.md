# CI/CD Setup

This repository now has:

- `CI` for the backend services, Flutter web app, and Python AI service.
- A Firebase Hosting deployment workflow for the Flutter web app.
- A GHCR publishing workflow for backend and AI Docker images.

## What the CI does

- Backend services: installs dependencies, runs lint, runs tests with `--passWithNoTests`, and builds each Node service.
- Flutter app: runs `flutter pub get`, `flutter analyze`, and `flutter build web --release`.
- AI service: installs Python dependencies and runs a syntax check with `python -m compileall`.

## How to enable frontend deploy

Add this repository secret in GitHub:

- `FIREBASE_TOKEN`

When that secret exists, the deploy workflow will publish the Flutter web build to Firebase Hosting for project `journal-trend-3a6d8`.

## Notes for backend deploy

- The backend and AI service already contain Dockerfiles, so the workflow publishes ready-to-deploy images.
- GitHub Container Registry images are tagged by commit SHA and `latest` on the default branch.
- You can point Railway, Render, or any container host at those images for automatic deployment.
