---
description: "Run agy-doctor diagnostics — audit system health, CLI version, authentication, subagent specs, skills, MCP servers, and language toolchains."
---

# /doctor

Run environment, subagent, skill, and toolchain diagnostics using `bin/agy-doctor.sh`.

## Steps

### Step 1: Health & System Audit
```bash
./bin/agy-doctor.sh
```

### Step 2: Diagnostic Synthesis & Remediation
Invoke the **`reviewer`** subagent (`.agents/agents/reviewer.md`):
- Review the output of `bin/agy-doctor.sh`.
- If any `[FAIL]` or `[WARN]` items are reported (such as missing language linter, unauthenticated CLI, or missing MCP server), provide step-by-step resolution commands.
