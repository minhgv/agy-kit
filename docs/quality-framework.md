# Quality Framework Operating Manual (Phase 10)

> **Scaffold:** `agy-kit`  
> **Skill References:** `qa-auditor`, `qa-test-gen`, `qa-reproducer`  
> **Status:** Production Standard

---

## 1. Concentric Quality Layers (L1–L5)

`agy-kit` organizes quality into 5 concentric layers:

```
┌──────────────────────────────────────────────────┐
│ L5  Release Quality       → reviewer + human     │
│  └ L4  E2E / System        → qa                  │
│     └ L3  Integration      → coder               │
│        └ L2  Unit / Contract → coder             │
│           └ L1  Static Analysis → CI / hooks     │
└──────────────────────────────────────────────────┘
```

- **L1 Static Analysis:** Linter (0 errors, 0 warnings), strict typechecking, secret scan clean.
- **L2 Unit / Contract Tests:** One test file per public unit, RED phase evidence under `tests/red/<feature>.log`, ≥85% line and ≥70% branch coverage.
- **L3 Integration Tests:** Verification of agent boundary contracts.
- **L4 End-to-End (E2E):** cURL / Playwright dogfooding scenarios mapped to RTM IDs executed by `qa` subagent.
- **L5 Release Quality:** Sign-off by `reviewer` subagent with RTM closure verification.

## 2. Test-Driven Development (TDD) Protocol

1. **RED Evidence:** `coder` appends failing test output to `tests/red/<feature>.log` before writing business logic.
2. **GREEN Evidence:** `coder` updates log with passing output after minimal logic implementation.
3. **REFACTOR Gate:** `coder` refactors for SOLID principles & DRY compliance while maintaining green tests.
4. **Coverage Floor:** Line coverage must be ≥85% and branch coverage ≥70%. Coverage drops >0.5% fail the gate.

## 3. QA Audit & Reproduction Contracts

- **QA Auditor (`qa-auditor`):** Outputs structured JSON Audit Contracts detailing scanned files, findings, severity, evidence, and recommendations across 5 runtime risk zones.
- **QA Test Gen (`qa-test-gen`):** Generates multi-framework test plans with mandatory boundary coverage and strict I/O mocking.
- **QA Bug Reproducer (`qa-reproducer`):** Synthesizes minimal reproduction scripts (`reproductions/repro-xxx.py`) and promotes fixed scripts to permanent regression tests under `tests/regression/`.
