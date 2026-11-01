# syntax=docker/dockerfile:1
# ---- Base: dependencies ----
FROM golang:1.24-alpine AS base
WORKDIR /app
RUN apk add --no-cache git ca-certificates tzdata
COPY go.mod go.sum ./
RUN go mod download

# ---- Dev: hot reload with air (docker-compose target: dev) ----
FROM base AS dev
RUN go install github.com/air-verse/air@v1.61.7
COPY . .
CMD ["air", "-c", ".air.toml"]

# ---- Build: static binary ----
FROM base AS builder
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/main .

# ---- Production ----
FROM alpine:3.20 AS runner
RUN apk --no-cache add ca-certificates tzdata wget \
 && addgroup -S app && adduser -S app -G app
WORKDIR /app
COPY --from=builder /out/main .
USER app
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD wget -qO- http://127.0.0.1:8080/health >/dev/null || exit 1
CMD ["./main"]
