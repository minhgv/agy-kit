#!/usr/bin/env bash
# bin/synthesize-skill.sh — agy-kit Skill Auto-Synthesis CLI
set -euo pipefail

SKILL_NAME=""
CATEGORY="general"
DESCRIPTION="Auto-synthesized skill by agy subagent"
CONTEXT_FILE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --name) SKILL_NAME="$2"; shift 2 ;;
    --category) CATEGORY="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --context) CONTEXT_FILE="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [ -z "$SKILL_NAME" ]; then
  echo "Error: --name is required"
  exit 1
fi

if [[ ! "$SKILL_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Error: Invalid skill name '$SKILL_NAME'. Must match ^[a-zA-Z0-9_-]+$"
  exit 1
fi

TARGET_DIR=".hermes/skills/${SKILL_NAME}"
mkdir -p "$TARGET_DIR"
SKILL_FILE="${TARGET_DIR}/SKILL.md"

CONTEXT_CONTENT=""
if [ -n "$CONTEXT_FILE" ] && [ -f "$CONTEXT_FILE" ]; then
  CONTEXT_CONTENT=$(cat "$CONTEXT_FILE")
elif [ -n "$CONTEXT_FILE" ]; then
  CONTEXT_CONTENT="$CONTEXT_FILE"
fi

cat <<EOF > "$SKILL_FILE"
---
name: ${SKILL_NAME}
description: ${DESCRIPTION}
category: ${CATEGORY}
tags: [auto-synthesized, agy-kit]
version: 1.0.0
author: agy-subagent
---

# ${SKILL_NAME}

## Overview & Trigger Conditions
${DESCRIPTION}

## Step-by-Step Workflow
1. Inspect target environment and state files.
2. Apply changes adhering to SPEC and TDD rules.
3. Validate through automated test suites.

${CONTEXT_CONTENT}

## Pitfalls & Guardrails
- Avoid out-of-boundary file edits.
- Ensure dependency security scan passes.

## Verification Commands
\`\`\`bash
make validate
make check-boundaries
\`\`\`
EOF

# Make any scripts in scripts/ executable if directory exists
if [ -d "${TARGET_DIR}/scripts" ]; then
  chmod +x "${TARGET_DIR}/scripts"/* 2>/dev/null || true
fi

# Dual/Triple compatibility mirroring (.hermes, .antigravity, .agents)
mkdir -p .antigravity/skills/
rm -rf ".antigravity/skills/${SKILL_NAME}"
cp -r "$TARGET_DIR" .antigravity/skills/

mkdir -p .agents/skills/
rm -rf ".agents/skills/${SKILL_NAME}"
cp -r "$TARGET_DIR" .agents/skills/

# Validation check
if [ ! -f "$SKILL_FILE" ] || ! grep -q "^---" "$SKILL_FILE" || ! grep -q "^## Overview & Trigger Conditions" "$SKILL_FILE"; then
  echo "Error: Synthesized skill failed schema validation"
  exit 1
fi

echo "✅ Successfully synthesized skill: ${SKILL_NAME} at ${SKILL_FILE}"
