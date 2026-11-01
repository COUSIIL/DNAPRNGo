#!/bin/bash

set -euo pipefail

echo "========================================"
echo " Stopping DEV development environment"
echo "========================================"
echo ""

# --------------------------------------------------
# 1. Stop containers
# --------------------------------------------------

echo "Stopping DEV services..."

docker compose down

echo ""

# --------------------------------------------------
# 2. Clean unused containers
# --------------------------------------------------

echo "Cleaning unused containers..."

docker container prune -f

echo ""

# --------------------------------------------------
# 3. Show Docker disk usage
# --------------------------------------------------

echo "========================================"
echo " Docker disk usage"
echo "========================================"

docker system df

echo ""

echo "DEV development environment stopped."
