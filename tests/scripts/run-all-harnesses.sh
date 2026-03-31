#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
JAVA25_BIN="${JAVA25_BIN:-/root/.gradle/jdks/eclipse_adoptium-25-amd64-linux.2/bin/java}"

cd "${REPO_ROOT}"

smoke_start() {
  local case_name="$1"
  shift
  local log_file
  log_file="$(mktemp)"

  set +e
  timeout 45s "$@" > >(tee "${log_file}") 2>&1
  local rc=$?
  set -e

  if [[ ${rc} -ne 0 && ${rc} -ne 124 ]]; then
    echo "[all] ${case_name} failed with exit code ${rc}"
    rm -f "${log_file}"
    return 1
  fi

  if ! python3 - "${log_file}" <<'PY'
import pathlib
import sys
text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8", errors="ignore")
sys.exit(0 if "Done (" in text else 1)
PY
  then
    echo "[all] ${case_name} did not reach startup completion."
    rm -f "${log_file}"
    return 1
  fi

  rm -f "${log_file}"
}

echo "[all] Case 1/3: intermediary (1.19.4)"
"${SCRIPT_DIR}/bootstrap-intermediary-1194.sh"
smoke_start "intermediary-1194" "${SCRIPT_DIR}/run-server.sh" --server-dir tests/runs/fabric-1.19.4

echo "[all] Case 2/3: intermediary (1.21.6)"
"${SCRIPT_DIR}/bootstrap-intermediary-1216.sh"
smoke_start "intermediary-1216" "${SCRIPT_DIR}/run-server.sh" --server-dir tests/runs/fabric-1.21.6

echo "[all] Case 3/3: official (26.1)"
if [[ ! -x "${JAVA25_BIN}" ]]; then
  echo "[all] Missing Java 25 binary at ${JAVA25_BIN}"
  echo "[all] Set JAVA25_BIN to your Java 25 executable and retry."
  exit 1
fi
"${SCRIPT_DIR}/bootstrap-official-261.sh"
smoke_start "official-261" "${SCRIPT_DIR}/run-server.sh" --server-dir tests/runs/fabric-26.1 --java-bin "${JAVA25_BIN}"

echo "[all] Harness run complete."
