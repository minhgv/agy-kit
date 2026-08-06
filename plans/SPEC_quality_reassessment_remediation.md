# SPEC — Quality Reassessment Remediation (CI 100% Green & Production Readiness)

> Status: Approved  
> Target: agy-kit v1.0  
> Feature: `quality-reassessment-remediation`  
> Reference: `docs/agy-kit-reassessment-2026-08-06.md`  

---

## 1. Executive Summary

This feature resolves the 4 remaining issues identified in the Hermes Agent Reassessment Report (`docs/agy-kit-reassessment-2026-08-06.md`), bringing `agy-kit` from 7.5/10 to **10/10 Production-Ready (100% Green CI)**:
1. Fix `test_forbidden_paths_detection` in `test_orchestrator.py` to call `validate_path_safety()`.
2. Fix 6 remaining Mypy type annotation errors in `locks.py`, `config.py`, and `worktree.py`.
3. Clean up Ruff lint errors across Python files.
4. Align `eval_harness.py` benchmark assertions with active asset structures.

---

## 2. Requirements Traceability Matrix (RTM)

| Requirement ID | Type | Priority | Description | Target Component | Test Reference |
|---|---|---|---|---|---|
| R-REA-001 | Explicit | P0 | Update `test_forbidden_paths_detection` to call `validate_path_safety()` | `tests/unit/test_orchestrator.py` | `pytest tests/unit/` |
| R-REA-002 | Explicit | P0 | Fix remaining Mypy type errors (`Optional[TextIOWrapper]`, `Optional[str]`, `tomllib`) | `src/agy_kit/` | `mypy src/agy_kit/` |
| R-REA-003 | Explicit | P0 | Fix Ruff lint errors across codebase | `src/agy_kit/` & `tests/` | `ruff check .` |
| R-REA-004 | Explicit | P0 | Fix 4 failing benchmarks in `eval_harness.py` to pass 8/8 benchmarks | `tests/evals/eval_harness.py` | `python3 tests/evals/eval_harness.py` |

---

## 3. File Mutation Manifest

- `tests/unit/test_orchestrator.py` [MODIFY]
- `src/agy_kit/safety/locks.py` [MODIFY]
- `src/agy_kit/config.py` [MODIFY]
- `src/agy_kit/worktree.py` [MODIFY]
- `tests/evals/eval_harness.py` [MODIFY]

---

## 4. 12-Dimensional Business Edge Case Matrix (ACM)

| Dimension | Risk Scenario | Mitigation |
|---|---|---|
| Test Discrepancy | Unit test uses inline logic instead of actual validator | Test calls `validate_path_safety()` directly |
| Type Safety | Mypy raises error for `None` assigned to `TextIOWrapper` | Annotate attribute as `file_obj: Optional[TextIOWrapper] = None` |
| Benchmark Drift | `eval_harness.py` looks for outdated template file layout | Update benchmark paths to reflect `src/templates/skills/` |
| Lint Failures | CI fails due to unsorted imports | Apply `ruff check . --fix` and format checks |

---

## 5. Definition of Done & 3-State Verification

- `pytest tests/unit/` passes **25/25 tests (0 failed)**.
- `mypy src/agy_kit/` reports **0 errors**.
- `ruff check .` reports **0 errors**.
- `python3 tests/evals/eval_harness.py` passes **8/8 benchmarks (100/100 score)**.
- `.github/workflows/ci.yml` passes 100%.
