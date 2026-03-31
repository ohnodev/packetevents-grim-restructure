#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="tests/runs/fabric-1.21.1"
PATH_MODE="intermediary"

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
    *)
      echo "Unknown arg: $1"
      echo "Usage: $0 [--server-dir tests/runs/fabric-1.21.1] [--path intermediary|official]"
      exit 1
      ;;
  esac
done

if [[ "${PATH_MODE}" != "intermediary" && "${PATH_MODE}" != "official" ]]; then
  echo "Invalid --path '${PATH_MODE}', expected intermediary|official"
  exit 1
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
  local file
  file="$(ls -t ${BUILD_LIBS}/${pattern} 2>/dev/null | head -n 1 || true)"
  if [[ -z "${file}" ]]; then
    return 1
  fi
  printf '%s\n' "${file}"
}

main_fabric_jar="$(latest_jar "packetevents-fabric-*.jar" | awk '!/javadoc|sources|fabric-common|fabric-intermediary|fabric-official|fabric-mc/' | head -n 1 || true)"
if [[ -z "${main_fabric_jar}" ]]; then
  # Fallback if awk filtering above doesn't catch due to shell expansion ordering
  for f in $(ls -t "${BUILD_LIBS}"/packetevents-fabric-*.jar 2>/dev/null); do
    b="$(basename "${f}")"
    if [[ "${b}" == *-sources.jar || "${b}" == *-javadoc.jar ]]; then
      continue
    fi
    if [[ "${b}" == packetevents-fabric-common-* || "${b}" == packetevents-fabric-intermediary-* || "${b}" == packetevents-fabric-official-* || "${b}" == packetevents-fabric-mc* ]]; then
      continue
    fi
    main_fabric_jar="${f}"
    break
  done
fi

if [[ -z "${main_fabric_jar}" ]]; then
  echo "Could not find main packetevents-fabric jar in ${BUILD_LIBS}"
  exit 1
fi

echo "[install] Cleaning existing PacketEvents jars from ${MODS_DIR}"
rm -f "${MODS_DIR}"/packetevents-*.jar

echo "[install] Copying main jar:"
echo "  - $(basename "${main_fabric_jar}")"
cp -f "${main_fabric_jar}" "${MODS_DIR}/"

common_jar="$(latest_jar "packetevents-fabric-common-*.jar" | awk '!/javadoc|sources/' | head -n 1 || true)"
if [[ -n "${common_jar}" ]]; then
  cp -f "${common_jar}" "${MODS_DIR}/"
fi

if [[ "${PATH_MODE}" == "intermediary" ]]; then
  intermediary_jar="$(latest_jar "packetevents-fabric-intermediary-*.jar" | awk '!/javadoc|sources/' | head -n 1 || true)"
  if [[ -n "${intermediary_jar}" ]]; then
    cp -f "${intermediary_jar}" "${MODS_DIR}/"
  fi

  for module_prefix in $(ls "${BUILD_LIBS}"/packetevents-fabric-mc*.jar 2>/dev/null | sed -E 's#^.*/(packetevents-fabric-mc[0-9]+)-.*#\1#' | sort -u); do
    module_jar="$(latest_jar "${module_prefix}-*.jar" | awk '!/javadoc|sources/' | head -n 1 || true)"
    if [[ -n "${module_jar}" ]]; then
      cp -f "${module_jar}" "${MODS_DIR}/"
    fi
  done
else
  official_jar="$(latest_jar "packetevents-fabric-official-*.jar" | awk '!/javadoc|sources/' | head -n 1 || true)"
  if [[ -n "${official_jar}" ]]; then
    cp -f "${official_jar}" "${MODS_DIR}/"
  fi
fi

echo "[install] Installed jars:"
ls -1 "${MODS_DIR}" | sed 's/^/  - /'
