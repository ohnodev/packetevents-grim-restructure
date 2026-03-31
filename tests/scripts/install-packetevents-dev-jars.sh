#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="tests/runs/fabric-1.21.1"
PATH_MODE="intermediary"
PROFILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --server-dir)
      SERVER_DIR="${2:?missing value for --server-dir}"
      shift 2
      ;;
    --path)
      PATH_MODE="${2:?missing value for --path}"
      shift 2
      ;;
    --profile)
      PROFILE="${2:?missing value for --profile}"
      shift 2
      ;;
    *)
      echo "Unknown arg: $1"
      echo "Usage: $0 [--server-dir tests/runs/fabric-1.21.1] [--path intermediary|official] [--profile intermediary-1194|intermediary-1216|official-261]"
      exit 1
      ;;
  esac
done

if [[ "${PATH_MODE}" != "intermediary" && "${PATH_MODE}" != "official" ]]; then
  echo "Invalid --path '${PATH_MODE}', expected intermediary|official"
  exit 1
fi

if [[ -z "${PROFILE}" ]]; then
  if [[ "${PATH_MODE}" == "intermediary" ]]; then
    PROFILE="intermediary-1216"
  else
    PROFILE="official-261"
  fi
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BUILD_LIBS="${REPO_ROOT}/build/libs"
MODS_DIR="${REPO_ROOT}/${SERVER_DIR}/mods"

if [[ ! -d "${BUILD_LIBS}" ]]; then
  echo "Missing build output directory: ${BUILD_LIBS}"
  echo "Run: ./gradlew :fabric:build"
  exit 1
fi

mkdir -p "${MODS_DIR}"

latest_jar() {
  local pattern="$1"
  local newest=""
  shopt -s nullglob
  local matches=( "${BUILD_LIBS}"/${pattern} )
  shopt -u nullglob
  local file
  for file in "${matches[@]}"; do
    [[ -e "${file}" ]] || continue
    local base
    base="$(basename "${file}")"
    if [[ "${base}" == *-sources.jar || "${base}" == *-javadoc.jar ]]; then
      continue
    fi
    if [[ -z "${newest}" || "${file}" -nt "${newest}" ]]; then
      newest="${file}"
    fi
  done
  if [[ -z "${newest}" ]]; then
    return 1
  fi
  printf '%s\n' "${newest}"
}

copy_latest_by_pattern() {
  local pattern="$1"
  local label="${2:-${pattern}}"
  local required="${3:-0}"
  local selected
  selected="$(latest_jar "${pattern}" || true)"
  if [[ -z "${selected}" ]]; then
    if [[ "${required}" == "1" ]]; then
      echo "[install] Missing required jar: ${label} (pattern: ${pattern})" >&2
      return 1
    fi
    return 0
  fi
  cp -f "${selected}" "${MODS_DIR}/"
  echo "  - $(basename "${selected}")"
}

copy_main_fabric_jar() {
  local selected=""
  shopt -s nullglob
  local f
  for f in "${BUILD_LIBS}"/packetevents-fabric-*.jar; do
    [[ -e "${f}" ]] || continue
    local b
    b="$(basename "${f}")"
    if [[ "${b}" == *-sources.jar || "${b}" == *-javadoc.jar ]]; then
      continue
    fi
    if [[ "${b}" == packetevents-fabric-common-* || "${b}" == packetevents-fabric-intermediary-* || "${b}" == packetevents-fabric-official-* || "${b}" == packetevents-fabric-mc* ]]; then
      continue
    fi
    if [[ -z "${selected}" || "${f}" -nt "${selected}" ]]; then
      selected="${f}"
    fi
  done
  shopt -u nullglob
  if [[ -z "${selected}" ]]; then
    echo "[install] Missing main packetevents-fabric jar" >&2
    return 1
  fi
  cp -f "${selected}" "${MODS_DIR}/"
  echo "  - $(basename "${selected}")"
}

copy_latest_mc_module() {
  local module="$1"
  local selected
  selected="$(latest_jar "packetevents-fabric-${module}-*.jar" || true)"
  if [[ -z "${selected}" ]]; then
    echo "[install] Missing module jar for ${module}" >&2
    return 1
  fi
  cp -f "${selected}" "${MODS_DIR}/"
  echo "  - $(basename "${selected}")"
}

echo "[install] Cleaning existing PacketEvents jars from ${MODS_DIR}"
rm -f "${MODS_DIR}"/packetevents-*.jar

echo "[install] Installing PacketEvents jars for profile: ${PROFILE}"
case "${PROFILE}" in
  intermediary-1194)
    copy_main_fabric_jar
    copy_latest_by_pattern "packetevents-fabric-common-*.jar" "fabric-common"
    copy_latest_by_pattern "packetevents-fabric-intermediary-*.jar" "fabric-intermediary" 1
    copy_latest_mc_module "mc1140"
    copy_latest_mc_module "mc1194"
    ;;
  intermediary-1216)
    copy_main_fabric_jar
    copy_latest_by_pattern "packetevents-fabric-common-*.jar" "fabric-common"
    copy_latest_by_pattern "packetevents-fabric-intermediary-*.jar" "fabric-intermediary" 1
    copy_latest_mc_module "mc1140"
    copy_latest_mc_module "mc1194"
    copy_latest_mc_module "mc1202"
    copy_latest_mc_module "mc1211"
    copy_latest_mc_module "mc1215"
    copy_latest_mc_module "mc1216"
    ;;
  official-261)
    copy_main_fabric_jar
    copy_latest_by_pattern "packetevents-fabric-common-*.jar" "fabric-common"
    copy_latest_by_pattern "packetevents-fabric-official-*.jar" "fabric-official" 1
    ;;
  *)
    echo "Unknown profile: ${PROFILE}"
    echo "Expected: intermediary-1194 | intermediary-1216 | official-261"
    exit 1
    ;;
esac

echo "[install] Installed jars:"
ls -1 "${MODS_DIR}" | sed 's/^/  - /'
