# CLAUDE.md

## Project Overview

MyApp — A web application. Monorepo with npm workspaces.

## Workspace Structure

- `frontend/` — React + Vite frontend (Node 24)
- `backend/` — Express + WebSocket backend (Node 24)

## Version Pinning (CRITICAL)

All dependency versions are **pinned to exact versions** (no `^`, `~`, or `*` prefixes). This prevents version drift between sandbox builds (cowork) and local dev (claude code).

### Rules for adding/updating dependencies

1. **npm dependencies**: Always use exact versions. The `.npmrc` files enforce `save-exact=true`, so `npm install <pkg>` will automatically pin. Never manually add `^` or `~` prefixes.
2. **Docker images**: Always use full version tags (e.g., `node:24.1.0-alpine`, not `node:24-alpine` or `node:latest`).
3. **Lock files**: Never delete lock files. Always run `npm install` (not `npm ci`) when changing dependencies so the lock file updates. Commit lock file changes.
4. **.nvmrc**: Uses exact semver (e.g., `24.1.0`, not `24`).

### Before finishing any task that touches dependencies

- Verify no `^` or `~` prefixes exist in any `package.json` dependency versions
- Verify Docker FROM statements use full `major.minor.patch` tags
- Run `npm install` at the affected workspace root to regenerate the lock file
- Run `npm run build` from the project root to confirm no version conflicts

## Build Commands

```bash
npm run build              # Build frontend + backend
npm run dev                # Dev mode (frontend + backend)
npm run dev:frontend       # Frontend only
npm run dev:backend        # Backend only
npm run docker:up          # Docker compose up --build
```

## Testing

```bash
npm test                   # Run all tests
npm test -- --watch        # Watch mode
npm run test:frontend      # Frontend unit tests (Vitest)
npm run test:backend       # Backend tests (Jest)
npm run test:e2e           # End-to-end tests (Playwright)
```

- Always run relevant tests before committing
- Backend tests require a running Postgres container: `npm run docker:up -- db`

## Code Style

- Prettier + ESLint via `npm run lint` / `npm run format`
- Pre-commit hook runs lint automatically — do not skip with `--no-verify`
- TypeScript strict mode enabled in both workspaces

## Local Dev

### Port configuration

The Vite dev proxy in `frontend/vite.config.ts` forwards `/api` and `/ws` to the backend. These ports must match:

| Service  | Port | Config location                         |
|----------|------|-----------------------------------------|
| Backend  | 4001 | `backend/src/index.ts` (reads `PORT` env) |
| Frontend | 3001 | `frontend/vite.config.ts` (server.port)   |

### First-time setup

```bash
nvm install          # Install the exact Node version from .nvmrc
npm install          # Install dependencies
```

### After pulling changes

Always run `npm install` (not `npm ci`) to sync the lock file, then `npm run build` to verify.

## Deployment

```bash
# Build and deploy
TAG=$(git rev-parse --short HEAD)
./scripts/build-and-push.sh $TAG
./scripts/deploy.sh all $TAG

# Other commands
./scripts/deploy.sh status           # Show running containers
./scripts/deploy.sh logs [service]   # Tail logs (all or specific)
./scripts/deploy.sh ssh              # SSH into the instance
```

## Git Conventions

- Branch names: `feat/`, `fix/`, `chore/` prefixes
- Commit messages: imperative mood, under 72 chars (e.g., "Add user auth endpoint")
- Always create new commits, never amend unless explicitly asked
