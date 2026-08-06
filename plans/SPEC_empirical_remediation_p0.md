# SPEC — Empirical Verification Failure Remediation (P0 Hotfix)

> Status: Approved  
> Target: agy-kit v1.0  
> Feature: `empirical-remediation-p0`  
> Reference: Empirical Test Audit Findings (2026-08-06)  

---

## 1. Executive Summary & Problem Diagnosis

Empirical test execution identified 3 critical execution bugs:
1. `make validate` (`bin/validate-workflows-sync.sh:199`): Fails with `SCRIPT_DIR: unbound variable` under `set -u`.
2. `test_fix_linter.py`: Fails with `ImportError: cannot import name 'fix_except_pass'` from `bin/fix_linter.py`.
3. `bin/agy-doctor.sh`: Fails with `Status: FAILED (4 errors)` because it checks legacy `.antigravity/agents/*.json` instead of AGY 2.0 native `.agents/agents/*.md` Markdown subagent specs.

This specification details the P0 hotfixes to achieve 100/100 benchmark execution and zero empirical errors.

---

## 2. Requirements Traceability Matrix (RTM)

| Requirement ID | Type | Priority | Description | Target Component | Test Reference |
|---|---|---|---|---|---|
| R-P0-001 | Explicit | P0 | Define `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` in `bin/validate-workflows-sync.sh` | `bin/validate-workflows-sync.sh` | `make validate` |
| R-P0-002 | Explicit | P0 | Restore `fix_except_pass(content: str) -> str` in `bin/fix_linter.py` | `bin/fix_linter.py` | `python3 tests/unit/test_fix_linter.py` |
| R-P0-003 | Explicit | P0 | Update `bin/agy-doctor.sh` to scan `.agents/agents/*.md` Markdown specs | `bin/agy-doctor.sh` | `./bin/agy-doctor.sh` |
| R-P0-004 | Explicit | P0 | Synchronize updated bin scripts to `src/templates/` with 0 drift | `src/templates/` | `python3 bin/sync_templates.py --check` |
| R-P0-005 | Explicit | P0 | Verify `eval_harness.py` achieves 100/100 across all 16 benchmarks | `tests/evals/eval_harness.py` | `python3 tests/evals/eval_harness.py` |

---

## 3. User Stories & Behavioral Acceptance Criteria (BDD / Gherkin Matrix)

#### Story US-P0: Zero Empirical Test Failure
- **As a** `Developer / CI Engine`
- **I want** `make validate, unit tests, and ./bin/agy-doctor.sh to pass with 0 errors`
- **So that** `the entire evaluation harness reaches 100/100 benchmark score`

##### Happy Path Scenario
- **Given** updated scripts
- **When** `make validate` and `./bin/agy-doctor.sh` are executed
- **Then** `make validate` completes with exit code 0 and `agy-doctor` reports `System status: HEALTHY (0 errors)`.

---

## 4. File Mutation Manifest

- `[MODIFY]` [bin/validate-workflows-sync.sh](file:///Users/giapminh79/code/GitHub/agy-kit/bin/validate-workflows-sync.sh)
- `[MODIFY]` [bin/fix_linter.py](file:///Users/giapminh79/code/GitHub/agy-kit/bin/fix_linter.py)
- `[MODIFY]` [bin/agy-doctor.sh](file:///Users/giapminh79/code/GitHub/agy-kit/bin/agy-doctor.sh)
- `[SYNC]` [src/templates/](file:///Users/giapminh79/code/GitHub/agy-kit/src/templates/)

---

## 5. 12-Dimensional Business Edge Case Matrix (ACM)

| Dimension | Risk Scenario | Mitigation |
|---|---|---|
| Unbound Bash Variable | `set -u` halts script on missing variable | Define `SCRIPT_DIR` at file top before any usage |
| Missing Import symbol | `ImportError` in unit tests | Export `fix_except_pass` function in `bin/fix_linter.py` |
| Spec Schema Mismatch | Doctor script scans deprecated JSON format | Update doctor script to scan AGY 2.0 `.agents/agents/*.md` Markdown format |

---

## 6. Definition of Done & 3-State Verification

- `make validate` completes with exit code 0.
- `python3 tests/unit/test_fix_linter.py` passes 100%.
- `./bin/agy-doctor.sh` returns `System status: HEALTHY (0 errors)`.
- `python3 tests/evals/eval_harness.py` returns `ALL 16 BENCHMARKS PASSED (100/100)`.
- `python3 bin/sync_templates.py --check` passes **100% Zero Drift**.
