#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Check if psql and sqlx are installed
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

check_dependency() {
  if ! command_exists "$1"; then
    echo >&2 "Error: $1 is not installed."
    exit 1
  fi
}

check_dependency "psql"
check_dependency "sqlx"

# Set default values for PostgreSQL connection parameters
DB_USER="${POSTGRES_USER:-postgres}"
DB_PASSWORD="${POSTGRES_PASSWORD:-password}"
DB_NAME="${POSTGRES_DB:-newsletter}"
DB_PORT="${POSTGRES_PORT:-5432}"
DB_HOST="${POSTGRES_HOST:-localhost}"

# Allow skipping Docker if a dockerized PostgreSQL database is already running
if [ -z "${SKIP_DOCKER:-}" ]; then
  # Check if a PostgreSQL container is running
  RUNNING_POSTGRES_CONTAINER=$(docker ps --filter 'name=postgres' --format '{{.ID}}')
  if [ -n "$RUNNING_POSTGRES_CONTAINER" ]; then
    echo >&2 "There is a PostgreSQL container already running. Kill it with:"
    echo >&2 "    docker kill $RUNNING_POSTGRES_CONTAINER"
    exit 1
  fi

  # Launch PostgreSQL using Docker
  docker run \
    -e POSTGRES_USER="${DB_USER}" \
    -e POSTGRES_PASSWORD="${DB_PASSWORD}" \
    -e POSTGRES_DB="${DB_NAME}" \
    -p "${DB_PORT}:5432" \
    -d \
    --name "postgres_$(date '+%s')" \
    postgres -N 1000
    # ^ Increased maximum number of connections for testing purposes
fi

# Keep pinging PostgreSQL until it's ready to accept commands
until PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -p "${DB_PORT}" -d "postgres" -c '\q'; do
  >&2 echo "PostgreSQL is still unavailable - sleeping"
  sleep 1
done

>&2 echo "PostgreSQL is up and running on port ${DB_PORT} - running migrations now!"

# Set DATABASE_URL environment variable
export DATABASE_URL="postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
# Run SQLx database creation and migrations
sqlx database create
sqlx migrate run

>&2 echo "PostgreSQL has been migrated, ready to go!"
