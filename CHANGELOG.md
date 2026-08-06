# agy-kit — Changelog

## [0.7.0] — 2026-08-06 (Phase 13 — Release Polish & Documentation)

### Added
- **Architect-Executor Model Routing:** Configured `zai/glm-5.2` for deep reasoning (`planner`, `reviewer`) and `gemini-3.6-flash-high` for high-throughput execution (`coder`, `qa`).
- **Complete 9 Skills Suite:** Added and synchronized `tdd-workflow`, `quality-gate`, `ba-expert`, `qa-auditor`, `qa-test-gen`, `qa-reproducer`, `brainstorming`, `grill-me`, and `problem-solving` skills across `.hermes/skills/` and `.antigravity/skills/`.
- **Complete 9 Slash Workflows:** Added native slash commands `/pipeline`, `/plan`, `/gate`, `/review`, `/qa`, `/safe-pipeline`, `/brainstorm`, `/grill`, `/solve` under `.antigravity/workflows/`.
- **10 Executable Automation Scripts:** Added `agy-pipeline.sh`, `safe-agent-run.sh`, `agy-doctor.sh`, `validate-agents.sh`, `check-path-boundaries.sh`, `synthesize-skill.sh`, `scan-dependencies.sh`, `validate-traceability.sh`, `validate-workflows-sync.sh`, `validate-brainstorm-skills.sh` under `bin/`.
- **13-Benchmark Evaluation Harness:** Upgraded `tests/evals/eval_harness.py` to run 13 automated benchmarks achieving 100/100 pass score.

### Summary of Phases 6–13 Progress
- **Phase 6 (Workspace Isolation):** Multi-agent path boundary verification script (`check-path-boundaries.sh`) and path scoping rules.
- **Phase 7 (Supply Chain Security):** OWASP-AI-01 dependency vulnerability and slopsquatting scanner (`scan-dependencies.sh`).
- **Phase 8 (Telemetry & Tracing):** OpenTelemetry exporter (`export_telemetry_summary.py`) and token/cost metrics reporting.
- **Phase 9 (Skill Auto-Synthesis):** Automated skill artifact synthesis protocol script (`synthesize-skill.sh`).
- **Phase 10 (BA & Quality Framework):** Full Business Analysis core, 12-Dimensional Edge Matrix (ACM), Requirements Traceability Matrix (RTM), and Quality Framework documentation (`docs/ba-and-quality-framework.md`, `docs/business-analysis.md`, `docs/quality-framework.md`, `docs/reliability.md`).
- **Phase 11 (Workflows Sync):** 100% alignment verification script for workflows, subagent specs, and skills (`validate-workflows-sync.sh`).
- **Phase 12 (Ideation & Problem Solving):** Integrated `brainstorming` (4-category unknowns), `grill-me` (11-question plan stress testing), and `problem-solving` (5 techniques with 7 reference guides).
- **Phase 13 (Release & Documentation Polish):** Updated version tracking to v0.7.0, overhauled `README.md`, updated `CHANGELOG.md`, verified 13/13 evals pass (100/100).

### Changed
- `.antigravity/version.json` — Updated to `0.7.0` targeting Antigravity CLI (`agy >= 1.1.0`).
- `README.md` — Overhauled to document Antigravity CLI focus, model routing, skills, workflows, scripts, and evaluation harness.

## [0.6.0] — 2026-08-06 (Phase 5 — Antigravity Native Deep Optimization)

### Added
- `docs/opentelemetry-tracing.md` — OpenTelemetry (OTLP) tracing setup, GenAI semantic attributes, and span visualizer guide for `agy`
- `tests/evals/eval_harness.py` — Local subagent evaluation harness measuring Pass@1 TDD rate, SPEC compliance, and token cost
- Pure Antigravity CLI scaffold focus — removed legacy cross-tool adapters (`.claude/`, `.opencode/`, `.codex/`, `.cursorrules`, `.windsurfrules`)

### Changed
- `.antigravity/version.json` — Updated to v0.6.0 with `target_platform: Antigravity CLI (agy)`
- `README.md` — Updated to focus 100% exclusively on Antigravity CLI (`agy`)

## [0.5.0] — 2026-08-06 (Phase 4 — Production Polish)

### Added
- `.claude/agents/*.md` — Claude Code adapter (4 agents: planner, coder, reviewer, qa)
- `.opencode/agents.json` — OpenCode adapter (4 agents in single JSON)
- `.codex/agents/*.toml` — Codex CLI adapter (4 agents, TOML format with sandbox_mode)
- `.cursorrules` — Cursor IDE project rules adapter
- `.windsurfrules` — Windsurf IDE project rules adapter
- `.github/copilot-instructions.md` — GitHub Copilot adapter
- `.antigravity/version.json` — Scaffold version tracking (semver + compatible CLI range)
- `bin/sync-adapters.sh` — Auto-generate all tool adapters from `.antigravity/agents/` (source of truth)
- `docs/cross-tool-compat.md` — Full compatibility matrix (7 tools) + customization patterns
- `docs/upgrade-guide.md` — Semver policy, non-destructive merge, migration guides, layered AGENTS.md
- `docs/meta-testing.md` — 3-layer testing: deterministic meta-tests, trajectory evals, prompt regression
- `CONTRIBUTING.md` — Contribution guide + semver rules
- `LICENSE` — MIT

### Architecture Decision
- **Canonical Spec + Sync CLI** model (from ECC pattern): `.antigravity/agents/*.json` is the single source of truth. `bin/sync-adapters.sh` regenerates all tool adapters.
- **Layered AGENTS.md:** root → subfolder → file-level inheritance for monorepo.

### Tool Compatibility
| Tool | Status |
|------|--------|
| Antigravity CLI (agy) | ✅ Native |
| Claude Code | ✅ Adapter |
| OpenCode | ✅ Adapter |
| Cursor | ✅ Adapter |
| Windsurf | ✅ Adapter |
| Codex CLI | ✅ Uses AGENTS.md |
| GitHub Copilot | ✅ Adapter |

## [0.4.0] — 2026-08-06 (Phase 3 Research Applied)

### Added
- `docs/multi-language-adapters.md` — 5 languages (Python, Go, Rust, PHP, Node/TS) with toolchain matrix + monorepo support
- `docs/rollback-recovery.md` — Git checkpoint, auto-rollback, loop prevention, token budget, session crash recovery
- `bin/safe-agent-run.sh` — Run agy stage with auto-rollback safety net (auto-detect test runner)
- `.antigravity/workflows/safe-pipeline.md` — Rollback-aware pipeline workflow (6 slash commands total)
- `examples/SPEC_user_registration_example.md` — Complete sample SPEC for REST API
- `examples/python_fastapi_config_example/` — Config Python/FastAPI subagents
- `examples/error_recovery_scenario.md` — Error recovery demo (test fail → agent fix)
- `examples/parallel_review_workflow.md` — Scatter-gather 3 reviewers (security, performance, style)
- `examples/getting_started_tutorial.md` — Tutorial from zero → first feature

### Changed
- `AGENTS.md` — Added Section 7 (Rollback & Recovery Safety) + Section 8 (Multi-Language Support)

### Research Sources (Phase 3)
- Multi-language toolchain adapters (ruff, golangci-lint, clippy, phpstan, eslint/biome)
- Monorepo patterns (hierarchical context scoping, path boundary isolation, turbo/nx filter)
- Token budget management (soft cap 75-80%, hard cap 100%, max_turns=15, 4-stage compression)
- Transactional rollback (git checkpoint, auto-rollback on test fail, clean slate retry)
- Enterprise case studies (Replit 3→20 engineers, McKinsey 40% PR uplift, narrow-scoped subagents +88% merge rate)

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
