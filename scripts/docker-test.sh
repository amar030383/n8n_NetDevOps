#!/usr/bin/env bash
# Docker test script for n8n_NetDevOps
# Usage: ./scripts/docker-test.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

# Use docker wrapper (fixes OrbStack/Docker Desktop path)
DOCKER="$SCRIPT_DIR/docker-wrap.sh"

# Ensure .env exists with credentials (docker-compose reads it)
if [[ ! -f .env ]]; then
  echo "Creating .env from .env.example - please edit .env with your credentials"
  cp .env.example .env
  echo "Edit .env and add NET_DEVICE_USERNAME and NET_DEVICE_PASSWORD, then re-run."
  exit 1
fi

# Check .env has required vars (simple grep - value after =)
if ! grep -qE '^NET_DEVICE_USERNAME=.+' .env || ! grep -qE '^NET_DEVICE_PASSWORD=.+' .env; then
  echo "Error: .env must have NET_DEVICE_USERNAME and NET_DEVICE_PASSWORD set." >&2
  echo "Edit .env and add your network device credentials." >&2
  exit 1
fi

# Stop local app if running (port 8000)
if lsof -ti:8000 >/dev/null 2>&1; then
  echo "Stopping local app on port 8000..."
  lsof -ti:8000 | xargs kill -9 2>/dev/null || true
  pkill -9 -f "gunicorn netapi" 2>/dev/null || true
  sleep 2
fi

echo "Building and starting Docker containers..."
"$DOCKER" compose up --build -d

echo "Waiting for services to be ready..."
sleep 5

# Test health endpoint
echo ""
echo "=== Testing health endpoint ==="
curl -s http://localhost:8000/api/v1/health | jq . 2>/dev/null || curl -s http://localhost:8000/api/v1/health
echo ""

# Test run-show (uses admin:admin by default from .env)
echo "=== Testing run-show endpoint ==="
curl -s -X POST -u admin:admin \
  -H "Content-Type: application/json" \
  -d '{"device_ip":"172.18.9.31","device_type":"arista_eos","command":"show version"}' \
  http://localhost:8000/api/v1/run-show | jq . 2>/dev/null || curl -s -X POST -u admin:admin \
  -H "Content-Type: application/json" \
  -d '{"device_ip":"172.18.9.31","device_type":"arista_eos","command":"show version"}' \
  http://localhost:8000/api/v1/run-show
echo ""

echo ""
echo "=== n8n_engine UI ==="
echo "Open http://localhost:5678 to access n8n"
echo "Use http://host.docker.internal:8000/api/v1/run-show in n8n HTTP Request nodes"
echo ""
echo "To view logs: ./scripts/docker-wrap.sh compose logs -f"
echo "To stop: ./scripts/docker-wrap.sh compose down"
