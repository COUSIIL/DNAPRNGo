#!/bin/bash

set -e

echo "========================================"
echo " Starting VARQAI development environment"
echo "========================================"
echo ""

# --------------------------------------------------
# 0. Configuration
# --------------------------------------------------

POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-monorepo_db}"

# --------------------------------------------------
# 1. Start PostgreSQL
# --------------------------------------------------

echo "Starting PostgreSQL..."

docker compose up -d postgres

echo ""

# --------------------------------------------------
# 2. Wait for PostgreSQL
# --------------------------------------------------

echo "Waiting for PostgreSQL..."

until docker compose exec -T postgres \
    pg_isready \
    -U "$POSTGRES_USER" \
    -d "$POSTGRES_DB" \
    > /dev/null 2>&1
do
    echo "PostgreSQL is not ready yet..."
    sleep 2
done

echo "PostgreSQL is ready!"
echo ""

# --------------------------------------------------
# 3. Initialize database
# --------------------------------------------------

INIT_SQL="./scripts/init.sql"

if [ ! -f "$INIT_SQL" ]; then
    echo "ERROR: $INIT_SQL not found."
    exit 1
fi

echo "Executing database initialization..."

docker compose exec -T postgres \
    psql \
    -U "$POSTGRES_USER" \
    -d "$POSTGRES_DB" \
    < "$INIT_SQL"

echo "Database initialization completed."
echo ""

# --------------------------------------------------
# 4. Execute migrations
# --------------------------------------------------

MIGRATIONS_DIR="./scripts/migration-db"

if [ -d "$MIGRATIONS_DIR" ]; then

    migration_files=$(find "$MIGRATIONS_DIR" -maxdepth 1 -type f -name "*.sql" | sort)

    if [ -n "$migration_files" ]; then

        echo "Applying database migrations..."

        while IFS= read -r migration_file; do

            echo "Executing migration: $migration_file"

            docker compose exec -T postgres \
                psql \
                -U "$POSTGRES_USER" \
                -d "$POSTGRES_DB" \
                < "$migration_file"

        done <<< "$migration_files"

        echo "Migrations completed."

    else
        echo "No migration files found."
    fi

    echo ""
fi

# --------------------------------------------------
# 5. Start all services
# --------------------------------------------------

echo "Starting VARQAI services..."

docker compose up -d

echo ""

# --------------------------------------------------
# 6. Status
# --------------------------------------------------

echo "========================================"
echo " Services status"
echo "========================================"

docker compose ps

echo ""

# --------------------------------------------------
# 7. Development URLs
# --------------------------------------------------

echo "========================================"
echo " Development URLs"
echo "========================================"

echo "Astro: http://localhost"
echo "Nuxt:  http://app.localhost"
echo "Center: http://center.localhost"
echo "API:   http://api.localhost/health"

echo ""

# --------------------------------------------------
# 8. Logs
# --------------------------------------------------

echo "========================================"
echo " Following logs"
echo " Press CTRL+C to stop viewing logs"
echo "========================================"

echo ""

docker compose logs -f
