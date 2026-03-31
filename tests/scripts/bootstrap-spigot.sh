#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "${REPO_ROOT}"

echo "[bootstrap:spigot] Building Spigot plugin artifact..."
./gradlew :spigot:build

echo "[bootstrap:spigot] Setting up Spigot server..."
"${SCRIPT_DIR}/setup-spigot-server.sh" \
  --mc-version 1.21.1 \
  --server-dir tests/runs/spigot-1.21.1

echo "[bootstrap:spigot] Installing PacketEvents plugin..."
"${SCRIPT_DIR}/install-packetevents-bukkit-dev-jar.sh" \
  --server-dir tests/runs/spigot-1.21.1

echo
echo "[bootstrap:spigot] Ready."
