# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copy workspace configuration and dependencies
COPY package.json pnpm-workspace.yaml ./
COPY apps/nuxt-app/package.json ./apps/nuxt-app/

# Install dependencies
RUN pnpm install --filter nuxt-app...

# Copy source code
COPY apps/nuxt-app/ ./apps/nuxt-app/

# Build Nuxt project
WORKDIR /app/apps/nuxt-app
RUN pnpm run build

# Production stage
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

# Copy built application
COPY --from=builder /app/apps/nuxt-app/.output ./.output

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]
