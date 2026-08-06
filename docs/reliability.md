# System Reliability Operating Manual (Phase 10)

> **Scaffold:** `agy-kit`  
> **Status:** Production Standard

---

## 1. Reliability Principles

1. **Determinism over Cleverness:** Identical inputs MUST yield identical outputs.
2. **Bounded Execution:** Every operation has explicit turn, time, token, and file mutation budgets.
3. **Fail-Safe Defaults:** Ambiguous state triggers auto-rollback, never partial unverified writes.
4. **No Silent Recovery:** All recovery events are logged to `.agy/events.jsonl` and metricized.
5. **Idempotency:** Operations must be idempotent under stable correlation IDs.

## 2. Hard System Limits

| Resource Limit | Cap | Failure Action |
|---|---|---|
| Retries per failing test | **3** | Auto-rollback + escalate |
| Turns per session | **15** | Auto-exit, persist `.agy/session.json` |
| Wall-clock per agent call | **30 min** (1800s) | SIGTERM, dump stack |
| Files modified per turn | **20** | Hard reject |

## 3. Runtime Invariants

- **INV-01:** `git status` clean at agent start and end.
- **INV-02:** Every commit on `main` reproducible from RTM + tests.
- **INV-03:** Zero credentials or secrets in object stores / commits.
- **INV-04:** Correlation ID traced to RTM row on all LLM calls.
- **INV-05:** Append-only signed rollback journal (`.agy/events.jsonl`).
- **INV-06:** Failing tests hard-block commit advancement.
- **INV-07:** Session state persists across turns in `.agy/session.json`.

## 4. Rollback & Recovery Workflow

```
subagent modifies code
        │
        ▼
[checkpoint] git stash push -m "agy:<agent>:<feature>:<ts>"
        │
        ▼
[mutation applied]
        │
        ▼
[test runner] ── PASS ──► keep mutation, advance turn counter
        │
        FAIL
        ▼
[retry ≤ 3] ── PASS ──► keep
        │
        still FAIL
        ▼
[rollback] git stash pop  (or git reset --hard <checkpoint>)
        │
        ▼
[escalate] handoff to planner with diagnostic bundle
```
