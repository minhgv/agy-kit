# Task Breakdown: PRD v1.0 agy-kit & Hybrid src/ Directory Architecture

## Phase 0: Stop False-Positive Release Claims & Fix Meta-Eval
- [x] 0.1 Update README, docs, and metrics to mark release experimental / qualify 100/100 claims
- [x] 0.2 Make generated evaluation reports non-authoritative output artifacts
- [x] 0.3 Fix meta-eval fault injection regression (`tests/evals/meta_eval_harness.py`)
- [x] 0.4 Verify `make verify-eval` pass rate (5/5 fault injections)

## Phase 1: AGY-Native Contract Migration
- [x] 1.1 Migrate custom agent definitions from JSON to `.agents/agents/<name>.md` with YAML frontmatter
- [x] 1.2 Audit and clean out unsupported CLI flags (`agy run`, `--agent`, `--auto-approve`) across docs, Makefile, scripts, workflows
- [x] 1.3 Canonicalize `.agents/skills` and `.agents/mcp_config.json`
- [x] 1.4 Rewrite workflows in `.agents/workflows/` to adhere strictly to AGY slash workflow contract
- [x] 1.5 Add capability detection and agent discovery validation (`bin/validate-agents.sh`)

## Phase 2: Safe Orchestrator & Worktree Isolation
- [x] 2.1 Implement typed state machine (`CREATED` -> `PREFLIGHT` -> ... -> `COMPLETED`)
- [x] 2.2 Implement Git worktree isolation in `bin/safe-agent-run.sh` / Python orchestrator
- [x] 2.3 Implement path canonicalization and boundary checks (`bin/check-path-boundaries.sh`)
- [x] 2.4 Enforce pre/post mutation manifests for coder/QA stages
- [x] 2.5 Ensure safe permission mode default (sandbox/review) and require protected opt-in for unsafe mode

## Phase 3: Independent Test & Evaluation System
- [x] 3.1 Build deterministic Fake AGY executable for mock CLI behavior testing
- [x] 3.2 Add comprehensive test suite: Unit, Shell, Contract, Integration, Mutation tests
- [x] 3.3 Overhaul benchmark scoring to report observed metrics (`not_collected` instead of synthetic hardcoded values)
- [x] 3.4 Create structured JSON schemas for stage results (`agy-kit/schemas/stage-result.schema.json`)

## Phase 4: Live Compatibility & Five-Language Proof
- [x] 4.1 Implement/verify 5 language adapters and test fixtures (Python, TypeScript, Go, Rust, PHP)
- [x] 4.2 Set up protected real-AGY smoke test suite
- [x] 4.3 Generate compatibility matrix and evidence checksums

## Phase 5: v1.0 Release Hardening & Hybrid `src/` Layout
- [x] 5.1 Implement safe non-destructive installer with `--dry-run` and backup recovery
- [x] 5.2 Build executable documentation verification runner
- [x] 5.3 Generate SBOM, release provenance, migration guide, and final 10/10 rubric verification
- [x] 5.4 Create `src/templates/` directory holding project scaffolding assets (`AGENTS.md.tpl`, `mcp_config.json.tpl`, native Markdown agents)
- [x] 5.5 Create `src/agy_kit/` Python module (`orchestrator.py`, `worktree.py`, `validators.py`, `cli.py`)
- [x] 5.6 Refactor `bin/init-agy-kit.sh` to copy scaffold assets from `src/templates/`
