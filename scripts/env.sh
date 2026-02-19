#!/usr/bin/env bash
# Source this to add Docker to PATH (fixes "docker: command not found")
# Usage: source scripts/env.sh
[[ -d /Applications/Docker.app/Contents/Resources/bin ]] && export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
[[ -d /Applications/OrbStack.app/Contents/MacOS/xbin ]] && export PATH="/Applications/OrbStack.app/Contents/MacOS/xbin:$PATH"
