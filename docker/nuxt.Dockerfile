# syntax=docker/dockerfile:1
# Shared Dockerfile for every Nuxt app of the monorepo.
# Usage: docker build -f docker/nuxt.Dockerfile --build-arg APP=nuxt-app .
# Targets: dev (hot reload, used by docker-compose.yml) | runner (production, default)

ARG NODE_VERSION=20
ARG APP=nuxt-app

# ---- Base: workspace dependencies (cached while manifests are unchanged) ----
FROM node:${NODE_VERSION}-alpine AS base
ARG APP
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@10.26.2 --activate

COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY packages/nuxt-base/package.json ./packages/nuxt-base/
COPY apps/${APP}/package.json ./apps/${APP}/
RUN --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile --filter ${APP}...

# ---- Dev: sources are bind-mounted by docker-compose.yml ----
FROM base AS dev
ARG APP
ENV APP=${APP}
WORKDIR /app/apps/${APP}
CMD ["pnpm", "run", "dev"]

# ---- Build ----
FROM base AS builder
ARG APP
COPY packages/nuxt-base/ ./packages/nuxt-base/
COPY apps/${APP}/ ./apps/${APP}/
WORKDIR /app/apps/${APP}
RUN pnpm run build

# ---- Production ----
FROM node:${NODE_VERSION}-alpine AS runner
ARG APP
WORKDIR /app
ENV NODE_ENV=production \
    NITRO_HOST=0.0.0.0 \
    NITRO_PORT=3000

COPY --from=builder --chown=node:node /app/apps/${APP}/.output ./.output

# Run as the unprivileged "node" user
USER node
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/ >/dev/null || exit 1

CMD ["node", ".output/server/index.mjs"]
