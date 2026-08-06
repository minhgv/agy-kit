# SPEC — Hybrid `src/` Directory Architecture for agy-kit

> Status: Approved  
> Target: agy-kit v1.0  
> Feature: `src-hybrid`  

## 1. Executive Summary

This feature restructures `agy-kit` to include a clean `src/` directory separating installer target scaffolding assets (`src/templates/`) from the core Python orchestration package (`src/agy_kit/`).

## 2. Requirements Traceability Matrix (RTM)

| Requirement ID | Type | Priority | Description | Target Component | Test Reference |
|---|---|---|---|---|---|
| R-SRC-001 | Explicit | P0 | Create `src/templates/` with canonical scaffold assets (`AGENTS.md.tpl`, `mcp_config.json.tpl`, `version.json.tpl`, `agents/*.md`) | `src/templates/` | `test_templates_exist` |
| R-SRC-002 | Explicit | P0 | Create `src/agy_kit/` Python module (`orchestrator.py`, `worktree.py`, `validators.py`, `cli.py`) | `src/agy_kit/` | `test_agy_kit_import` |
| R-SRC-003 | Explicit | P0 | Refactor `bin/init-agy-kit.sh` to load scaffold assets from `src/templates/` | `bin/init-agy-kit.sh` | `test_init_installer_templates` |
| R-SRC-004 | Implicit | P1 | Ensure path safety validation (`realpath`) on template copying | `src/agy_kit/validators.py` | `test_validator_traversal` |

## 3. File Mutation Manifest

- `src/templates/AGENTS.md.tpl` [NEW]
- `src/templates/mcp_config.json.tpl` [NEW]
- `src/templates/version.json.tpl` [NEW]
- `src/templates/agents/planner.md` [NEW]
- `src/templates/agents/coder.md` [NEW]
- `src/templates/agents/reviewer.md` [NEW]
- `src/templates/agents/qa.md` [NEW]
- `src/agy_kit/__init__.py` [NEW]
- `src/agy_kit/orchestrator.py` [NEW]
- `src/agy_kit/worktree.py` [NEW]
- `src/agy_kit/validators.py` [NEW]
- `src/agy_kit/cli.py` [NEW]
- `bin/init-agy-kit.sh` [MODIFY]
- `tests/unit/test_src_hybrid.py` [NEW]

## 4. 12-Dimensional Business Edge Case Matrix (ACM)

| Dimension | Risk Scenario | Mitigation |
|---|---|---|
| Null/Missing | `src/templates/` directory missing when `init-agy-kit.sh` runs | Fallback to embedded default templates |
| Path Traversal | Symlink or `../` in template output target | Canonical path boundary validation via `realpath` |
| Schema Drift | `src/templates/agents/*.md` out of sync with `.agents/agents/*.md` | Automated sync check in `validate-workflows-sync.sh` |

## 5. Definition of Done

- All files created under `src/templates/` and `src/agy_kit/`.
- `pytest tests/unit/test_src_hybrid.py` passes 100%.
- `bin/init-agy-kit.sh` successfully scaffolds from `src/templates/`.
