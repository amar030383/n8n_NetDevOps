#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

: "${NET_DEVICE_USERNAME:?NET_DEVICE_USERNAME must be set in environment}"
: "${NET_DEVICE_PASSWORD:?NET_DEVICE_PASSWORD must be set in environment}"

NET_DEVICE_PORT=${NET_DEVICE_PORT:-22}
PORT=${PORT:-8000}

# Kill any process already using the port
if lsof -ti:${PORT} >/dev/null 2>&1; then
  echo "Killing process on port ${PORT}..."
  lsof -ti:${PORT} | xargs kill -9 2>/dev/null || true
  # Also kill any gunicorn netapi workers
  pkill -9 -f "gunicorn netapi" 2>/dev/null || true
  sleep 2
fi

echo "Starting Django application on http://localhost:${PORT}"
echo "POST /api/v1/run-show with {\"device_ip\":\"<ip>\",\"command\":\"<show command>\"}"
gunicorn netapi.wsgi:application --bind 0.0.0.0:${PORT}
