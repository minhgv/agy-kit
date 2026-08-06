#!/usr/bin/env bash
# check-path-boundaries.sh — Multi-agent Workspace Isolation & Path Enforcement
#
# Usage: ./bin/check-path-boundaries.sh [--stage STAGE]

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

STAGE="all"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --stage)
            STAGE="$2"
            shift 2
            ;;
        *)
            STAGE="$1"
            shift 1
            ;;
    esac
done

ERRORS=0

log_ok() { echo -e "  [${GREEN}OK${NC}] $1"; }
log_fail() { echo -e "  [${RED}FAIL${NC}] $1"; ERRORS=$((ERRORS + 1)); }

echo "=================================================="
echo -e "   ${BLUE}agy-kit Multi-Agent Workspace Boundary Check${NC}"
echo "=================================================="
echo ""

# Get list of modified and untracked files
MODIFIED_FILES=$(git status --porcelain | awk '{print $2}')

if [ -z "$MODIFIED_FILES" ]; then
    log_ok "No modified files detected in workspace."
    echo "=================================================="
    exit 0
fi

# Forbidden global patterns
FORBIDDEN_PATTERNS="^\.env$|^\.ssh/|^/etc/|^\.git/"

for file in $MODIFIED_FILES; do
    if echo "$file" | grep -qE "$FORBIDDEN_PATTERNS"; then
        log_fail "CRITICAL: Modification detected on forbidden path: $file"
    else
        log_ok "Path within safe boundary: $file"
    fi
done

# Stage-specific checks
if [ "$STAGE" = "coder" ]; then
    for file in $MODIFIED_FILES; do
        if echo "$file" | grep -qE "^\.antigravity/agents/"; then
            log_fail "ROLE VIOLATION: Coder agent modified agent prompt spec: $file"
        fi
    done
fi

echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All workspace path boundaries verified successfully!${NC}"
    echo "=================================================="
    exit 0
else
    echo -e "${RED}❌ Workspace boundary violation detected! ($ERRORS errors)${NC}"
    echo "=================================================="
    exit 1
fi
