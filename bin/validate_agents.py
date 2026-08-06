#!/usr/bin/env python3
"""
validate_agents.py — Validate native subagent Markdown specs (.agents/agents/*.md) and AGENTS.md consistency
"""
from __future__ import annotations

import glob
import os
import sys

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
AGENTS_DIR = os.path.join(PROJECT_ROOT, ".agents/agents")
AGENTS_MD = os.path.join(PROJECT_ROOT, "AGENTS.md")

print("==================================================")
print("   agy-kit Subagent & Rule Validation Suite      ")
print("==================================================")

if not os.path.isdir(AGENTS_DIR):
    print(f"  [\033[0;31mFAIL\033[0m] Directory {AGENTS_DIR} does not exist")
    sys.exit(1)

if not os.path.isfile(AGENTS_MD):
    print(f"  [\033[0;31mFAIL\033[0m] {AGENTS_MD} file not found")
    sys.exit(1)

with open(AGENTS_MD, "r", encoding="utf-8") as f:
    agents_md = f.read()

required_frontmatter_keys = ["name", "description", "tools", "mainAgent", "subagent", "model", "commandExecutionPolicy"]
allowed_tools = {"read_file", "write_file", "search_files", "run_command", "patch", "web_search", "terminal"}
allowed_models = {"inherit", "flash", "pro", "gemini-3.6-flash-high", "gemini-3.6-flash-low"}

def parse_frontmatter(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    if not content.startswith("---"):
        return None, "Missing YAML frontmatter starting marker '---'"
    parts = content.split("---", 2)
    if len(parts) < 3:
        return None, "Malformed YAML frontmatter delimiters"
    
    yaml_text = parts[1]
    data = {}
    current_key = None
    
    for line in yaml_text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if ":" in line and not line.startswith("-"):
            key, val = line.split(":", 1)
            key = key.strip()
            val = val.strip()
            if val.startswith("[") and val.endswith("]"):
                val = [x.strip(" '\"") for x in val[1:-1].split(",") if x.strip()]
            elif val.lower() == "true":
                val = True
            elif val.lower() == "false":
                val = False
            elif not val:
                val = []
            data[key] = val
            current_key = key
        elif line.startswith("-") and current_key:
            val = line[1:].strip().strip("'\"")
            if isinstance(data.get(current_key), list):
                data[current_key].append(val)
            else:
                data[current_key] = [val]
                
    return data, None

errors = 0
md_files = sorted(glob.glob(os.path.join(AGENTS_DIR, "*.md")))

if not md_files:
    print(f"  [\033[0;31mFAIL\033[0m] No Markdown agent files found in {AGENTS_DIR}")
    sys.exit(1)

for md_file in md_files:
    agent_name = os.path.splitext(os.path.basename(md_file))[0]
    print(f"\nValidating native agent spec: {agent_name} ({os.path.basename(md_file)})")
    
    data, err = parse_frontmatter(md_file)
    if err:
        print(f"  [\033[0;31mFAIL\033[0m] {err} in {md_file}")
        errors += 1
        continue
        
    for key in required_frontmatter_keys:
        if key not in data:
            print(f"  [\033[0;31mFAIL\033[0m] Missing required frontmatter key '{key}' in {md_file}")
            errors += 1
            
    tools = data.get("tools", [])
    if isinstance(tools, list):
        invalid = [t for t in tools if t not in allowed_tools]
        if invalid:
            print(f"  [\033[0;31mFAIL\033[0m] Unrecognized tool '{invalid[0]}' in {md_file}")
            errors += 1
        else:
            print("  [\033[0;32mOK\033[0m] Tools permissions validated")
            
    model = data.get("model")
    if model not in allowed_models:
        print(f"  [\033[0;31mFAIL\033[0m] Model tier '{model}' invalid in {md_file} (must be inherit, flash, or pro)")
        errors += 1
    else:
        print(f"  [\033[0;32mOK\033[0m] Model tier '{model}' validated")

print("\nValidating AGENTS.md consistency:")
for md_file in md_files:
    agent_name = os.path.splitext(os.path.basename(md_file))[0]
    if f"`{agent_name}`" in agents_md or agent_name in agents_md:
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
