#!/bin/bash
# Zero-config remote deployment over SSH.
# Usage: SERVER_IP=1.2.3.4 SSH_USER=deploy ./scripts/deploy.sh
set -euo pipefail

# Configuration (override through the environment)
SERVER_IP="${SERVER_IP:-your_vps_ip}"
SSH_USER="${SSH_USER:-deploy_user}"
DEPLOY_DIR="${DEPLOY_DIR:-/opt/my-monorepo}"
API_DOMAIN="${API_DOMAIN:-api.exemple.com}"
BRANCH="${BRANCH:-main}"

if [ "$SERVER_IP" = "your_vps_ip" ]; then
    echo "ERROR: set SERVER_IP (and SSH_USER, DEPLOY_DIR, API_DOMAIN) before deploying." >&2
    exit 1
fi

echo "==================================="
echo " Deploying to ${SSH_USER}@${SERVER_IP}"
echo "==================================="

# The remote script is quoted ('EOF'): nothing is expanded locally.
# Variables are passed explicitly as arguments.
ssh -t "${SSH_USER}@${SERVER_IP}" bash -s -- "$DEPLOY_DIR" "$BRANCH" <<'EOF'
set -euo pipefail
DEPLOY_DIR="$1"
BRANCH="$2"
COMPOSE="docker compose -f docker-compose.prod.yml"

cd "$DEPLOY_DIR"

# Load POSTGRES_USER / POSTGRES_DB from the server .env
set -a; . ./.env; set +a

echo "1. Pulling latest code ($BRANCH)..."
git fetch origin "$BRANCH"
git reset --hard "origin/$BRANCH"

echo "2. Building images..."
$COMPOSE build

echo "3. Starting database first..."
$COMPOSE up -d postgres redis
until $COMPOSE exec -T postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; do
    echo "   PostgreSQL is not ready yet..."
    sleep 2
done

echo "4. Applying schema and migrations..."
for sql in ./scripts/init.sql $(ls ./scripts/migration-db/*.sql 2>/dev/null | sort); do
    echo "   -> $sql"
    $COMPOSE exec -T postgres psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$sql"
done

echo "5. Restarting services..."
$COMPOSE up -d --remove-orphans

echo "6. Cleaning dangling images..."
docker image prune -f
EOF

echo "7. Validating deployment..."
for attempt in 1 2 3 4 5 6; do
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${API_DOMAIN}/health" || true)
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "Deployment successful: API is healthy."
        exit 0
    fi
    echo "   attempt ${attempt}: HTTP ${HTTP_STATUS}, retrying..."
    sleep 5
done

echo "Deployment verification failed (last HTTP status: ${HTTP_STATUS})." >&2
exit 1
