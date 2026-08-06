#!/usr/bin/env bash
# validate-agents.sh — Validate subagent JSON specs and AGENTS.md consistency
#
# Usage: ./bin/validate-agents.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "=================================================="
echo "   agy-kit Subagent & Rule Validation Suite      "
echo "=================================================="

python3 - << 'EOF'
import json, glob, sys, os

AGENTS_DIR = ".antigravity/agents"
AGENTS_MD = "AGENTS.md"

if not os.path.isdir(AGENTS_DIR):
    print(f"  [\033[0;31mFAIL\033[0m] Directory {AGENTS_DIR} does not exist")
    sys.exit(1)

if not os.path.isfile(AGENTS_MD):
    print(f"  [\033[0;31mFAIL\033[0m] {AGENTS_MD} file not found")
    sys.exit(1)

with open(AGENTS_MD, "r") as f:
    agents_md = f.read()

required_keys = ["name", "description", "version", "model", "instructions", "tools", "permissions", "input_schema", "output_schema"]
allowed_tools = {"read_file", "write_file", "search_files", "terminal", "patch", "web_search"}

errors = 0
json_files = sorted(glob.glob(os.path.join(AGENTS_DIR, "*.json")))

for json_file in json_files:
    agent_name = os.path.splitext(os.path.basename(json_file))[0]
    print(f"\nValidating agent spec: {agent_name} ({json_file})")
    
    try:
        with open(json_file, "r") as f:
            data = json.load(f)
    except Exception as e:
        print(f"  [\033[0;31mFAIL\033[0m] Invalid JSON syntax in {json_file}: {e}")
        errors += 1
        continue
        
    for key in required_keys:
        if key not in data:
            print(f"  [\033[0;31mFAIL\033[0m] Missing required key '{key}' in {json_file}")
            errors += 1
            
    tools = data.get("tools", [])
    invalid = [t for t in tools if t not in allowed_tools]
    if invalid:
        print(f"  [\033[0;31mFAIL\033[0m] Unrecognized tool '{invalid[0]}' in {json_file}")
        errors += 1
    else:
        print("  [\033[0;32mOK\033[0m] Tools permissions validated")
        
    instructions = " ".join(data.get("instructions", []))
    if "PROMPT LEAK PREVENTION" in instructions:
        print("  [\033[0;32mOK\033[0m] Prompt leak prevention rule present")
    else:
        print(f"  [\033[0;31mFAIL\033[0m] Missing 'PROMPT LEAK PREVENTION' rule in instructions for {json_file}")
        errors += 1

print("\nValidating AGENTS.md consistency:")
for json_file in json_files:
    agent_name = os.path.splitext(os.path.basename(json_file))[0]
    if f"`{agent_name}`" in agents_md:
        print(f"  [\033[0;32mOK\033[0m] Agent '{agent_name}' documented in AGENTS.md")
    else:
        print(f"  [\033[0;31mFAIL\033[0m] Agent '{agent_name}' is missing from AGENTS.md subagent table")
        errors += 1

print("\n==================================================")
if errors == 0:
    print("   Validation Status: \033[0;32mALL AGENTS PASSED\033[0m")
    print("==================================================")
    sys.exit(0)
else:
    print(f"   Validation Status: \033[0;31m{errors} VALIDATION ERRORS FOUND\033[0m")
    print("==================================================")
    sys.exit(1)
EOF
