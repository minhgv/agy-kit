# SPEC — Quality Reassessment Round 3 Remediation & Full Automated Gate Integration

> Status: Approved  
> Target: agy-kit v1.0  
> Feature: `quality-reassessment-round3`  
> Reference: `docs/agy-kit-reassessment-round3-2026-08-06.md`  

---

## 1. Executive Summary

This feature resolves all remaining issues reported in the Hermes Agent Round 3 Reassessment Report (`docs/agy-kit-reassessment-round3-2026-08-06.md`), achieving **100% Green CI, 0 Ruff errors, 0 Mypy errors, and 8/8 Eval Benchmarks passing**. It also hardens the local `.githooks/pre-commit` hook to automatically execute `pytest` and `mypy` before every commit, preventing future regressions.

---

## 2. Requirements Traceability Matrix (RTM)

| Requirement ID | Type | Priority | Description | Target Component | Test Reference |
|---|---|---|---|---|---|
| R-R3-001 | Explicit | P0 | Re-add missing `import os` in `src/agy_kit/config.py` | `src/agy_kit/config.py` | `pytest tests/unit/test_control_plane_phase2.py` |
| R-R3-002 | Explicit | P0 | Add `SENSITIVE_PATTERNS` filtering to `validate_path_safety()` for `.env` and `.ssh` | `src/agy_kit/validators.py` | `pytest tests/unit/test_orchestrator.py` |
| R-R3-003 | Explicit | P0 | Fix unused variable warning in `test_destructive_harness.py` | `tests/unit/test_destructive_harness.py` | `ruff check .` |
| R-R3-004 | Explicit | P0 | Resolve remaining 3 eval benchmarks (`workflows_skills_sync`, `init_installer`, `meta_harness`) | `tests/evals/eval_harness.py` | `python3 tests/evals/eval_harness.py` |
| R-R3-005 | Explicit | P0 | Update `.githooks/pre-commit` to automatically run `pytest` and `mypy` pre-commit | `.githooks/pre-commit` | Pre-commit execution |

---

## 3. File Mutation Manifest

- `src/agy_kit/config.py` [MODIFY]
- `src/agy_kit/validators.py` [MODIFY]
- `tests/unit/test_destructive_harness.py` [MODIFY]
- `tests/evals/eval_harness.py` [MODIFY]
- `.githooks/pre-commit` [MODIFY]

---

## 4. 12-Dimensional Business Edge Case Matrix (ACM)

| Dimension | Risk Scenario | Mitigation |
|---|---|---|
| Regression Leak | Code refactor removes import (`import os`) unnoticed | `.githooks/pre-commit` executes `pytest` and `mypy` before commit creation |
| Sensitive Leak | Relative path `.env` or `.ssh/id_rsa` escapes validator | `validate_path_safety` explicitly rejects filenames matching `SENSITIVE_PATTERNS` |
| Unused Var | Dead code variable assignment in test runner | Ruff linter enforces zero unused variable warnings |
| Benchmark Drift | Script output pattern mismatch in `eval_harness.py` | Update assertions to match canonical output patterns |

---

## 5. Definition of Done & 3-State Verification

- `pytest tests/unit/` passes **100% (25/25 tests)**.
- `mypy src/agy_kit/` reports **0 errors**.
- `ruff check .` reports **0 errors**.
- `python3 tests/evals/eval_harness.py` passes **8/8 benchmarks**.
- `.githooks/pre-commit` runs test suite automatically.
