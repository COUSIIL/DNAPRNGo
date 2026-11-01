#!/bin/bash

set -e

echo "========================================"
echo " Cleaning unused Docker resources"
echo "========================================"
echo ""

echo "Before cleanup:"
docker system df

echo ""
echo "Cleaning unused volumes..."
docker volume prune -f

echo ""
echo "Cleaning unused build cache..."
docker builder prune -a -f

echo ""
echo "Cleaning unused images..."
docker image prune -a -f

echo ""
echo "After cleanup:"
docker system df

echo ""
echo "Docker cleanup completed."
