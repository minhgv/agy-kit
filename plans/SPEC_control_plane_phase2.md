# SPEC — Python Control Plane Phase 2 Hardening (agy-kit v1.0 Production Readiness)

> Status: Approved  
> Target: agy-kit v1.0  
> Feature: `control-plane-phase2`  
> Reference: `docs/AGY_KIT_IMPROVEMENT_PROPOSAL.md`  

---

## 1. Executive Summary

This feature completes the remaining 30% architectural roadmap from `docs/AGY_KIT_IMPROVEMENT_PROPOSAL.md`. It implements the **AGY Runtime Capability Probe** (fail-closed if subagent discovery fails), **JSONL Event Store** (`.agy-kit/runs/<run_id>/events.jsonl`), **Safe Patch Apply** (`agy-kit apply <run_id>`), **TOML Config Resolver** (`.agy-kit.toml`), and **OS File Locks** (`fcntl.flock`) for concurrent run protection.

---

## 2. Requirements Traceability Matrix (RTM)

| Requirement ID | Type | Priority | Description | Target Component | Test Reference |
|---|---|---|---|---|---|
| R-CP2-001 | Explicit | P0 | Implement AGY Runtime Capability Probe (`probe()`) & fail-closed detection | `src/agy_kit/adapters/agy_cli.py` | `test_r001_capability_probe_fail_closed` |
| R-CP2-002 | Explicit | P0 | Implement JSONL Event Logger (`events.jsonl`) with secret redaction | `src/agy_kit/adapters/filesystem_evidence.py` | `test_r002_jsonl_event_logging` |
| R-CP2-003 | Explicit | P0 | Implement `agy-kit apply <run_id>` with pre-apply `git apply --check` | `src/agy_kit/cli.py` & `worktree.py` | `test_r003_safe_apply_check` |
| R-CP2-004 | Explicit | P1 | Implement TOML Config Resolver for `.agy-kit.toml` | `src/agy_kit/config.py` | `test_r004_config_resolver_precedence` |
| R-CP2-005 | Explicit | P1 | Implement OS File Lock (`fcntl.flock`) to reject duplicate run execution (`run_locked`) | `src/agy_kit/safety/locks.py` | `test_r005_concurrent_run_lock` |

---

## 3. File Mutation Manifest

- `src/agy_kit/config.py` [NEW]
- `src/agy_kit/adapters/agy_cli.py` [NEW]
- `src/agy_kit/adapters/filesystem_evidence.py` [NEW]
- `src/agy_kit/safety/locks.py` [NEW]
- `src/agy_kit/cli.py` [MODIFY]
- `.agy-kit.toml` [NEW]
- `tests/unit/test_control_plane_phase2.py` [NEW]

---

## 4. 12-Dimensional Business Edge Case Matrix (ACM)

| Dimension | Risk Scenario | Mitigation |
|---|---|---|
| Null / Missing | Missing `.agy-kit.toml` | Fallback gracefully to built-in immutable defaults |
| Path Traversal | Apply patch targets file outside allowlisted root | Validate patch filenames against `validate_path_safety` |
| Concurrency Race | 2 CLI instances resume same `run_id` | `RunLock` acquires `fcntl.flock(LOCK_EX | LOCK_NB)` and raises `RunLockedError` |
| Capability Failure | `agy` CLI missing subagent `planner` | Probe fails closed with exit code 10 and actionable error |
| Secret Leak | Secret present in stdout/stderr | Redactor replaces API keys/passwords with `[REDACTED]` before writing to `events.jsonl` |
| Dirty Primary Repo | Primary repo dirty when running `apply` | `apply` fails before mutating primary repo if `git status --porcelain` is not clean |
| Malformed TOML | Invalid syntax in `.agy-kit.toml` | Parser catches syntax error and exits with `exit_code = 2` |

---

## 5. Definition of Done

- All 5 requirements implemented in `src/agy_kit/`.
- `pytest tests/unit/test_control_plane_phase2.py` passes 100%.
- `./bin/validate-traceability.sh` passes with 0 warnings.
