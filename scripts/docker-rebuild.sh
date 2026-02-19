#!/usr/bin/env bash
# Stop containers, remove old images, and rebuild from scratch.
# Usage: ./scripts/docker-rebuild.sh

set -euo pipefail
cd "$(dirname "$0")/.."

[[ -d /Applications/Docker.app/Contents/Resources/bin ]] && export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"

command -v docker &>/dev/null || { echo "Error: docker not found." >&2; exit 1; }
docker info &>/dev/null || { echo "Error: Docker daemon not running." >&2; exit 1; }
[[ -f .env ]] || { echo "Error: .env missing. Copy from .env.example." >&2; exit 1; }

echo "Stopping containers..."
docker compose down --remove-orphans 2>/dev/null || true

for port in 8000 5678; do
  for id in $(docker ps -q --filter "publish=$port" 2>/dev/null); do
    docker stop "$id" 2>/dev/null || true
  done
done
pkill -9 -f "gunicorn netapi" 2>/dev/null || true
sleep 2

echo "Removing project images..."
docker compose down --rmi local --remove-orphans 2>/dev/null || true

echo "Building from scratch..."
docker compose build --no-cache

echo "Starting containers..."
docker compose up -d

echo ""
echo "Done. n8n_engine: http://localhost:5678  |  netdevops: http://localhost:8000"
