#!/usr/bin/env bash
# bin/sync-templates.sh — Template Synchronization & Drift Verification Tool
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

python3 "${PROJECT_ROOT}/bin/sync_templates.py" "$@"
