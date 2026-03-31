#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "${REPO_ROOT}"

echo "[bootstrap:paper] Building Spigot plugin artifact..."
./gradlew :spigot:build

echo "[bootstrap:paper] Setting up Paper server..."
"${SCRIPT_DIR}/setup-paper-server.sh" \
  --mc-version 1.21.1 \
  --server-dir tests/runs/paper-1.21.1

echo "[bootstrap:paper] Installing PacketEvents plugin..."
"${SCRIPT_DIR}/install-packetevents-bukkit-dev-jar.sh" \
  --server-dir tests/runs/paper-1.21.1

echo
echo "[bootstrap:paper] Ready."
