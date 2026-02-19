#!/usr/bin/env bash
# Fix broken OrbStack symlink by pointing /usr/local/bin/docker to Docker Desktop.
# Run once: ./scripts/fix-docker-path.sh (requires sudo)

set -euo pipefail

DOCKER_BIN="/Applications/Docker.app/Contents/Resources/bin/docker"

if [[ ! -x "$DOCKER_BIN" ]]; then
  echo "Docker Desktop not found. Install Docker Desktop first." >&2
  exit 1
fi

echo "Fixing /usr/local/bin/docker symlink (was pointing to broken OrbStack path)..."
sudo ln -sf "$DOCKER_BIN" /usr/local/bin/docker
echo "Done. Run 'docker --version' to verify."
echo "Then: ./scripts/docker-test.sh"
