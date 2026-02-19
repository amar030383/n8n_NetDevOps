#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Load .env if present
[[ -f .env ]] && set -a && source .env && set +a

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
echo "POST /api/v1/run-show with {\"device_ip\":\"<ip>\",\"device_type\":\"<arista_eos|cisco_ios|...>\",\"command\":\"<show command>\"}"

# Apply database migrations
python3 manage.py migrate --noinput

# Create admin user
python3 scripts/create_admin.py

# Start Gunicorn with workers and threads for concurrency
gunicorn netapi.wsgi:application --bind 0.0.0.0:${PORT} --workers 4 --threads 4
