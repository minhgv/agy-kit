# agy-kit

> **Antigravity-First Agent Engineering Kit** — production-ready rules, specialist subagents, slash-command workflows, MCP integration, safety hooks, persistent memory, and multi-language support built exclusively for **Antigravity CLI (`agy`)**.

[![Version](https://img.shields.io/badge/scaffold-v0.6.0-blue.svg)](.antigravity/version.json)
[![Platform](https://img.shields.io/badge/target-Antigravity--CLI-emerald.svg)](https://github.com/minhgv/agy-kit)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## Overview

`agy-kit` is a dedicated scaffold designed specifically for **Antigravity CLI (`agy`)**. It provides an end-to-end framework for autonomous agentic software development, enforcing strict TDD, Quality Gates, E2E QA testing, transactional rollbacks, and multi-language toolchain adaptation.

---

## Directory Structure

```
agy-kit/
├── AGENTS.md                      # Core rules & system instructions for agy
├── GEMINI.md                      # Antigravity model routing & tracing overrides
├── MEMORY.md                      # Persistent project memory (stack, decisions, conventions)
├── README.md                      # Project documentation
├── Makefile                       # Command wrapper: make pipeline FEATURE=auth
├── .antigravity/
│   ├── agents/                    # Specialist subagent definitions (v1.1 schema)
│   │   ├── planner.json           # Survey & SPEC authoring (gemini-3.6-flash-high)
│   │   ├── coder.json             # TDD implementation (gemini-3.6-flash-low)
│   │   ├── reviewer.json          # Code review & security audit (gemini-3.6-flash-high)
│   │   └── qa.json                # E2E QA & dogfooding (gemini-3.6-flash-low)
│   ├── mcp.json                   # MCP server integrations (filesystem, github, playwright, sqlite)
│   ├── workflows/                 # Native agy slash commands
│   │   ├── pipeline.md            # /pipeline — Full 5-stage sequential execution
│   │   ├── plan.md                # /plan — Architecture & SPEC authoring
│   │   ├── gate.md                # /gate — Security scan & quality audit
│   │   ├── review.md              # /review — Diff audit & conventional commits
│   │   ├── qa.md                  # /qa — E2E server testing & evidence collection
│   │   └── safe-pipeline.md       # /safe-pipeline — Pipeline with auto-rollback safety net
│   └── version.json               # Scaffold version tracking
├── .githooks/                     # Git security & commit enforcement
│   ├── pre-commit                 # Gitleaks & lint validation
│   └── commit-msg                 # Conventional Commits format validator
├── .github/workflows/ci.yml       # GitHub Actions CI pipeline
├── .hermes/skills/                # Agent Skills Open Standard
│   ├── tdd-workflow/              # RED-GREEN-REFACTOR skill
│   └── quality-gate/              # Audit & security scan skill
├── bin/
│   ├── agy-pipeline.sh            # Headless CI runner (--auto-approve)
│   └── safe-agent-run.sh          # Auto-rollback safety net runner
├── docs/
│   ├── orchestration-patterns.md  # Subagent pipeline architecture
│   ├── model-routing.md           # Model assignment & token cost optimization
│   ├── owasp-ai-checklist.md      # 5-point AI security audit protocol
│   ├── prompt-engineering.md      # Prompt patterns & 3-state verification
│   ├── memory-guide.md            # 4-layer persistent memory strategy
│   ├── multi-language-adapters.md # Toolchain matrix for Python, Go, Rust, PHP, Node/TS
│   ├── rollback-recovery.md       # Transactional code edits & git checkpointing
│   ├── upgrade-guide.md           # Scaffold versioning & migration rules
│   └── meta-testing.md            # Testing agent scaffolds & trajectory evals
├── examples/                      # Concrete implementation samples
│   ├── SPEC_user_registration_example.md
│   ├── error_recovery_scenario.md
│   ├── parallel_review_workflow.md
│   ├── getting_started_tutorial.md
│   └── python_fastapi_config_example/
└── plans/
    └── SPEC_TEMPLATE.md           # 7-section technical specification template
```

---

## Key Features

### 1. 5-Stage Agentic Workflow

```
[Plan] ──> [TDD] ──> [Quality Gate] ──> [E2E QA] ──> [Review & Commit]
```

| Stage | Subagent | Model | Command |
|-------|----------|-------|---------|
| **1. Plan** | `planner` | `gemini-3.6-flash-high` | `agy run --agent plan` |
| **2. TDD** | `coder` | `gemini-3.6-flash-low` | `agy run --agent build` |
| **3. Gate** | `reviewer` | `gemini-3.6-flash-high` | `agy run --agent review` |
| **4. QA** | `qa` | `gemini-3.6-flash-low` | `agy run --agent qa` |
| **5. Review** | `reviewer` | `gemini-3.6-flash-high` | `agy run --agent review` |

### 2. Multi-Language Support

Automatically configures linter, formatter, typechecker, and test runner based on project root:
- **Python:** `ruff`, `mypy`, `pytest`
- **Go:** `golangci-lint`, `go test`
- **Rust:** `clippy`, `cargo test`
- **PHP:** `pint`, `phpstan`, `phpunit` / `pest`
- **Node/TS:** `eslint`, `tsc`, `vitest` / `jest`

### 3. Transactional Rollback & Safety Hooks

- **Git Checkpointing:** Creates clean stashes before subagent code mutations.
- **Auto-Rollback:** Automatically reverts code on test failure (`bin/safe-agent-run.sh`).
- **Loop Prevention:** 15-turn session hard cap, 3 retries max per failing test.
- **OWASP-AI Scan:** 5-point security audit before code merge.

---

## Quick Start

```bash
# 1. Clone agy-kit
git clone https://github.com/minhgv/agy-kit.git my-project
cd my-project

# 2. Set up git hooks
git config core.hooksPath .githooks

# 3. Run full feature pipeline
make pipeline FEATURE=auth-oauth2
```

---

## Documentation

- [Orchestration Patterns](docs/orchestration-patterns.md)
- [Model Routing & Cost Strategy](docs/model-routing.md)
- [OWASP AI Checklist](docs/owasp-ai-checklist.md)
- [Prompt Engineering Guide](docs/prompt-engineering.md)
- [Memory Management Guide](docs/memory-guide.md)
- [Multi-Language Toolchain Adapters](docs/multi-language-adapters.md)
- [Rollback & Recovery Safety](docs/rollback-recovery.md)
- [Meta-Testing & Scaffold Evals](docs/meta-testing.md)
- [Upgrade & Migration Guide](docs/upgrade-guide.md)

---

## License

[MIT](LICENSE) © 2026 Minh Vu
