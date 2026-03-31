#!/usr/bin/env bash
set -euo pipefail

MC_VERSION="1.21.1"
SERVER_DIR="tests/runs/fabric-1.21.1"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mc-version)
      MC_VERSION="${2:?missing value for --mc-version}"
      shift 2
      ;;
    --server-dir)
      SERVER_DIR="${2:?missing value for --server-dir}"
      shift 2
      ;;
    *)
      echo "Unknown arg: $1"
      echo "Usage: $0 [--mc-version 1.21.1] [--server-dir tests/runs/fabric-1.21.1]"
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TARGET_DIR="${REPO_ROOT}/${SERVER_DIR}"
CACHE_DIR="${REPO_ROOT}/tests/.cache"
LOADER_META_URL="https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}"
INSTALLER_META_URL="https://meta.fabricmc.net/v2/versions/installer"

mkdir -p "${TARGET_DIR}" "${TARGET_DIR}/mods" "${CACHE_DIR}"

echo "[setup] Resolving Fabric loader/installer for MC ${MC_VERSION}..."
read -r LOADER_VERSION INSTALLER_VERSION < <(
  python3 - <<'PY' "${LOADER_META_URL}" "${INSTALLER_META_URL}"
import json, sys, urllib.request
loader_url = sys.argv[1]
installer_url = sys.argv[2]

with urllib.request.urlopen(loader_url) as r:
    loader_data = json.load(r)
if not loader_data:
    raise SystemExit("No loader metadata found for requested MC version")
loader_version = loader_data[0]["loader"]["version"]

with urllib.request.urlopen(installer_url) as r:
    installer_data = json.load(r)
if not installer_data:
    raise SystemExit("No installer metadata found")
installer_version = installer_data[0]["version"]

print(loader_version, installer_version)
PY
)

SERVER_JAR_URL="https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}/${LOADER_VERSION}/${INSTALLER_VERSION}/server/jar"
SERVER_JAR_PATH="${TARGET_DIR}/fabric-server-launch.jar"

echo "[setup] MC=${MC_VERSION} loader=${LOADER_VERSION} installer=${INSTALLER_VERSION}"
echo "[setup] Downloading server jar..."
curl -fsSL "${SERVER_JAR_URL}" -o "${SERVER_JAR_PATH}"

cat > "${TARGET_DIR}/eula.txt" <<'EOF'
eula=true
EOF

echo "[setup] Server directory ready at: ${TARGET_DIR}"
echo "[setup] Next: ./tests/scripts/install-packetevents-dev-jars.sh --server-dir ${SERVER_DIR} --path intermediary"
