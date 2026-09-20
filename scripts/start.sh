#!/bin/bash

echo "Starting development environment..."
docker compose up -d

echo "Services started!"
echo "Astro: http://localhost"
echo "Nuxt:  http://app.localhost"
echo "API:   http://api.localhost/health"

# Follow logs for debugging
docker compose logs -f
