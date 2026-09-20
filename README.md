# DevOps & Fullstack Monorepo Boilerplate

A complete, modern, secure, and production-ready monorepo boilerplate.

## Architecture

- **apps/nuxt-app**: Nuxt 4 SSR application (Dashboard/Web App)
- **apps/astro-app**: Astro 4+ SSR application (Landing Page/Showcase)
- **apps/go-backend**: Go API with Fiber (Postgres & Redis)
- **nginx**: Nginx reverse proxy configuration for Dev and Prod
- **scripts**: Utility scripts for local development and remote deployment

## Requirements

- Docker & Docker Compose
- Node.js (for local linting/testing if desired)
- pnpm (package manager)
- Go 1.22+ (for local development without docker)

## Getting Started

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Start the development environment:
   ```bash
   make dev
   ```
   Or use the script directly:
   ```bash
   ./scripts/start.sh
   ```

3. Access your applications (via Nginx proxy):
   - Landing (Astro): `http://localhost`
   - App (Nuxt): `http://app.localhost`
   - API (Go): `http://api.localhost`

## Deployment

To deploy to your VPS via SSH, ensure you have set up the appropriate variables inside `scripts/deploy.sh` (like `SERVER_IP`, `SSH_USER`, `DEPLOY_DIR`).

Run the deployment script from your local machine:

```bash
make deploy
```
Or directly:
```bash
./scripts/deploy.sh
```
