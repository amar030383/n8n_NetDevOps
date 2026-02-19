#!/usr/bin/env bash
# Wrapper to find and run docker (fixes OrbStack/Docker Desktop path issues)
# Usage: ./scripts/docker-wrap.sh compose up --build -d

DOCKER_BIN=""
for path in \
  "/Applications/Docker.app/Contents/Resources/bin/docker" \
  "/Applications/OrbStack.app/Contents/MacOS/xbin/docker" \
  "$(command -v docker 2>/dev/null)"
do
  [[ -n "$path" ]] && [[ -x "$path" ]] && DOCKER_BIN="$path" && break
done

if [[ -z "$DOCKER_BIN" ]]; then
  echo "Error: docker not found. Install Docker Desktop or OrbStack, then start it." >&2
  exit 1
fi

# Ensure credential helpers (docker-credential-osxkeychain) are in PATH
DOCKER_DIR="$(dirname "$DOCKER_BIN")"
export PATH="$DOCKER_DIR:$PATH"

exec "$DOCKER_BIN" "$@"
