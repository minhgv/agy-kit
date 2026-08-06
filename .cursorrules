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

## 7. Rollback & Recovery Safety

- Trước khi subagent can thiệp code → tạo git checkpoint (`git stash` hoặc temp commit).
- Sau khi sửa code → chạy test runner. Nếu test FAIL → auto-rollback về checkpoint sạch.
- Max 3 retries per failing test → nếu vượt quá, STOP và escalate.
- Max 15 turns per session → auto-exit để tránh vòng lặp vô hạn.
- Chi tiết: `docs/rollback-recovery.md`

## 8. Multi-Language Support

- Tự động phát hiện ngôn ngữ qua root indicator file (`pyproject.toml`, `go.mod`, `Cargo.toml`, `composer.json`, `package.json`).
- Mỗi ngôn ngữ có toolchain adapter riêng (linter, formatter, typechecker, test runner).
- Chi tiết: `docs/multi-language-adapters.md`
