# Project Memory Index

> Session boot loads this index only. Agent reads sub-memory files on-demand per task.

## Memory Layers

| Layer | File/Location | Purpose |
|-------|---------------|---------|
| 1. Core Rules | `AGENTS.md` + `MEMORY.md` | Tech stack, conventions, decisions (auto-loaded) |
| 2. SPEC Archive | `plans/SPEC_*.md` | Technical specs per feature |
| 3. Decisions | `decisions/*.md` | Architecture Decision Records (ADR format) |
| 4. Bug Patterns | `bug-patterns/*.md` | Known bug patterns + fixes |

## How to Use

1. **Session start:** `MEMORY.md` auto-loads — provides project context.
2. **During task:** Agent reads relevant SPEC file and decision records.
3. **Session end:** Extract takeaways → append to `MEMORY.md` Lessons Learned.

## Adding Memory Entries

```bash
# New architecture decision
echo "# ADR-001: Use MoE model routing\n\n## Decision\n..." > decisions/ADR-001-model-routing.md

# New bug pattern
echo "# Bug: gitleaks false positive on test fixtures\n\n## Fix\n..." > bug-patterns/gitleaks-false-positive.md
```

Update this index when adding new memory files.
