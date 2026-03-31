#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Delegates to the 1.21.6 intermediary harness, which explicitly builds
# :fabric-intermediary:build before installing dev jars.
"${SCRIPT_DIR}/bootstrap-intermediary-1216.sh"
