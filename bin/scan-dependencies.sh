#!/usr/bin/env bash
# bin/scan-dependencies.sh — agy-kit Multi-Language Supply Chain Scanner
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
echo -e "   ${BLUE}agy-kit Supply Chain & Slopsquatting Scanner${NC}"
echo "=================================================="

# OWASP-AI-01 Hallucinated / Slopsquatting pattern signatures
SLOPSQUAT_PATTERNS="(fastapi-utils-v2|react-helper-lib|python-crypto|requests-async-v2|langchain-core-plus|flask-utils-v2)"

# Check Python manifest/lock files
PY_FILES=()
for f in requirements.txt pyproject.toml Pipfile.lock poetry.lock; do
    if [ -f "$f" ]; then PY_FILES+=("$f"); fi
done

if [ ${#PY_FILES[@]} -gt 0 ]; then
    echo "Scanning Python dependencies..."
    if grep -iE "$SLOPSQUAT_PATTERNS" "${PY_FILES[@]}" 2>/dev/null; then
        log_fail "OWASP-AI-01 Slopsquatting signature detected in Python dependencies!"
    else
        log_ok "Python dependencies clean of known slopsquatting patterns."
    fi
    
    if [ -f "requirements.txt" ] && grep -E "==\*|>=0\.0\.0" requirements.txt 2>/dev/null; then
        log_warn "Unpinned Python dependency version spec detected."
    fi
else
    log_ok "No Python dependency files found."
fi

# Check Node.js manifest/lock files
NODE_FILES=()
for f in package.json package-lock.json pnpm-lock.yaml yarn.lock; do
    if [ -f "$f" ]; then NODE_FILES+=("$f"); fi
done

if [ ${#NODE_FILES[@]} -gt 0 ]; then
    echo "Scanning Node.js dependencies..."
    if grep -iE "$SLOPSQUAT_PATTERNS" "${NODE_FILES[@]}" 2>/dev/null; then
        log_fail "OWASP-AI-01 Slopsquatting signature detected in Node.js dependencies!"
    else
        log_ok "Node.js dependencies clean."
    fi
else
    log_ok "No Node.js dependency files found."
fi

# Check Go, Rust, PHP lockfiles if present
for lockfile in go.sum go.mod Cargo.lock Cargo.toml composer.lock composer.json; do
    if [ -f "$lockfile" ]; then
        if grep -iE "$SLOPSQUAT_PATTERNS" "$lockfile" 2>/dev/null; then
            log_fail "OWASP-AI-01 Slopsquatting signature detected in $lockfile!"
        else
            log_ok "Verified dependency file: $lockfile"
        fi
    fi
done

echo "=================================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Supply Chain Scan Passed (Warnings: $WARNINGS, Errors: 0)${NC}"
    exit 0
else
    echo -e "${RED}❌ Supply Chain Scan Failed ($ERRORS errors detected)${NC}"
    exit 1
fi
