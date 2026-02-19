#!/usr/bin/env bash
# Stop containers, remove old images, and rebuild from scratch.
# Usage: ./scripts/docker-rebuild.sh

set -euo pipefail

cd "$(dirname "$0")/.."

# Ensure Docker in PATH (for when run from minimal env)
[[ -d /Applications/Docker.app/Contents/Resources/bin ]] && export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"

# Ensure Docker is available
command -v docker &>/dev/null || {
  echo "Error: docker not found. Install Docker Desktop and start it." >&2
  exit 1
}

# Check Docker daemon is running
if ! docker info &>/dev/null; then
  echo "Error: Docker daemon not running. Open Docker Desktop from Applications and wait for it to start." >&2
  exit 1
fi

# Ensure .env has credentials (docker-compose needs them)
[[ -f .env ]] || { echo "Error: .env missing. Copy from .env.example and add credentials." >&2; exit 1; }

echo "Stopping containers..."
docker compose down --remove-orphans 2>/dev/null || true

# Stop containers on ports 8000/5678 (from old runs)
for port in 8000 5678; do
  for id in $(docker ps -q --filter "publish=$port" 2>/dev/null); do
    docker stop "$id" 2>/dev/null || true
  done
done
pkill -9 -f "gunicorn netapi" 2>/dev/null || true
sleep 2

echo "Removing project images..."
docker compose down --rmi local --remove-orphans 2>/dev/null || true
docker image rm netdevops-netdevops 2>/dev/null || true

echo "Building from scratch..."
docker compose build --no-cache

echo "Starting containers..."
docker compose up -d

echo ""
echo "Done. n8n_engine: http://localhost:5678  |  netdevops: http://localhost:8000"
echo "n8n HTTP Request URL: http://host.docker.internal:8000/api/v1/run-show"
