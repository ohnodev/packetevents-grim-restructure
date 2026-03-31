#!/usr/bin/env bash
set -euo pipefail

CASE_NAME=""
MC_VERSION=""
SERVER_DIR=""
PROFILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --case)
      CASE_NAME="${2:?missing value for --case}"
      shift 2
      ;;
    --mc-version)
      MC_VERSION="${2:?missing value for --mc-version}"
      shift 2
      ;;
    --server-dir)
      SERVER_DIR="${2:?missing value for --server-dir}"
      shift 2
      ;;
    --profile)
      PROFILE="${2:?missing value for --profile}"
      shift 2
      ;;
    *)
      echo "Unknown arg: $1"
      echo "Usage: $0 --case name --mc-version 1.21.6 --server-dir tests/runs/name --profile intermediary-1216|intermediary-1194|official-261"
      exit 1
      ;;
  esac
done

if [[ -z "${CASE_NAME}" || -z "${MC_VERSION}" || -z "${SERVER_DIR}" || -z "${PROFILE}" ]]; then
  echo "Missing required args."
  echo "Usage: $0 --case name --mc-version 1.21.6 --server-dir tests/runs/name --profile intermediary-1216|intermediary-1194|official-261"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "${REPO_ROOT}"

echo "[bootstrap:${CASE_NAME}] Building Fabric artifacts..."
case "${PROFILE}" in
  intermediary-*)
    ./gradlew :fabric:build :fabric-intermediary:build
    ;;
  official-261)
    ./gradlew :fabric:build :fabric-official:build
    ;;
  *)
    ./gradlew :fabric:build
    ;;
esac

echo "[bootstrap:${CASE_NAME}] Setting up server ${MC_VERSION}..."
"${SCRIPT_DIR}/setup-fabric-server.sh" \
  --mc-version "${MC_VERSION}" \
  --server-dir "${SERVER_DIR}"

echo "[bootstrap:${CASE_NAME}] Installing PacketEvents jars (${PROFILE})..."
"${SCRIPT_DIR}/install-packetevents-dev-jars.sh" \
  --server-dir "${SERVER_DIR}" \
  --profile "${PROFILE}"

echo
echo "[bootstrap:${CASE_NAME}] Ready."
