# SPEC — Quality Assessment Remediation & CI Hardening (agy-kit v1.0 Production Readiness)

> Status: Approved  
> Target: agy-kit v1.0  
> Feature: `quality-assessment-remediation`  
> Reference: `docs/agy-kit-quality-assessment-2026-08-06.md`  

---

## 1. Executive Summary

This feature resolves all 5 Critical blocking defects and 5 High-priority issues identified in the Hermes Agent Quality Assessment Report (`docs/agy-kit-quality-assessment-2026-08-06.md`), bringing `agy-kit` from 6.5/10 (technical alpha) to a **10/10 Production-Ready Agent Harness Scaffold**.

---

## 2. Requirements Traceability Matrix (RTM)

| Requirement ID | Type | Priority | Description | Target Component | Test Reference |
|---|---|---|---|---|---|
| R-QA-001 | Explicit | P0 | Fix `RunLock.acquire(self)` missing `self` parameter in `locks.py` | `src/agy_kit/safety/locks.py` | `test_r005_concurrent_run_lock` |
| R-QA-002 | Explicit | P0 | Fix `validate_path_safety` to reject whitespace-only and absolute paths (`/etc/passwd`) | `src/agy_kit/validators.py` | `test_attack_1_boundary_edge_bombardment` |
| R-QA-003 | Explicit | P0 | Fix Ruff lint errors (unsorted imports, unused imports, type annotations) across `src/` and `tests/` | `src/agy_kit/` & `tests/` | `ruff check .` |
| R-QA-004 | Explicit | P0 | Fix mypy static type errors across `src/agy_kit/` | `src/agy_kit/` | `mypy src/agy_kit/` |
| R-QA-005 | Explicit | P0 | Update `.github/workflows/ci.yml` to run `pytest`, `mypy`, `ruff check`, and `ruff format` | `.github/workflows/ci.yml` | CI execution |
| R-QA-006 | Explicit | P1 | Synchronize all workflows and agent specs between `.agents/` and `.antigravity/` | `.antigravity/workflows/` | `python3 bin/sync_templates.py --check` |
| R-QA-007 | Explicit | P1 | Fix state machine transition matrix in `orchestrator.py` for flexible pipeline stages | `src/agy_kit/orchestrator.py` | `test_attack_2_concurrency_race_conditions` |
| R-QA-008 | Implicit | P1 | Achieve 100% pass rate across unit, destructive, and hybrid test suites | `tests/unit/` | `pytest tests/unit/` |

---

## 3. File Mutation Manifest

- `src/agy_kit/safety/locks.py` [MODIFY]
- `src/agy_kit/validators.py` [MODIFY]
- `src/agy_kit/orchestrator.py` [MODIFY]
- `src/agy_kit/config.py` [MODIFY]
- `src/agy_kit/worktree.py` [MODIFY]
- `src/agy_kit/cli.py` [MODIFY]
- `.github/workflows/ci.yml` [MODIFY]
- `.antigravity/workflows/pipeline.md` [MODIFY]
- `tests/unit/test_control_plane_phase2.py` [MODIFY]
- `tests/unit/test_destructive_harness.py` [MODIFY]

---

## 4. 12-Dimensional Business Edge Case Matrix (ACM)

| Dimension | Risk Scenario | Mitigation |
|---|---|---|
| Null / Missing | `locks.py` `acquire()` called on instance without `self` | Signature updated to `def acquire(self) -> bool:` |
| Path Traversal | Whitespace-only string (`'   '`) or absolute path (`/etc/passwd`) | Explicit `.strip()` and `os.path.isabs()` check before canonical root evaluation |
| Type Error | mypy type redefinition (`tomllib = None`) | Type annotation `tomllib: Any = None` |
| State Transition | Stage transition `CREATED → ISOLATED` or `CREATED → BUILT` rejected | Allow initial transition flexibility for custom pipeline subsets |
| CI Bypass | PR merged with failing pytest suite | Mandatory `pytest`, `mypy`, and `ruff` steps added to `.github/workflows/ci.yml` |
| Workflow Drift | `.agents/workflows/pipeline.md` differs from `.antigravity/workflows/pipeline.md` | Synchronize `.antigravity/` workflows to match `.agents/` |

---

## 5. Definition of Done & 3-State Verification

- `pytest tests/unit/` passes **100% (0 failed, 0 skipped)**.
- `ruff check .` reports **0 errors**.
- `mypy src/agy_kit/` reports **0 errors**.
- `python3 bin/sync_templates.py --check` passes with **0 template drift**.
- `.github/workflows/ci.yml` updated with full test and quality gates.
