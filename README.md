# DevOps & Fullstack Monorepo Boilerplate

Nuxt 4-ready frontends, Astro landing page, Go (Fiber) API, PostgreSQL (pgvector), Redis and Nginx, all orchestrated with Docker Compose.

## Architecture

```
apps/
  astro-app/      Astro SSR: landing page            -> http://localhost
  nuxt-app/       Nuxt SSR: user web app             -> http://app.localhost
  nuxt-center/    Nuxt SSR: admin back-office        -> http://center.localhost
  go-backend/     Go + Fiber API (Postgres, Redis)   -> http://api.localhost
packages/
  nuxt-base/      Shared Nuxt layer (config + composables) extended by both Nuxt apps
docker/
  nuxt.Dockerfile One Dockerfile for every Nuxt app (build arg APP)
nginx/            Reverse proxy: default.conf (dev), prod.conf.template (prod), snippets/
scripts/          start/stop/deploy/clean + init.sql + migration-db/
```

### Go backend layout

```
apps/go-backend/
  main.go                 entry point: wiring + graceful shutdown
  internal/config/        env loading and validation
  internal/database/      PostgreSQL and Redis clients
  internal/handler/       HTTP handlers (health, users demo)
  internal/server/        Fiber app, middleware, routes
```

### Adding a new Nuxt app

1. Copy `apps/nuxt-app`, rename it in `package.json`, keep `extends: ['../../packages/nuxt-base']`.
2. Add a service in both compose files using `docker/nuxt.Dockerfile` with `args: { APP: <name> }`.
3. Add an Nginx server block, then run `pnpm install` to update `pnpm-lock.yaml`.

Shared code (composables, config) goes in `packages/nuxt-base`, never copy-pasted.

## Requirements

Docker + Docker Compose. For local tooling: Node 20+, pnpm 10 (`corepack enable`), Go 1.24+.

## Development

```bash
cp .env.example .env
make dev        # DB init + migrations + all services + logs
make help       # all commands
```

| Service | URL |
|---|---|
| Astro | http://localhost |
| Nuxt App | http://app.localhost |
| Nuxt Center | http://center.localhost |
| API health | http://api.localhost/health |
| pgAdmin | http://localhost:5050 |

Databases and tools are bound to `127.0.0.1` only. Portainer is optional: `docker compose --profile tools up -d portainer`.

> The demo route `GET /users` exists **only when `APP_ENV` is not `production`** (it is unauthenticated).

## Production

1. On the server, create `.env` from `.env.example` with real values: `JWT_SECRET` (min 32 chars, `openssl rand -hex 32`), strong DB password, and `DOMAIN`, `APP_DOMAIN`, `CENTER_DOMAIN`, `API_DOMAIN`.
2. Nginx reads the domains from `.env` (template `nginx/prod.conf.template`). It needs certificates to start: issue them once, e.g.
   ```bash
   docker run --rm -p 80:80 -v dnaprngo_certbot-conf:/etc/letsencrypt certbot/certbot \
     certonly --standalone -d $DOMAIN -d www.$DOMAIN --email $CERTBOT_EMAIL --agree-tos
   # repeat for APP_DOMAIN, CENTER_DOMAIN, API_DOMAIN
   ```
   (adjust the volume name with `docker volume ls`). The `certbot` service then renews them.
3. Deploy from your machine:
   ```bash
   SERVER_IP=1.2.3.4 SSH_USER=deploy DEPLOY_DIR=/opt/my-monorepo API_DOMAIN=api.example.com make deploy
   ```
   The script pulls, builds, applies `init.sql` and migrations (`ON_ERROR_STOP`), restarts, then checks `/health`.

## Conventions

- Lockfile `pnpm-lock.yaml` is committed; Docker builds use `--frozen-lockfile`.
- Migrations in `scripts/migration-db/` must be idempotent (`IF NOT EXISTS`).
- Never commit `.env`.
