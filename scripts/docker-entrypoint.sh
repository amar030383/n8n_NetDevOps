#!/bin/sh
set -e
cd /app
python manage.py migrate --noinput
python scripts/create_admin.py
exec "$@"
