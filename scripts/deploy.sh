#!/bin/bash
set -e

# Configuration
SERVER_IP="your_vps_ip"
SSH_USER="deploy_user"
DEPLOY_DIR="/opt/my-monorepo"
API_DOMAIN="api.exemple.com"

echo "==================================="
echo " Starting Zero-Downtime Deployment "
echo "==================================="

# Execute commands on remote VPS via SSH
ssh -t ${SSH_USER}@${SERVER_IP} << EOF
    set -e
    echo "1. Navigating to project directory..."
    cd ${DEPLOY_DIR}

    echo "2. Pulling latest code..."
    git pull origin main

    echo "3. Building new images..."
    docker compose -f docker-compose.prod.yml build

    echo "4. Restarting containers (Zero-Downtime approach via remove-orphans)..."
    docker compose -f docker-compose.prod.yml up -d --remove-orphans

    echo "5. Waiting for PostgreSQL to be ready..."
    until docker compose -f docker-compose.prod.yml exec -T postgres pg_isready -U "\${POSTGRES_USER:-postgres}" -d "\${POSTGRES_DB:-monorepo_db}" > /dev/null 2>&1; do
        echo "PostgreSQL is not ready yet..."
        sleep 2
    done
    echo "PostgreSQL is ready!"

    echo "6. Applying database migrations..."
    MIGRATIONS_DIR="./scripts/migration-db"
    if [ -d "\$MIGRATIONS_DIR" ]; then
        if ls "\$MIGRATIONS_DIR"/*.sql 1> /dev/null 2>&1; then
            for migration_file in \$(ls "\$MIGRATIONS_DIR"/*.sql | sort); do
                echo "Executing migration: \$migration_file"
                docker compose -f docker-compose.prod.yml exec -T postgres \
                    psql \
                    -U "\${POSTGRES_USER:-postgres}" \
                    -d "\${POSTGRES_DB:-monorepo_db}" \
                    < "\$migration_file"
            done
            echo "Migrations applied successfully."
        else
            echo "No migration files found in \$MIGRATIONS_DIR."
        fi
    fi

    echo "7. Cleaning up old images..."
    docker system prune -f
EOF

echo "8. Validating Deployment..."
sleep 5 # Wait a few seconds for services to fully start

# Check Health Endpoint
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://${API_DOMAIN}/health)

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ Deployment Successful! API is healthy."
else
    echo "❌ Deployment Verification Failed! HTTP Status: $HTTP_STATUS"
    exit 1
fi
