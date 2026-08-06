# agy-kit — Changelog

## [0.3.0] — 2026-08-06 (Phase 2 Research Applied)

### Added
- `plans/SPEC_TEMPLATE.md` — 7-section SPEC template (Exec Summary, Architecture, Schema, File Manifest, Test Plan, Migration, Definition of Done)
- `.antigravity/workflows/` — 5 slash command workflows: `/pipeline`, `/plan`, `/gate`, `/review`, `/qa`
- `Makefile` — chain agy commands: `make pipeline FEATURE=xxx`
- `bin/agy-pipeline.sh` — headless CI runner with `--auto-approve` flag
- `MEMORY.md` — persistent project memory (tech stack, decisions, conventions)
- `.githooks/pre-commit` — gitleaks + pre-commit framework enforcement
- `.githooks/commit-msg` — Conventional Commits format validation
- `docs/prompt-engineering.md` — 6 prompt patterns: Architect/Editor split, error recovery, self-reflection (3-state verification), anti-hallucination, few-shot XML format, reasoning model guidance
- `docs/memory-guide.md` — 4-layer memory architecture (core rules, SPEC archive, decisions, bug patterns)

### Research Sources (Phase 2)
- Anthropic Claude Code system prompts (Architect/Editor split, 3-state verification)
- Aider AI prompt patterns (file content grounding, edit block format, anti-lazy/overeager)
- SWE-agent error recovery and loop-breaking patterns
- GitHub spec-kit SDD workflow (spec→plan→tasks→code)
- Antigravity CLI workflow definitions (turbo mode, slash commands)

## [0.2.0] — 2026-08-06 (Phase 1 Research Applied)

### Added
- `.antigravity/mcp.json` — MCP server config (filesystem, github, playwright, sqlite)
- `.pre-commit-config.yaml` — Git pre-commit hooks (ruff, eslint, gitleaks)
- `.gitleaks.toml` — Custom secret scanning rules
- `.github/workflows/ci.yml` — CI pipeline (lint + test + Gitleaks + TruffleHog)
- `docs/orchestration-patterns.md`, `docs/model-routing.md`, `docs/owasp-ai-checklist.md`

### Changed
- Subagent JSON schema upgraded to v1.1 (model routing, permissions, context_window, input/output schemas)
- QA agent: flash-low for cost optimization; Reviewer: OWASP-AI 5-item checklist

## [0.1.0] — 2026-08-06

### Added
- Initial scaffold: AGENTS.md, GEMINI.md, 4 subagents (v1.0), 2 skills (tdd-workflow, quality-gate), README
