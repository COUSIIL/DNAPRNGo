# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@9 --activate

# Copy workspace configuration and dependencies
COPY package.json pnpm-workspace.yaml ./
COPY apps/astro-app/package.json ./apps/astro-app/

# Install dependencies (only for Astro initially to optimize caching)
RUN pnpm install --filter astro-app...

# Copy source code
COPY apps/astro-app/ ./apps/astro-app/

# Build Astro project
WORKDIR /app/apps/astro-app
RUN pnpm run build

# Production stage
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=4321

# Copy built assets
COPY --from=builder /app/apps/astro-app/dist ./dist
COPY --from=builder /app/apps/astro-app/package.json ./
# For node adapter standalone mode, dependencies are mostly bundled, but sometimes node_modules is needed
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/apps/astro-app/node_modules ./apps/astro-app/node_modules

EXPOSE 4321

CMD ["node", "./dist/server/entry.mjs"]
