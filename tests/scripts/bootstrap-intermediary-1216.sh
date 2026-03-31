#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/bootstrap-case.sh" \
  --case intermediary-1216 \
  --mc-version 1.21.6 \
  --server-dir tests/runs/fabric-1.21.6 \
  --profile intermediary-1216
