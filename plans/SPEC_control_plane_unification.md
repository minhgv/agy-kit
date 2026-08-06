# SPEC — Python Control Plane Unification & Packaging (agy-kit v1.0 Production Hardening)

> Status: Approved  
> Target: agy-kit v1.0  
> Feature: `control-plane-unification`  
> Reference: `docs/AGY_KIT_IMPROVEMENT_PROPOSAL.md`  

---

## 1. Executive Summary

This feature unifies the `agy-kit` execution layer into a single **Modular Monolith Python Control Plane** (`src/agy_kit/`), making `agy-kit run <feature>` the canonical entrypoint. It packages `agy-kit` via `pyproject.toml`, enforces strict JSON execution contracts (`run-manifest.schema.json`, `stage-result.schema.json`), guarantees primary repository worktree immutability (`mktemp -d` -> `git worktree add`), and validates 100% template synchronization without drift.

---

## 2. Requirements Traceability Matrix (RTM)

| Requirement ID | Type | Priority | Description | Target Component | Test Reference |
|---|---|---|---|---|---|
| R-CP-001 | Explicit | P0 | Package `agy-kit` using standard `pyproject.toml` with console script entrypoint `agy-kit` | `pyproject.toml` | `test_pyproject_installation` |
| R-CP-002 | Explicit | P0 | Implement `agy-kit` CLI commands (`doctor`, `run`, `status`, `apply`, `clean`, `verify`, `sync`, `version`) | `src/agy_kit/cli.py` | `test_cli_commands` |
| R-CP-003 | Explicit | P0 | Enforce `StageState` machine transitions with strict transition guards | `src/agy_kit/orchestrator.py` | `test_illegal_state_transition_rejected` |
| R-CP-004 | Explicit | P0 | Enforce isolated Git worktree execution & primary worktree immutability | `src/agy_kit/worktree.py` | `test_primary_worktree_immutability` |
| R-CP-005 | Explicit | P0 | Validate JSON execution contracts against schema (`run-manifest`, `stage-result`) | `src/agy_kit/models/` & `schemas/` | `test_stage_result_schema_validation` |
| R-CP-006 | Explicit | P1 | Implement capability probe for AGY runtime & subagent discovery | `src/agy_kit/validators.py` | `test_agy_capability_probe` |
| R-CP-007 | Explicit | P1 | Maintain zero template drift via `bin/sync_templates.py --check` | `bin/sync_templates.py` | `test_sync_templates_zero_drift` |
| R-CP-008 | Implicit | P1 | Redact secrets and private paths in execution events (`events.jsonl`) | `src/agy_kit/validators.py` | `test_event_redaction` |

---

## 3. File Mutation Manifest

- `pyproject.toml` [NEW]
- `src/agy_kit/__init__.py` [MODIFY]
- `src/agy_kit/cli.py` [MODIFY]
- `src/agy_kit/orchestrator.py` [MODIFY]
- `src/agy_kit/worktree.py` [MODIFY]
- `src/agy_kit/validators.py` [MODIFY]
- `src/agy_kit/models/run.py` [NEW]
- `src/agy_kit/models/stage.py` [NEW]
- `Makefile` [MODIFY]
- `tests/unit/test_control_plane.py` [NEW]

---

## 4. 12-Dimensional Business Edge Case Matrix (ACM)

| Dimension | Risk Scenario | Mitigation |
|---|---|---|
| Null / Missing | `run_id` or `baseline_commit` is null | Validate ULID generation and git rev-parse HEAD before stage execution |
| Path Traversal | Malicious path escape (`../../../etc/passwd`) | Strict canonical path validation via `os.path.realpath` against allowlisted root |
| Illegal State Jump | State transition from `CREATED` directly to `COMPLETED` | Throw `IllegalTransitionError` and block event |
| Concurrency Race | Multiple processes resume the same `run_id` | Acquire OS file lock (`fcntl.flock`) on run lockfile |
| Schema Drift | Stage result JSON missing required fields | Validate with `jsonschema` against `stage-result.schema.json` |
| Unsafe Permissions | Invocation uses `--dangerously-skip-permissions` | Reject unsafe mode in standard execution profile; enforce sandbox mode |
| Hardcoded Telemetry | Hardcoding token/cost values | Report `not_collected` if raw telemetry unavailable |
| Dirty Primary Repo | User has uncommitted changes during `apply` | Pre-check primary status with `git apply --check` before applying patch |
| Signal Interruption | `SIGINT` / `SIGTERM` received mid-run | Signal handler catches interrupt, sets state `CANCELLED`, cleans worktree safely |
| Resource Leak | Temporary worktrees left in `/tmp` | Implement idempotent cleanup and `agy-kit clean <run_id>` |
| Tenant / Scope Leak | File mutation outside specified manifest | Stage mutation guard inspects git diff and fails stage if unmanifested file changed |
| Flaky Retries | Assertion failure masked by retry | Set default retry to 0 for assertion/security failures; record retry attempts explicitly |

---

## 5. Non-Functional Requirements (NFR)

- **Latency**: CLI preflight & capability probe completes in < 300ms.
- **Throughput**: Support 100+ concurrent state transitions without state corruption.
- **Coverage**: Core orchestrator line coverage >= 90%, branch coverage >= 85%. Safety/worktree branch coverage = 100%.

---

## 6. Data Flow Diagram (DFD)

```text
[User / CLI] ──(1. agy-kit run)──> [cli.py] ──(2. resolve config & probe)──> [validators.py]
                                       │
                                (3. init run)
                                       ▼
                             [orchestrator.py] ──(4. create worktree)──> [worktree.py]
                                       │                                       │
                                (5. execute stage)                     (isolated /tmp)
                                       ▼                                       ▼
                               [AGY Runtime] ──(6. validate schema)──> [schemas/*.json]
                                       │
                                (7. emit events)
                                       ▼
                             [events.jsonl / patch]
```

---

## 7. Definition of Done & 3-State Verification

- `pip install -e .` successfully installs `agy-kit` CLI.
- `agy-kit run --help` and `agy-kit doctor` execute without error.
- All unit, contract, and destructive tests pass 100% (`pytest tests/unit/test_control_plane.py`).
- Primary worktree remains 100% untouched during failed runs.
