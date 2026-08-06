#!/usr/bin/env bash
# validate-agents.sh — Validate subagent JSON specs and AGENTS.md consistency
#
# Usage: ./bin/validate-agents.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

ERRORS=0

log_ok() { echo -e "  [${GREEN}OK${NC}] $1"; }
log_fail() { echo -e "  [${RED}FAIL${NC}] $1"; ERRORS=$((ERRORS + 1)); }

echo "=================================================="
echo "   agy-kit Subagent & Rule Validation Suite      "
echo "=================================================="

AGENTS_DIR=".antigravity/agents"
AGENTS_MD="AGENTS.md"

if [ ! -d "$AGENTS_DIR" ]; then
    log_fail "Directory $AGENTS_DIR does not exist"
    exit 1
fi

REQUIRED_KEYS=("name" "description" "version" "model" "instructions" "tools" "permissions" "input_schema" "output_schema")

# Step 1: Validate each agent JSON file
for json_file in "$AGENTS_DIR"/*.json; do
    [ -e "$json_file" ] || continue
    agent_name=$(basename "$json_file" .json)
    echo ""
    echo "Validating agent spec: $agent_name ($json_file)"
    
    # JSON syntax check
    if ! python3 -c "import json; json.load(open('$json_file'))" &>/dev/null; then
        log_fail "Invalid JSON syntax in $json_file"
        continue
    fi
    
    # Required keys check
    for key in "${REQUIRED_KEYS[@]}"; do
        if ! python3 -c "import json; data=json.load(open('$json_file')); exit(0 if '$key' in data else 1)"; then
            log_fail "Missing required key '$key' in $json_file"
        fi
    done
    
    # Tool permissions validation
    INVALID_TOOL=$(python3 -c "
import json
data = json.load(open('$json_file'))
allowed = {'read_file', 'write_file', 'search_files', 'terminal', 'patch', 'web_search'}
tools = data.get('tools', [])
invalid = [t for t in tools if t not in allowed]
print(invalid[0] if invalid else '')
")
    if [ -n "$INVALID_TOOL" ]; then
        log_fail "Unrecognized tool '$INVALID_TOOL' in $json_file"
    else
        log_ok "Tools permissions validated"
    fi
    
    # Ensure instructions contain prompt leak prevention
    HAS_LEAK_PREVENTION=$(python3 -c "
import json
data = json.load(open('$json_file'))
instructions = ' '.join(data.get('instructions', []))
print('1' if 'PROMPT LEAK PREVENTION' in instructions else '0')
")
    if [ "$HAS_LEAK_PREVENTION" = "1" ]; then
        log_ok "Prompt leak prevention rule present"
    else
        log_fail "Missing 'PROMPT LEAK PREVENTION' rule in instructions for $json_file"
    fi
done

# Step 2: Validate AGENTS.md consistency
echo ""
echo "Validating AGENTS.md consistency:"
if [ -f "$AGENTS_MD" ]; then
    for json_file in "$AGENTS_DIR"/*.json; do
        [ -e "$json_file" ] || continue
        agent_name=$(basename "$json_file" .json)
        if grep -q "\`$agent_name\`" "$AGENTS_MD"; then
            log_ok "Agent '$agent_name' documented in AGENTS.md"
        else
            log_fail "Agent '$agent_name' is missing from AGENTS.md subagent table"
        fi
    done
else
    log_fail "AGENTS.md file not found"
fi

echo ""
echo "=================================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "   Validation Status: ${GREEN}ALL AGENTS PASSED${NC}"
    echo "=================================================="
    exit 0
else
    echo -e "   Validation Status: ${RED}$ERRORS VALIDATION ERRORS FOUND${NC}"
    echo "=================================================="
    exit 1
fi
