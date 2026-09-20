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

    echo "5. Cleaning up old images..."
    docker system prune -f
EOF

echo "6. Validating Deployment..."
sleep 5 # Wait a few seconds for services to fully start

# Check Health Endpoint
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://${API_DOMAIN}/health)

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ Deployment Successful! API is healthy."
else
    echo "❌ Deployment Verification Failed! HTTP Status: $HTTP_STATUS"
    exit 1
fi
