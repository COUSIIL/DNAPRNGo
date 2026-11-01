# syntax=docker/dockerfile:1
# ---- Build stage (also used as the dev target in docker-compose.yml) ----
FROM node:20-alpine AS builder

WORKDIR /app
RUN corepack enable && corepack prepare pnpm@10.26.2 --activate

# Copy manifests first to maximise layer caching
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY packages/nuxt-base/package.json ./packages/nuxt-base/
COPY apps/astro-app/package.json ./apps/astro-app/
RUN --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile --filter astro-app...

COPY apps/astro-app/ ./apps/astro-app/
WORKDIR /app/apps/astro-app
RUN pnpm run build

# ---- Production stage ----
FROM node:20-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=4321

# Built server + runtime dependencies (the node adapter needs them in standalone mode)
COPY --from=builder --chown=node:node /app/apps/astro-app/dist ./dist
COPY --from=builder --chown=node:node /app/apps/astro-app/package.json ./
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/apps/astro-app/node_modules ./apps/astro-app/node_modules

# Run as the unprivileged "node" user
USER node
EXPOSE 4321

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -qO- http://127.0.0.1:4321/ >/dev/null || exit 1

CMD ["node", "./dist/server/entry.mjs"]
