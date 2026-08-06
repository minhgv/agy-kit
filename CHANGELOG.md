# agy-kit — Changelog

## [0.2.0] — 2026-08-06 (Phase 1 Research Applied)

### Added
- `.antigravity/mcp.json` — MCP server config (filesystem, github, playwright, sqlite)
- `.pre-commit-config.yaml` — Git pre-commit hooks (ruff, eslint, gitleaks)
- `.gitleaks.toml` — Custom secret scanning rules (API key, JWT secret, private key)
- `.github/workflows/ci.yml` — CI pipeline (lint + test + Gitleaks + TruffleHog)
- `docs/orchestration-patterns.md` — Sequential, Parallel, Hub-Spoke, Nexus patterns
- `docs/model-routing.md` — Model routing matrix + cost optimization + OpenTelemetry
- `docs/owasp-ai-checklist.md` — 5-item OWASP security checklist for AI code

### Changed
- Subagent JSON schema upgraded to v1.1 — added model routing (primary/fallback/temperature), permissions (output_files, read_only_paths, allowed_commands), context_window isolation, input/output schemas
- QA agent switched to gemini-3.6-flash-low for cost optimization (~75-80% token savings)
- Reviewer agent enhanced with OWASP-AI 5-item security checklist
- README.md updated with MCP integration, safety hooks table, model routing summary

### Research Sources
- 7 community scaffolds analyzed: ECC (238K stars), spec-kit (125K), claude-mem (89K), agent-skills (82K), oh-my-codex (32K), claude-code-templates (30K), agentrules-architect
- Declarative subagent schema patterns (dual-constraint tool filtering, CVE-2026-22708 lesson)
- Multi-agent orchestration patterns (Anthropic "Building Effective Agents")
- OpenTelemetry GenAI semantic conventions (5 core agent spans)

## [0.1.0] — 2026-08-06

### Added
- Initial scaffold: AGENTS.md, GEMINI.md
- 4 declarative subagents: planner, coder, reviewer, qa (v1.0 schema)
- 2 reusable skills: tdd-workflow, quality-gate
- README.md with 5-step workflow guide
