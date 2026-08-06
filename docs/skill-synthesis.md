# Skill Auto-Synthesis Protocol & Standard

> Guidelines and procedures for subagents to automatically capture, structure, validate, and persist reusable multi-step resolution procedures into `.hermes/skills/` and `.antigravity/skills/`.

## 1. Skill Lifecycle Architecture

```
[Execution History] ──► [Synthesis Trigger] ──► [bin/synthesize-skill.sh] ──► [.hermes/skills/<name>/SKILL.md]
                                                                        └──► [.antigravity/skills/<name>/SKILL.md]
```

Subagent sessions are stateless by default; once an execution turn finishes, operational insights, complex debugging solutions, and custom integrations evaporate. The Skill Auto-Synthesis Protocol bridges this gap by persisting learned procedural memory.

## 2. Auto-Synthesis Trigger Conditions

A subagent MUST synthesize a new skill when any of the following conditions are met:
1. **Multi-Turn Resolution:** Complex tasks requiring 5+ tool execution turns.
2. **Failure Recovery:** Successful resolution of a previously failing test runner loop or tricky environment error.
3. **Custom Tooling Integration:** Setup and orchestration of non-trivial third-party tools, MCP servers, or project scripts.
4. **Explicit Request:** User or architect explicitly requests persisting a workflow.

## 3. Standardized SKILL.md Template & Schema

Every synthesized skill must adhere to the following schema:

```markdown
---
name: skill-name-in-kebab-case
description: Short trigger description explaining when to use this skill.
category: devops
tags: [auto-synthesized, agy-kit]
version: 1.0.0
author: agy-subagent
---

# skill-name-in-kebab-case

## Overview & Trigger Conditions
High-level summary of the skill and precise trigger conditions.

## Step-by-Step Workflow
1. Clear, actionable step 1.
2. Clear, actionable step 2.
3. Clear, actionable step 3.

## Pitfalls & Guardrails
- Known failure modes and how to avoid them.
- Safety boundaries (e.g., path isolation, unpinned dependencies).

## Verification Commands
\`\`\`bash
# Executable verification commands
make validate
\`\`\`
```

### Mandatory Frontmatter Fields
- `name`: Lowercase kebab-case string (max 64 chars).
- `description`: Self-contained trigger condition and short behavior overview.
- `category`: Domain grouping (e.g. `devops`, `testing`, `security`, `frontend`, `backend`).
- `tags`: List of descriptive tags including `auto-synthesized`.
- `version`: Semantic version string.
- `author`: `agy-subagent` or author string.

## 4. Actionable Steps vs. Vague Advice

| ❌ Vague Advice (Avoid) | ✅ Actionable Procedure (Required) |
|-----------------------|------------------------------------|
| "Check dependencies before building." | "Run `bin/scan-dependencies.sh` to check for OWASP-AI-01 slopsquatting." |
| "Fix test errors if any occur." | "Execute `npm test` and inspect `stderr` logs for exit code non-zero." |
| "Ensure code style is clean." | "Run `make gate` and verify zero linter and typecheck warnings." |

## 5. Verification & Reloading Procedure

Synthesized skills must be verified by:
1. Confirming `.hermes/skills/<skill-name>/SKILL.md` exists and contains non-empty frontmatter and body sections.
2. Confirming dual-compatibility mirror `.antigravity/skills/<skill-name>/SKILL.md` exists.
3. Executing verification commands specified in the skill file.
