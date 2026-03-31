#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/bootstrap-case.sh" \
  --case official-261 \
  --mc-version 26.1 \
  --server-dir tests/runs/fabric-26.1 \
  --profile official-261
