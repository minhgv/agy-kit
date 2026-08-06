#!/usr/bin/env bash
# bin/validate-traceability.sh — agy-kit End-to-End Requirement Traceability Validator
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

log_ok() { echo -e "  [${GREEN}OK${NC}] $1"; }
log_warn() { echo -e "  [${YELLOW}WARN${NC}] $1"; WARNINGS=$((WARNINGS + 1)); }
log_fail() { echo -e "  [${RED}FAIL${NC}] $1"; ERRORS=$((ERRORS + 1)); }

echo "=================================================="
echo -e "   ${BLUE}agy-kit Requirement Traceability Audit${NC}"
echo "=================================================="

# 1. Audit SPEC_TEMPLATE.md
TEMPLATE_FILE="plans/SPEC_TEMPLATE.md"
if [ -f "$TEMPLATE_FILE" ]; then
    echo "Auditing $TEMPLATE_FILE..."
    if grep -q "Requirement Traceability Matrix" "$TEMPLATE_FILE" && grep -q "RTM" "$TEMPLATE_FILE"; then
        log_ok "SPEC_TEMPLATE.md contains Requirement Traceability Matrix (RTM)."
    else
        log_fail "SPEC_TEMPLATE.md missing Requirement Traceability Matrix section!"
    fi

    if grep -q "6-Category Edge Case Matrix" "$TEMPLATE_FILE" || grep -q "Edge Case Matrix" "$TEMPLATE_FILE"; then
        log_ok "SPEC_TEMPLATE.md contains Edge Case Matrix section."
    else
        log_fail "SPEC_TEMPLATE.md missing Edge Case Matrix section!"
    fi

    if grep -q "3-State Verification" "$TEMPLATE_FILE"; then
        log_ok "SPEC_TEMPLATE.md contains 3-State Verification definition."
    else
        log_fail "SPEC_TEMPLATE.md missing 3-State Verification!"
    fi
else
    log_fail "SPEC_TEMPLATE.md not found at plans/SPEC_TEMPLATE.md!"
fi

# 2. Audit Active SPEC files in plans/
SPEC_COUNT=0
for spec in plans/SPEC_*.md; do
    [ -e "$spec" ] || continue
    [ "$spec" == "plans/SPEC_TEMPLATE.md" ] && continue
    SPEC_COUNT=$((SPEC_COUNT + 1))
    echo "Auditing active SPEC: $spec..."
    
    if grep -q "RTM" "$spec" || grep -q "Requirement Traceability Matrix" "$spec"; then
        log_ok "$spec has RTM section."
    else
        log_warn "$spec missing RTM table section."
    fi

    if grep -q "Edge Case" "$spec"; then
        log_ok "$spec has Edge Case section."
    else
        log_warn "$spec missing Edge Case section."
    fi
done

if [ "$SPEC_COUNT" -eq 0 ]; then
    log_ok "No active feature SPECs found in plans/ (template validated cleanly)."
fi

# 3. Audit Framework Documentation
FRAMEWORK_DOC="docs/ba-and-quality-framework.md"
if [ -f "$FRAMEWORK_DOC" ]; then
    echo "Auditing $FRAMEWORK_DOC..."
    if grep -q "Given-When-Then" "$FRAMEWORK_DOC" && grep -q "Confirmed" "$FRAMEWORK_DOC"; then
        log_ok "Framework documentation exists and contains core methodologies."
    else
        log_fail "Framework documentation missing key methodology definitions!"
    fi
else
    log_fail "Framework documentation missing at docs/ba-and-quality-framework.md!"
fi

echo "=================================================="
if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}Traceability Audit Failed with $ERRORS error(s) and $WARNINGS warning(s).${NC}"
    exit 1
else
    echo -e "${GREEN}Traceability Audit Passed Successfully ($WARNINGS warning(s)).${NC}"
    exit 0
fi
