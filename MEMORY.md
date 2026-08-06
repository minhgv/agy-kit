# MEMORY.md — agy-kit Project Memory

> Auto-loaded at session start. Stores architectural decisions, conventions, and patterns.

## Tech Stack
- Agent platform: Antigravity CLI (agy) v1.1.0+
- Skills format: SKILL.md (Agent Skills Open Standard)
- CI: GitHub Actions (lint + test + gitleaks + trufflehog)

## Architecture Decisions
- **Sequential Pipeline** as default orchestration (Plan→TDD→Gate→QA→Review)
- **Model Routing:** flash-high for Plan/Code/Review, flash-low for QA (cost optimization)
- **Dual-Constraint Security:** Prompt guidance + Schema-level tool filtering per subagent
- **SPEC-Driven:** Every feature >3 files requires plans/SPEC_*.md before code

## Conventions
- Commits: Conventional Commits (feat:, fix:, test:, docs:, refactor:)
- Test coverage threshold: ≥80% for new code
- Pre-commit hooks: ruff + eslint + gitleaks

## Known Issues & Fixes
- (empty — append as discovered)

## Lessons Learned
- (empty — append at session end)
