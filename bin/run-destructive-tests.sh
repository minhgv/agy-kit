#!/usr/bin/env bash
# bin/run-destructive-tests.sh — Adversarial Chaos & Destructive Test Suite Runner
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=================================================="
echo "🔥 Running Adversarial Chaos & Destructive Testing Suite..."
echo "=================================================="

PYTHONPATH="${PROJECT_ROOT}:${PROJECT_ROOT}/src" python3 "${PROJECT_ROOT}/tests/unit/test_destructive_harness.py"

echo "=================================================="
echo "✅ Destructive testing complete. Evidence collected at tests/qa-evidence/destructive_test_report.json"
