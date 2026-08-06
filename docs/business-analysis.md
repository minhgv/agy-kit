# Business Analysis Operating Manual (Phase 10)

> **Scaffold:** `agy-kit`  
> **Skill Reference:** `ba-expert`  
> **Status:** Production Standard

---

## 1. Overview

The Business Analysis (BA) discipline in `agy-kit` ensures that business intent is converted into verifiable, traceable engineering artefacts before any code implementation begins.

## 2. Mandatory BA Artefacts

For every feature touching **>3 files** or altering system architecture, the `planner` subagent produces:

1. **Feature Specification (`plans/SPEC_<feature>.md`):** Executive summary, domain model, DFD, API schemas.
2. **Requirement Traceability Matrix (`plans/RTM_<feature>.md`):** Monotonically ordered requirements (`R-001`, `R-002`, ...), explicit vs implicit types, priority (`P0`–`P3`), target files, unit test refs, and QA evidence paths.
3. **12-Dimensional Business Edge Case Matrix (`plans/ACM_<feature>.md`):** Complete enumeration of business edge cases across all 12 risk dimensions (`E-001` format, ≥3 edge cases per requirement).
4. **Non-Functional Requirements (`plans/NFR_<feature>.md`):** Quantitative metrics for Latency (p95 < 300ms), Throughput (≥100 ops/s), Error Rate (<0.1%), MTTR (<60s), and Coverage Floor (≥85% lines, ≥70% branches).
5. **Data Flow Diagram (`plans/DFD_<feature>.md`):** ASCII or Mermaid DFD clearly delineating trust boundaries.

## 3. The 12-Dimensional Business Edge-Case Matrix

| Dimension | Risk Category | Standard Mitigation |
|---|---|---|
| 1 | Null / Missing | Zod / Pydantic default schema values |
| 2 | Precision Loss | Currency as integer cents |
| 3 | Concurrency | Optimistic locking (`version` key / ETag) |
| 4 | Rate Limit | Token Bucket Rate Limiter |
| 5 | Schema Drift | Dual-schema transformer / adapter |
| 6 | Idempotency | `X-Idempotency-Key` header deduplication |
| 7 | Partial Failure | Transactional Outbox Pattern |
| 8 | Security Fallback | Fail-Closed mode |
| 9 | Context Overflow | Input length pre-validation & truncation |
| 10 | Resource Leak | RAII cleanup / `try-finally` blocks |
| 11 | Tenant Leak | Row-Level Security (RLS) & TenantID predicates |
| 12 | Task Interrupt | Atomic checkpoint persistence (`.agy/session.json`) |

## 4. `plan-review` Gate Approval

No feature may enter the `coder` implementation stage without a stamped `plan-review` approval from `reviewer`. Any unapproved plan handed off to code generation is a process violation and is rejected at the orchestration layer.
