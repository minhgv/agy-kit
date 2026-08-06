#!/usr/bin/env bash
# bin/verify-eval-harness.sh — agy-kit Phase 18 Harness Meta-Evaluation & Fault Injection Verification Tool
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=================================================="
echo -e "   ${BLUE}agy-kit Meta-Evaluation & Fault Injection Suite${NC}"
echo "=================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_ROOT}"

if python3 tests/evals/meta_eval_harness.py; then
    echo ""
    echo -e "${GREEN}✅ Harness Meta-Evaluation & Fault Injection Verification Passed!${NC}"
    echo "=================================================="
    exit 0
else
    echo ""
    echo -e "${RED}❌ Harness Meta-Evaluation & Fault Injection Verification Failed!${NC}"
    echo "=================================================="
    exit 1
fi
