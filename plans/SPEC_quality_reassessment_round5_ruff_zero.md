# SPEC — Quality Reassessment Round 5: Zero Ruff Errors & 100% Format Compliance

> Status: Approved  
> Target: agy-kit v1.0  
> Feature: `quality-reassessment-round5-ruff-zero`  
> Reference: `docs/agy-kit-reassessment-round5-2026-08-06.md` Section 2.2  

---

## 1. Executive Summary & Problem Diagnosis

The Round 5 Reassessment Report (`docs/agy-kit-reassessment-round5-2026-08-06.md`) confirms that `mypy` errors are at **0** and pytest suite is **25/25 PASS**. However, 72 Ruff style errors and 34 unformatted files remain. This specification details the systematic cleanup to achieve **0 Ruff errors, 0 Ruff warnings, and 100% Ruff format compliance**.

---

## 2. Requirements Traceability Matrix (RTM)

| Requirement ID | Type | Priority | Description | Target Component | Test Reference |
|---|---|---|---|---|---|
| R-R5-001 | Explicit | P0 | Apply `ruff check . --fix --unsafe-fixes` for UP006/UP035/FA100 annotations (22 errors) | All Python files | `ruff check .` |
| R-R5-002 | Explicit | P0 | Format all Python files using `ruff format .` (34 unformatted files) | All Python files | `ruff format --check .` |
| R-R5-003 | Explicit | P0 | Prefix unused unpacked variables (`RUF059`) in `eval_harness.py` with `_` (24 errors) | `tests/evals/eval_harness.py` | `ruff check .` |
| R-R5-004 | Explicit | P0 | Add `check=False` to `subprocess.run` (`PLW1510`) in test runners (8 errors) | `tests/evals/*.py` | `ruff check .` |
| R-R5-005 | Explicit | P0 | Add `# noqa: BLE001, S110` or proper logging to try-except blocks (13 errors) | `tests/unit/*.py` | `ruff check .` |
| R-R5-006 | Explicit | P0 | Fix timezone (`DTZ005`), unused noqa (`RUF100`), file context (`SIM115`), and shebang (`EXE001`) (5 errors) | Workspace Python files | `ruff check .` |
| R-R5-007 | Explicit | P0 | Synchronize active assets and verify 100% zero template drift | `src/templates/` | `python3 bin/sync_templates.py --check` |

---

## 3. User Stories & Behavioral Acceptance Criteria (BDD / Gherkin Matrix)

#### Story US-R5: Zero Linter Warning Codebase
- **As a** `Developer / CI Engine`
- **I want** `ruff check . and ruff format --check . to return 0 errors`
- **So that** `CI Quality Gate passes 100% without noise or style warnings`

##### Happy Path Scenario
- **Given** clean workspace **When** `ruff check .` is executed **Then** returns exit code 0 with message `All checks passed!`.

---

## 4. File Mutation Manifest

- `tests/evals/eval_harness.py` [MODIFY]
- `tests/evals/meta_eval_harness.py` [MODIFY]
- `tests/evals/export_telemetry_summary.py` [MODIFY]
- `tests/unit/*.py` [MODIFY]
- `src/agy_kit/**/*.py` [MODIFY]
- `src/templates/` [SYNC]

---

## 5. 12-Dimensional Business Edge Case Matrix (ACM)

| Dimension | Risk Scenario | Mitigation |
|---|---|---|
| Linter Noise | Unused variables (`RUF059`) cause CI failure | Prefix unpacked variables with `_` |
| Style Drift | Python files unformatted | `ruff format .` formats all 34 files deterministically |
| Template Drift | Active asset updates break `src/templates/` | `sync_templates.py --sync` auto-syncs updated assets |

---

## 6. Definition of Done & 3-State Verification

- `ruff check .` returns **0 errors**.
- `ruff format --check .` returns **0 files to reformat**.
- `mypy src/agy_kit/ --ignore-missing-imports` returns **0 errors**.
- `pytest tests/unit/` passes **25/25 tests**.
- `python3 bin/sync_templates.py --check` passes **100% Zero Drift**.
