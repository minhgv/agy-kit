# AGENTS.md — agy-kit Project Rules

> **agy-kit** is an Antigravity-first agent engineering kit: rules, skills, specialist agents, workflows, persistent memory, MCP guidance, orchestration, and native safety hooks.

## 1. Planning First Rule

- With any feature touching >3 files or changing architecture, Agent MUST create `plans/SPEC_<feature>.md` first.
- SPEC must include: use-cases, data flow, files to modify/create, API schema, edge-cases, backward compatibility.
- **DO NOT create or modify code files** during the Plan phase.

## 2. Test-Driven Development (TDD)

- Every new logic must ship with Unit/Integration Test.
- Enforce RED → GREEN → REFACTOR cycle. Confirm test FAIL before writing logic.

## 3. Strict Quality Gates

- Linter & Typecheck: 0 error, 0 warning.
- **NEVER hardcode** secrets, API keys, or passwords into the codebase.
- OWASP security scan mandatory before merge.

## 4. Git Convention

- Group commits into complete feature units, follow Conventional Commits.
- **DO NOT commit** single files one by one (commit after 5-10 iterations of work).

## 5. Agentic Workflow

```
[Plan] → [TDD] → [Quality Gate] → [E2E QA] → [Review & Commit]
```

## 6. Subagent Roles

| Agent | Role | Trigger |
|-------|------|---------|
| `planner` | Survey codebase, write SPEC | `--agent plan` |
| `coder` | TDD implementation | `--agent build` (default) |
| `reviewer` | Code review, security scan | `--agent review` |
| `qa` | E2E testing, dogfooding | `--agent qa` |

## 7. Rollback & Recovery Safety

- Before a subagent modifies code → create a git checkpoint (`git stash` or temp commit).
- After modifying code → run test runner. If test FAIL → auto-rollback to clean checkpoint.
- Max 3 retries per failing test → if exceeded, STOP and escalate.
- Max 15 turns per session → auto-exit to prevent infinite loops.
- Details: `docs/rollback-recovery.md`

## 8. Multi-Language Support

- Auto-detect language via root indicator file (`pyproject.toml`, `go.mod`, `Cargo.toml`, `composer.json`, `package.json`).
- Each language has its own toolchain adapter (linter, formatter, typechecker, test runner).
- Details: `docs/multi-language-adapters.md`
