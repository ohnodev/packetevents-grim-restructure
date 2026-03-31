#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "${REPO_ROOT}"

echo "[bootstrap] Building Fabric artifacts..."
./gradlew :fabric:build

echo "[bootstrap] Setting up test server directory..."
"${SCRIPT_DIR}/setup-fabric-server.sh" \
  --mc-version 1.21.1 \
  --server-dir tests/runs/fabric-1.21.1

echo "[bootstrap] Installing PacketEvents intermediary dev jars..."
"${SCRIPT_DIR}/install-packetevents-dev-jars.sh" \
  --server-dir tests/runs/fabric-1.21.1 \
  --path intermediary

echo
echo "[bootstrap] Ready."
echo "Run the server with:"
echo "  ./tests/scripts/run-server.sh --server-dir tests/runs/fabric-1.21.1"
