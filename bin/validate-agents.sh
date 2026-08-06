#!/usr/bin/env bash
# validate-agents.sh — Validate native subagent Markdown specs (.agents/agents/*.md) and AGENTS.md consistency
#
# Usage: ./bin/validate-agents.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

python3 "${PROJECT_ROOT}/bin/validate_agents.py"
