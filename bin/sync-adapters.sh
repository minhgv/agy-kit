#!/usr/bin/env bash
# sync-adapters.sh — Sync agent definitions from .antigravity/ (source of truth)
# to all tool adapters (.claude/, .opencode/, .codex/, .cursorrules, .windsurfrules)
#
# Usage: ./bin/sync-adapters.sh
#
# This script regenerates adapter files from the canonical .antigravity/agents/*.json

set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

echo "🔄 Syncing agy-kit adapters from .antigravity/agents/ (source of truth)..."

# Check if python3 is available for JSON parsing
if ! command -v python3 &>/dev/null; then
    echo "❌ python3 required for sync. Install it first."
    exit 1
fi

# --- Cursor & Windsurf: Copy AGENTS.md ---
if [ -f AGENTS.md ]; then
    cp AGENTS.md .cursorrules
    cp AGENTS.md .windsurfrules
    cp AGENTS.md .github/copilot-instructions.md
    echo "  ✅ .cursorrules, .windsurfrules, .github/copilot-instructions.md synced"
fi

# --- Claude Code: Generate .claude/agents/*.md from JSON ---
mkdir -p .claude/agents
python3 -c "
import json, os, glob

agents_dir = '.antigravity/agents'
claude_dir = '.claude/agents'
os.makedirs(claude_dir, exist_ok=True)

for json_file in sorted(glob.glob(f'{agents_dir}/*.json')):
    with open(json_file) as f:
        agent = json.load(f)

    name = agent.get('name', os.path.basename(json_file).replace('.json', ''))
    desc = agent.get('description', '')
    model = agent.get('model', {})
    if isinstance(model, dict):
        model_name = model.get('primary', '')
    else:
        model_name = str(model)
    tools = agent.get('tools', [])
    instructions = agent.get('instructions', [])

    # Map agy model names to Claude model names
    claude_model = model_name
    if 'flash-low' in model_name:
        claude_model = 'claude-haiku-4-20250414'
    elif 'flash-high' in model_name or 'gemini' in model_name:
        claude_model = 'claude-sonnet-4-20250514'

    # Build YAML frontmatter
    tools_yaml = '\n'.join(f'  - {t}' for t in tools) if tools else '  []'

    # Build system prompt from instructions array
    prompt_body = '\n'.join(instructions)

    md = f'''---
name: {name}
description: \"{desc}\"
model: {claude_model}
tools:
{tools_yaml}
---

{prompt_body}
'''
    out_path = os.path.join(claude_dir, f'{name}.md')
    with open(out_path, 'w') as f:
        f.write(md)
    print(f'  ✅ .claude/agents/{name}.md')
"

# --- OpenCode: Generate .opencode/agents.json ---
mkdir -p .opencode
python3 -c "
import json, os, glob

agents_dir = '.antigravity/agents'
agents_list = []

for json_file in sorted(glob.glob(f'{agents_dir}/*.json')):
    with open(json_file) as f:
        agent = json.load(f)

    name = agent.get('name', '')
    model = agent.get('model', {})
    if isinstance(model, dict):
        model_name = model.get('primary', '')
    else:
        model_name = str(model)

    # Map to OpenAI/Anthropic provider format
    if 'flash-low' in model_name:
        oc_model = 'anthropic/claude-haiku-4-20250414'
    elif 'flash-high' in model_name or 'gemini' in model_name:
        oc_model = 'anthropic/claude-sonnet-4-20250514'
    else:
        oc_model = model_name

    instructions = agent.get('instructions', [])
    prompt = ' '.join(instructions)

    agents_list.append({
        'name': name,
        'mode': 'primary' if name in ('planner', 'coder') else 'subagent',
        'description': agent.get('description', ''),
        'model': oc_model,
        'prompt': prompt,
    })

with open('.opencode/agents.json', 'w') as f:
    json.dump({'agents': agents_list}, f, indent=2)
print('  ✅ .opencode/agents.json')
"

# --- Update version.json last_sync timestamp ---
python3 -c "
import json, datetime
path = '.antigravity/version.json'
try:
    with open(path) as f:
        v = json.load(f)
except: v = {}
v['last_sync'] = datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00','Z')
with open(path, 'w') as f:
    json.dump(v, f, indent=2)
print('  ✅ .antigravity/version.json (last_sync updated)')
"

echo ""
echo "✅ Sync complete. All adapters regenerated from .antigravity/agents/."
echo "   Review changes with: git diff"
