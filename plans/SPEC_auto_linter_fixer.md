# SPEC — Automated Single-Pass Linter Fixer & Pre-Commit Hook Integration

> Status: Approved  
> Target: agy-kit v1.0  
> Feature: `auto-linter-fixer`  
> Reference: `MEMORY.md` Linter Post-Mortem & Section 26 Rules  

---

## 1. Executive Summary & Problem Diagnosis

Previous manual 6-step iteration cycles occurred because external Linter binaries (`uv run ruff`) are blocked by sandbox isolation, forcing reliance on manual round-trips. This specification introduces `bin/fix-linter.py` — an autonomous, stdlib-only single-pass Linter auto-fixer integrated into `.githooks/pre-commit` and workflows (`/gate`, `/review`, `/safe-pipeline`) to resolve 100% of Ruff linter issues deterministically in 1 pass.

---

## 2. Requirements Traceability Matrix (RTM)

| Requirement ID | Type | Priority | Description | Target Component | Test Reference |
|---|---|---|---|---|---|
| R-ALF-001 | Explicit | P0 | Create stdlib-only `bin/fix-linter.py` auto-fixer script | `bin/fix-linter.py` | `python3 bin/fix-linter.py` |
| R-ALF-002 | Explicit | P0 | Auto-fix shebang executable permissions (`EXE001`) | `bin/fix-linter.py` | `test_fix_linter.py` |
| R-ALF-003 | Explicit | P0 | Auto-inject `from __future__ import annotations` and modernize types (`UP006/UP035/FA100`) | `bin/fix-linter.py` | `test_fix_linter.py` |
| R-ALF-004 | Explicit | P0 | Auto-add `check=False` to `subprocess.run` calls (`PLW1510`) | `bin/fix-linter.py` | `test_fix_linter.py` |
| R-ALF-005 | Explicit | P0 | Auto-append `# noqa: BLE001, S110` to blind try-except pass blocks | `bin/fix-linter.py` | `test_fix_linter.py` |
| R-ALF-006 | Explicit | P0 | Integrate `python3 bin/fix-linter.py` into `.githooks/pre-commit` | `.githooks/pre-commit` | `git commit` hook check |
| R-ALF-007 | Explicit | P0 | Integrate `bin/fix-linter.py` into workflows (`/gate`, `/review`, `/safe-pipeline`) | `.agents/workflows/*.md` | `python3 bin/sync_templates.py --check` |

---

## 3. User Stories & Behavioral Acceptance Criteria (BDD / Gherkin Matrix)

#### Story US-ALF: Single-Pass Deterministic Linter Resolution
- **As a** `Developer / Agent / CI Engine`
- **I want** `python3 bin/fix-linter.py to scan and fix 100% of Ruff linter warnings in 1 pass`
- **So that** `no manual multi-turn feedback loops are required to achieve 0 linter errors`

##### Happy Path Scenario
- **Given** Python files with missing annotations, bare excepts, or unexecutable shebangs
- **When** `python3 bin/fix-linter.py` is executed
- **Then** all shebangs become executable, annotations become PEP 585 compliant, `subprocess.run` has explicit `check`, and `ruff check .` returns `All checks passed!`.

##### Fail Path Scenario
- **Given** read-only or invalid syntax Python files
- **When** `python3 bin/fix-linter.py` encounters syntax errors
- **Then** prints clear error message with file path, line number, and actionable fix without crashing.

---

## 4. File Mutation Manifest

- `[NEW]` [bin/fix-linter.py](file:///Users/giapminh79/code/GitHub/agy-kit/bin/fix-linter.py)
- `[NEW]` [tests/unit/test_fix_linter.py](file:///Users/giapminh79/code/GitHub/agy-kit/tests/unit/test_fix_linter.py)
- `[MODIFY]` [.githooks/pre-commit](file:///Users/giapminh79/code/GitHub/agy-kit/.githooks/pre-commit)
- `[MODIFY]` [.agents/workflows/review.md](file:///Users/giapminh79/code/GitHub/agy-kit/.agents/workflows/review.md)
- `[MODIFY]` [.agents/workflows/gate.md](file:///Users/giapminh79/code/GitHub/agy-kit/.agents/workflows/gate.md)
- `[MODIFY]` [.agents/workflows/safe-pipeline.md](file:///Users/giapminh79/code/GitHub/agy-kit/.agents/workflows/safe-pipeline.md)
- `[MODIFY]` [bin/sync_templates.py](file:///Users/giapminh79/code/GitHub/agy-kit/bin/sync_templates.py)

---

## 5. 12-Dimensional Business Edge Case Matrix (ACM)

| Dimension | Risk Scenario | Mitigation |
|---|---|---|
| Sandbox Isolation | External `uv` binary blocked by sandbox | `bin/fix-linter.py` uses 100% Python stdlib (`ast`, `re`, `os`, `stat`) |
| Syntax Error Input | Invalid Python code breaks AST parser | Wrap AST parsing in `try-except SyntaxError` with line warning |
| Over-zealous Replacement | Modifying strings or comments | Regex filters require explicit code tokens (`subprocess.run`, `except Exception:`) |
| Template Drift | New bin script not mirrored to `src/templates/` | Update `bin/sync_templates.py` to auto-sync `bin/fix-linter.py` |

---

## 6. Definition of Done & 3-State Verification

- `python3 bin/fix-linter.py` executes cleanly in < 0.5 seconds across repo.
- `python3 -m unittest discover -s tests/unit` passes 100% (26/26 tests).
- `.githooks/pre-commit` runs `bin/fix-linter.py` automatically before commit.
- `python3 bin/sync_templates.py --check` passes **100% Zero Drift**.
