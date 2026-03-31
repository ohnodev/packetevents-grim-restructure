#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="tests/runs/paper-1.21.1"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --server-dir)
      SERVER_DIR="${2:?missing value for --server-dir}"
      shift 2
      ;;
    *)
      echo "Unknown arg: $1"
      echo "Usage: $0 [--server-dir tests/runs/paper-1.21.1]"
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BUILD_LIBS="${REPO_ROOT}/build/libs"
PLUGINS_DIR="${REPO_ROOT}/${SERVER_DIR}/plugins"

if [[ ! -d "${BUILD_LIBS}" ]]; then
  echo "[install] Missing build output directory: ${BUILD_LIBS}" >&2
  echo "[install] Run: ./gradlew :spigot:build" >&2
  exit 1
fi

mkdir -p "${PLUGINS_DIR}"

latest_spigot_jar() {
  local newest=""
  shopt -s nullglob
  local candidates=( "${BUILD_LIBS}"/packetevents-spigot-*.jar )
  shopt -u nullglob
  local f
  for f in "${candidates[@]}"; do
    [[ -e "${f}" ]] || continue
    case "$(basename "${f}")" in
      *-sources.jar|*-javadoc.jar) continue ;;
    esac
    if [[ -z "${newest}" || "${f}" -nt "${newest}" ]]; then
      newest="${f}"
    fi
  done
  [[ -n "${newest}" ]] && printf '%s\n' "${newest}"
}

SPIGOT_JAR="$(latest_spigot_jar || true)"
if [[ -z "${SPIGOT_JAR}" ]]; then
  echo "[install] Missing packetevents-spigot jar in ${BUILD_LIBS}" >&2
  exit 1
fi

echo "[install] Cleaning existing PacketEvents plugin jars from ${PLUGINS_DIR}"
rm -f "${PLUGINS_DIR}"/packetevents*.jar

echo "[install] Copying plugin jar:"
echo "  - $(basename "${SPIGOT_JAR}")"
cp -f "${SPIGOT_JAR}" "${PLUGINS_DIR}/"

echo "[install] Installed plugin jars:"
ls -1 "${PLUGINS_DIR}" | sed 's/^/  - /'
