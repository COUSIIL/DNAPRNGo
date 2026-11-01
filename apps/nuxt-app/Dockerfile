# syntax=docker/dockerfile:1
# ---- Build stage (also used as the dev target in docker-compose.yml) ----
FROM node:20-alpine AS builder

WORKDIR /app
RUN corepack enable && corepack prepare pnpm@9 --activate

# Copy manifests first to maximise layer caching
COPY package.json pnpm-workspace.yaml ./
COPY apps/nuxt-app/package.json ./apps/nuxt-app/
RUN pnpm install --filter nuxt-app...

COPY apps/nuxt-app/ ./apps/nuxt-app/
WORKDIR /app/apps/nuxt-app
RUN pnpm run build

# ---- Production stage ----
FROM node:20-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production \
    NITRO_HOST=0.0.0.0 \
    NITRO_PORT=3000

COPY --from=builder --chown=node:node /app/apps/nuxt-app/.output ./.output

# Run as the unprivileged "node" user
USER node
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/ >/dev/null || exit 1

CMD ["node", ".output/server/index.mjs"]
