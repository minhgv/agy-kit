# AGENTS.md — agy-kit Project Rules

> **agy-kit** is an Antigravity-first agent engineering kit: rules, skills, specialist agents, workflows, persistent memory, MCP guidance, orchestration, and native safety hooks.

## 1. Planning First Rule

- With any feature touching >3 files or changing architecture, Agent MUST create `plans/SPEC_<feature>.md` first.
- SPEC must include: use-cases, data flow, files to modify/create, API schema, edge-cases, backward compatibility.
- **CHƯA ĐƯỢC TẠO HOẶC SỬA FILE CODE** trong giai đoạn Plan.

## 2. Test-Driven Development (TDD)

- Every new logic must ship with Unit/Integration Test.
- Enforce RED → GREEN → REFACTOR cycle. Confirm test FAIL before writing logic.

## 3. Strict Quality Gates

- Linter & Typecheck: 0 error, 0 warning.
- **Tuyệt đối KHÔNG hardcode** bí mật, API key, password vào codebase.
- OWASP security scan mandatory before merge.

## 4. Git Convention

- Group commits into complete feature units, follow Conventional Commits.
- **KHÔNG commit vụn vặt** từng file đơn lẻ (5-10 iterations xong mới commit).

## 5. Agentic Workflow

```
[Plan] → [TDD] → [Quality Gate] → [E2E QA] → [Review & Commit]
```

## 6. Subagent Roles

| Agent | Role | Trigger |
|-------|------|---------|
| `planner` | Khảo sát codebase, viết SPEC | `--agent plan` |
| `coder` | TDD implementation | `--agent build` (default) |
| `reviewer` | Code review, security scan | `--agent review` |
| `qa` | E2E testing, dogfooding | `--agent qa` |
