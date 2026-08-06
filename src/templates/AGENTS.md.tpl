# AGENTS.md — agy-kit Project Rules (${LANG})

> **agy-kit scaffolded project** (${LANG}) — rules, skills, specialist agents, workflows, persistent memory, MCP guidance, orchestration, and native safety hooks.

## 1. Planning First Rule

- With any feature touching >3 files or changing architecture, Agent MUST create `plans/SPEC_<feature>.md` first.
- SPEC must include: use-cases, data flow, files to modify/create, API schema, edge-cases, backward compatibility.
- **DO NOT create or modify code files** during the Plan phase.

## 2. Test-Driven Development (TDD)

- Primary language: **${LANG}**
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

| Agent | Role | Specification |
|-------|------|---------------|
| `planner` | Survey codebase, write SPEC | `.agents/agents/planner.md` |
| `coder` | TDD implementation | `.agents/agents/coder.md` |
| `reviewer` | Code review, security scan | `.agents/agents/reviewer.md` |
| `qa` | E2E testing, dogfooding | `.agents/agents/qa.md` |

## 7. Rollback & Recovery Safety

- Before a subagent modifies code → create a git checkpoint (`git stash` or temp commit).
- After modifying code → run test runner. If test FAIL → auto-rollback to clean checkpoint.
- Max 3 retries per failing test → if exceeded, STOP and escalate.
- Max 15 turns per session → auto-exit to prevent infinite loops.

## 8. Multi-Language Support

- Primary language adapter configured for **${LANG}**.
- Auto-detect language via root indicator file (`pyproject.toml`, `go.mod`, `Cargo.toml`, `composer.json`, `package.json`).

## 9. Problem Solving, Ideation & Stress Testing

- **Brainstorming (`/brainstorm`, `brainstorming` skill):** Before writing code or implementation plans for novel/vague features, classify unknowns into 4 categories (Known knowns, Known unknowns, Unknown knowns, Unknown unknowns) and present 2–4 concrete option variants with explicit trade-offs. Respect hard gate: no code or implementation plans until design is approved by user.
- **Stress Testing (`/grill`, `grill-me` skill):** Before implementing technical specs or ADRs, subject plans to 11-question scrutiny. Force concrete answers — no hand-waving "figure out later".
- **Systematic Problem Solving (`/solve`, `problem-solving` skill):** Dispatch 5 core techniques (Simplification Cascades, Collision-Zone Thinking, Meta-Pattern Recognition, Inversion Exercise, Scale Game).

## 10. Quality Assurance & Evaluation

- Validates pipeline execution, test coverage, and OWASP security audit.
