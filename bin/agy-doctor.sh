#!/usr/bin/env bash
# agy-doctor.sh — Environment & Subagent Health Diagnostics for agy-kit
#
# Usage: ./bin/agy-doctor.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

log_ok() { echo -e "  [${GREEN}OK${NC}] $1"; }
log_warn() { echo -e "  [${YELLOW}WARN${NC}] $1"; WARNINGS=$((WARNINGS + 1)); }
log_fail() { echo -e "  [${RED}FAIL${NC}] $1"; ERRORS=$((ERRORS + 1)); }

echo "=================================================="
echo -e "   ${BLUE}agy-kit System Health Diagnostics (agy-doctor)${NC}"
echo "=================================================="
echo ""

# Check 1: CLI Availability
echo "1. Checking CLI & Tools Availability:"
if command -v agy &>/dev/null; then
    log_ok "Antigravity CLI (agy) is installed: $(agy --version 2>/dev/null || echo 'present')"
else
    log_warn "Antigravity CLI (agy) not found in PATH (mock/fallback mode active)"
fi

if command -v git &>/dev/null; then
    log_ok "git is installed: $(git --version)"
else
    log_fail "git is not installed"
fi

# Check 2: Runtime Environments
echo ""
echo "2. Checking Language Runtimes:"
if command -v python3 &>/dev/null; then
    PY_VER=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    log_ok "Python 3 version: $PY_VER"
else
    log_fail "Python 3 is not installed"
fi

if command -v node &>/dev/null; then
    NODE_VER=$(node -v)
    log_ok "Node.js version: $NODE_VER"
else
    log_warn "Node.js not installed (optional for Python-only workflows)"
fi

# Check 3: Repository Setup & Git Hooks
echo ""
echo "3. Checking Repository Setup & Git Configuration:"
if git rev-parse --is-inside-work-tree &>/dev/null; then
    log_ok "Valid Git repository detected"
else
    log_fail "Current directory is not a Git repository"
fi

if [ -f "AGENTS.md" ]; then
    log_ok "AGENTS.md project rules file present"
else
    log_fail "AGENTS.md is missing from repository root"
fi

if [ -f "GEMINI.md" ]; then
    log_ok "GEMINI.md model routing overrides present"
else
    log_warn "GEMINI.md is missing from repository root"
fi

# Check 4: Subagent JSON Specs Validity
echo ""
echo "4. Checking Subagent Declarative Specs (.antigravity/agents/*.json):"
AGENT_FILES=(planner.json coder.json reviewer.json qa.json)
for agent_file in "${AGENT_FILES[@]}"; do
    FILE_PATH=".antigravity/agents/$agent_file"
    if [ -f "$FILE_PATH" ]; then
        if python3 -c "import json; json.load(open('$FILE_PATH'))" &>/dev/null; then
            log_ok "Subagent spec $agent_file is valid JSON"
        else
            log_fail "Subagent spec $agent_file has invalid JSON syntax"
        fi
    else
        log_fail "Subagent spec $agent_file missing at $FILE_PATH"
    fi
done

# Check 5: MCP Configuration Check
echo ""
echo "5. Checking MCP Server Configuration:"
if [ -f ".antigravity/mcp.json" ]; then
    if python3 -c "import json; json.load(open('.antigravity/mcp.json'))" &>/dev/null; then
        log_ok ".antigravity/mcp.json is present and valid JSON"
    else
        log_fail ".antigravity/mcp.json has invalid JSON syntax"
    fi
else
    log_warn ".antigravity/mcp.json not found"
fi

# Check 6: Security Scan Tools
echo ""
echo "6. Checking Security & Audit Tooling:"
if command -v gitleaks &>/dev/null; then
    log_ok "gitleaks secret scanner installed"
elif command -v trufflehog &>/dev/null; then
    log_ok "trufflehog secret scanner installed"
else
    log_warn "Neither gitleaks nor trufflehog installed (fallback to git diff grep pattern)"
fi

echo ""
echo "=================================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "   Status: ${GREEN}PASSED${NC} ($WARNINGS warnings)"
    echo "=================================================="
    exit 0
else
    echo -e "   Status: ${RED}FAILED${NC} ($ERRORS errors, $WARNINGS warnings)"
    echo "=================================================="
    exit 1
fi
