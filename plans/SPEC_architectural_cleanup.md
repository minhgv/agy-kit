# SPEC — Architectural Cleanup, Secure Worktrees & Coverage Hardening (agy-kit v1.0 Final Polish)

> Status: Approved  
> Target: agy-kit v1.0  
> Feature: `architectural-cleanup`  
> Reference: `docs/agy-kit-quality-assessment-2026-08-06.md`  

---

## 1. Executive Summary

This feature completes the 4 long-term architectural optimization items from `docs/agy-kit-quality-assessment-2026-08-06.md`:
1. **Triplet Mirroring Cleanup**: Removes 101 duplicate committed files by making `.agents/` canonical and generating `.antigravity/` / `.hermes/` dynamically via `init-agy-kit.sh` / `sync_templates.py`.
2. **Secure Worktree Allocation**: Replaces hardcoded `/tmp/` paths in `src/agy_kit/worktree.py` with `tempfile.mkdtemp(prefix="agy-wt-")`.
3. **Safety & Worktree Unit Test Coverage**: Achieves ≥ 80% coverage for `locks.py`, `worktree.py`, and `cli.py`.
4. **Documentation Archival**: Moves historical phase specs to `docs/archive/` and canonicalizes documentation.

---

## 2. Requirements Traceability Matrix (RTM)

| Requirement ID | Type | Priority | Description | Target Component | Test Reference |
|---|---|---|---|---|---|
| R-CLN-001 | Explicit | P1 | Dynamic mirroring of `.antigravity/` and `.hermes/` via `sync_templates.py` / `init-agy-kit.sh` | `bin/sync_templates.py` & `bin/init-agy-kit.sh` | `test_r001_dynamic_mirror_generation` |
| R-CLN-002 | Explicit | P1 | Secure temporary worktree directory creation using `tempfile.mkdtemp()` | `src/agy_kit/worktree.py` | `test_r002_secure_tempfile_worktree` |
| R-CLN-003 | Explicit | P1 | Increase test coverage for `locks.py`, `worktree.py`, and `cli.py` to ≥ 80% | `tests/unit/test_safety_and_worktree.py` | `pytest tests/unit/` |
| R-CLN-004 | Explicit | P2 | Archive historical phase documentation files into `docs/archive/` | `docs/` | Directory structure check |

---

## 3. File Mutation Manifest

- `src/agy_kit/worktree.py` [MODIFY]
- `bin/sync_templates.py` [MODIFY]
- `bin/init-agy-kit.sh` [MODIFY]
- `tests/unit/test_safety_and_worktree.py` [NEW]
- `docs/archive/` [NEW DIRECTORY]

---

## 4. 12-Dimensional Business Edge Case Matrix (ACM)

| Dimension | Risk Scenario | Mitigation |
|---|---|---|
| Symlink Attack | Malicious pre-created symlink in `/tmp/agy-wt-*` | `tempfile.mkdtemp()` creates uniquely named directory with `0700` OS permissions |
| Orphaned Worktree | Worktree directory remains after process crash | `remove_worktree()` safely cleans up directory and prunes git worktrees |
| Template Drift | `.antigravity/` missing when CLI loaded | `init-agy-kit.sh` and `sync_templates.py` auto-generate `.antigravity/` mirror if missing |
| Race Condition | OS lock file release fails on non-existent file | `locks.py` handles missing lock files gracefully during `release()` |

---

## 5. Definition of Done & 3-State Verification

- `tempfile.mkdtemp()` used in `worktree.py`.
- `test_safety_and_worktree.py` passes 100%.
- `python3 bin/sync_templates.py --check` passes with 0 template drift.
- `./bin/validate-traceability.sh` passes with 0 warnings.
