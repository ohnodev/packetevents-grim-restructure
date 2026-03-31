#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/bootstrap-case.sh" \
  --case intermediary-1194 \
  --mc-version 1.19.4 \
  --server-dir tests/runs/fabric-1.19.4 \
  --profile intermediary-1194
