---
description: "Initialize agy-kit scaffolding — scaffold AGY-native subagent specs, rules, skills, workflows, and language toolchains into a target repository."
---

# /init

Scaffold `agy-kit` into a target project using `bin/init-agy-kit.sh`.

## Steps

### Step 1: Execute Safe Scaffolding Installer
```bash
./bin/init-agy-kit.sh --target . --lang python
```

### Step 2: Verification & Agent Alignment
Invoke the **`planner`** subagent (`.agents/agents/planner.md`):
- Verify `.agents/` directory structure and `install-manifest.json`.
- Confirm `AGENTS.md` and native Markdown subagent specifications align with the project's primary tech stack.
