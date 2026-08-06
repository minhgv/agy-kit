# agy-kit

> **Production-ready scaffold for agentic engineering** — rules, declarative subagents, slash-command workflows, MCP integration, safety hooks, cross-tool adapters, and multi-language support.
>
> Works with [Antigravity CLI](https://antigravity.google) (`agy`), Claude Code, OpenCode, Cursor, Windsurf, Codex, and GitHub Copilot.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Scaffold Version](https://img.shields.io/badge/version-0.5.0-blue.svg)](.antigravity/version.json)

---

## Why agy-kit?

AI coding agents without a scaffold tend to: skip planning, produce untested code, commit chaotically, leak secrets, and use expensive models for trivial tasks. agy-kit solves this with **deterministic enforcement** (git hooks, schema filtering, CI gates) rather than relying on prompt instructions alone.

| Problem | agy-kit enforcement |
|---------|-------------------|
| Agent writes code without a plan | **Planning First Rule** — SPEC required before code |
| No tests, fragile code | **TDD workflow** — Red → Green → Refactor mandatory |
| Messy git history | **Conventional Commits** — commit-msg hook enforces format |
| Untested in real environment | **E2E Dogfooding** — cURL/Playwright on local server |
| Hardcoded secrets, OWASP holes | **Security Gates** — Gitleaks + TruffleHog + OWASP-AI checklist |
| Expensive model for every task | **Model Routing** — high-tier for Plan/Code/Review, low-tier for QA |
| Agent breaks codebase mid-pipeline | **Auto-rollback** — git checkpoint + test verification per stage |
| Works only with one tool | **7 tool adapters** — sync from single source of truth |

---

## Quick Start

### Option A: GitHub Template (greenfield projects)

1. Go to **[github.com/minhgv/agy-kit](https://github.com/minhgv/agy-kit)**
2. Click **"Use this template"** → **"Create a new repository"**

### Option B: Add to existing project

```bash
# Clone and copy scaffold files
git clone https://github.com/minhgv/agy-kit.git /tmp/agy-kit
cp -r /tmp/agy-kit/{AGENTS.md,GEMINI.md,MEMORY.md,.antigravity,.claude,.opencode,.codex,.githooks,.hermes,.github,.pre-commit-config.yaml,.gitleaks.toml,Makefile,bin,plans,docs} /path/to/your-project/

# Install git hooks
cd /path/to/your-project
git config core.hooksPath .githooks
```

### Verify setup

```bash
./bin/sync-adapters.sh    # Regenerate all tool adapters from source of truth
cat .antigravity/version.json   # Check scaffold version
```

---

## Project Structure

```text
agy-kit/
├── AGENTS.md                         # Universal project rules (8 sections, all tools read this)
├── GEMINI.md                         # Antigravity-specific overrides (highest precedence)
├── MEMORY.md                         # Persistent project memory (tech stack, decisions)
│
├── .antigravity/                     # SOURCE OF TRUTH — Antigravity CLI native configs
│   ├── agents/                       #   4 declarative subagents (v1.1 schema)
│   │   ├── planner.json              #     Lead Architect — surveys + writes SPEC
│   │   ├── coder.json                #     Senior Dev — TDD implementation
│   │   ├── reviewer.json             #     Principal Reviewer — OWASP-AI + Conventional Commits
│   │   └── qa.json                   #     QA Engineer — E2E + dogfooding
│   ├── workflows/                    #   6 slash-command workflows (turbo mode)
│   │   ├── pipeline.md               #     /pipeline — full 5-step automated
│   │   ├── safe-pipeline.md          #     /safe-pipeline — with auto-rollback
│   │   ├── plan.md / gate.md / ...   #     Individual stage triggers
│   ├── mcp.json                      #   4 MCP servers (filesystem, github, playwright, sqlite)
│   └── version.json                  #   Scaffold version + compatible CLI range
│
├── .claude/agents/                   # Claude Code adapter (4 agents, YAML frontmatter + prompt)
├── .opencode/agents.json             # OpenCode adapter (4 agents, single JSON)
├── .codex/agents/                    # Codex CLI adapter (4 agents, TOML with sandbox_mode)
├── .cursorrules                      # Cursor IDE rules (auto-generated from AGENTS.md)
├── .windsurfrules                    # Windsurf IDE rules (auto-generated)
├── .github/
│   ├── copilot-instructions.md       #   GitHub Copilot adapter
│   └── workflows/ci.yml              #   CI: lint + test + Gitleaks + TruffleHog
│
├── .githooks/                        # Git enforcement hooks
│   ├── pre-commit                    #   Gitleaks + lint on staged files
│   └── commit-msg                    #   Conventional Commits format validation
├── .gitleaks.toml                    # Custom secret scanning rules (API key, JWT, private key)
├── .pre-commit-config.yaml           # Pre-commit framework config (ruff, gitleaks)
│
├── .hermes/skills/                   # Reusable SKILL.md workflows
│   ├── tdd-workflow/                 #   Red → Green → Refactor procedure
│   └── quality-gate/                 #   Lint, typecheck, OWASP, secret scan
│
├── bin/                              # Automation scripts
│   ├── agy-pipeline.sh               #   Headless CI pipeline runner (--auto-approve)
│   ├── safe-agent-run.sh             #   Run stage with auto-rollback safety net
│   └── sync-adapters.sh              #   Regenerate all tool adapters from .antigravity/
│
├── plans/                            # Technical specifications
│   └── SPEC_TEMPLATE.md              #   7-section SPEC template
├── tests/                            # Test suites (unit, integration, E2E, qa-evidence)
│
├── docs/                             # Documentation (10 guides)
│   ├── orchestration-patterns.md     #   Sequential, Parallel, Hub-Spoke, Nexus
│   ├── model-routing.md              #   Routing matrix + cost optimization + OpenTelemetry
│   ├── owasp-ai-checklist.md         #   5-item OWASP security for AI-generated code
│   ├── prompt-engineering.md         #   6 patterns: Architect/Editor, error recovery, anti-hallucination
│   ├── multi-language-adapters.md    #   5 languages: Python, Go, Rust, PHP, Node/TS
│   ├── rollback-recovery.md          #   Git checkpoint, auto-rollback, loop prevention, token budget
│   ├── cross-tool-compat.md          #   7-tool compatibility matrix + sync strategy
│   ├── upgrade-guide.md              #   Semver, non-destructive merge, migration guides
│   ├── meta-testing.md               #   Testing agent scaffolds (meta-tests, trajectory evals)
│   └── memory-guide.md               #   4-layer memory architecture
│
├── examples/                         # Concrete examples
│   ├── SPEC_user_registration_example.md   #   Complete SPEC for REST API feature
│   ├── python_fastapi_config_example/      #   Python/FastAPI subagent configs
│   ├── error_recovery_scenario.md          #   Test fail → agent self-heal demo
│   ├── parallel_review_workflow.md         #   Scatter-gather 3 reviewers
│   └── getting_started_tutorial.md         #   Zero to first feature tutorial
│
├── Makefile                          # make pipeline FEATURE=xxx (chain 5 stages)
├── CONTRIBUTING.md                   # Contribution guide + semver rules
├── CHANGELOG.md                      # Versioned changelog with migration notes
└── LICENSE                           # MIT
```

---

## 5-Step Agentic Engineering Workflow

```
[1. Plan/Spec] → [2. TDD] → [3. Quality Gate] → [4. E2E QA] → [5. Review & Commit]
```

Each step maps to a subagent and a slash command:

| Step | Subagent | Slash Command | Makefile | Output |
|------|----------|--------------|----------|--------|
| 1. Plan | `planner` | `/plan` | `make spec FEATURE=xxx` | `plans/SPEC_xxx.md` |
| 2. TDD | `coder` | — | `make build FEATURE=xxx` | `src/*` + `tests/*` |
| 3. Quality Gate | `reviewer` | `/gate` | `make gate` | 0 errors, 0 secrets |
| 4. E2E QA | `qa` | `/qa` | `make qa` | `tests/qa-evidence/*` |
| 5. Review & Commit | `reviewer` | `/review` | `make review` | Conventional Commits |

**Full pipeline:** `/pipeline` or `make pipeline FEATURE=xxx`

**Safe pipeline (with auto-rollback):** `/safe-pipeline` or `./bin/safe-agent-run.sh coder "feature" "prompt"`

---

## Declarative Subagents (v1.1 Schema)

Each subagent has: model routing (primary/fallback/temperature), tool permissions (schema filtering), context window isolation, and input/output schemas.

| Agent | Role | Model (agy) | Temp | Tools (allowed) | Write Scope |
|-------|------|-------------|------|-----------------|-------------|
| `planner` | Lead Architect | flash-high | 0.4 | read_file, search_files, web_search | `plans/SPEC_*.md` only |
| `coder` | Senior Dev (TDD) | flash-high | 0.2 | read_file, write_file, search_files, terminal, patch | `src/**`, `tests/**` |
| `reviewer` | Principal Reviewer | flash-high | 0.3 | read_file, terminal, search_files, patch | Read-only + patch security fixes |
| `qa` | QA Engineer | flash-low | 0.1 | terminal, read_file, write_file | `tests/e2e/**`, `tests/qa-evidence/**` |

**Dual-Constraint Security:** Prompt instructions guide behavior + schema filtering removes disallowed tools from the API request entirely. (Lesson from CVE-2026-22708: combine with OS-level sandboxing.)

---

## Cross-Tool Compatibility (7 Tools)

agy-kit uses a **Canonical Spec + Sync CLI** architecture. `.antigravity/agents/*.json` is the single source of truth. `bin/sync-adapters.sh` regenerates all adapters:

| Tool | Config Location | Format | How to Sync |
|------|----------------|--------|-------------|
| **Antigravity CLI** | `.antigravity/agents/*.json` | JSON v1.1 | Source of truth |
| **Claude Code** | `.claude/agents/*.md` | YAML frontmatter + prompt | `./bin/sync-adapters.sh` |
| **OpenCode** | `.opencode/agents.json` | JSON | `./bin/sync-adapters.sh` |
| **Codex CLI** | `.codex/agents/*.toml` | TOML + sandbox_mode | Manual (or extend sync script) |
| **Cursor** | `.cursorrules` | Markdown | `./bin/sync-adapters.sh` |
| **Windsurf** | `.windsurfrules` | Markdown | `./bin/sync-adapters.sh` |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Markdown | `./bin/sync-adapters.sh` |

All tools also read root `AGENTS.md` for project-level rules.

---

## Multi-Language Support (5 Languages)

agy-kit auto-detects the project language and injects the correct toolchain commands into subagent prompts:

| Language | Detection File | Linter | Test Runner | Type Checker |
|----------|---------------|--------|-------------|-------------|
| **Python** | `pyproject.toml` | ruff | pytest | mypy |
| **Go** | `go.mod` | golangci-lint | go test | (built-in) |
| **Rust** | `Cargo.toml` | clippy | cargo test | (built-in) |
| **PHP** | `composer.json` | phpstan | phpunit | (built-in) |
| **Node/TS** | `package.json` | eslint/biome | vitest/jest | tsc |

See `docs/multi-language-adapters.md` for toolchain configs and monorepo support (hierarchical AGENTS.md, path boundary isolation, turbo/nx filter).

---

## Safety Hooks

| Layer | What it does | Tool |
|-------|-------------|------|
| **Pre-commit** (Git) | Block commit if secrets detected or lint fails | `.githooks/pre-commit` → Gitleaks + ruff/eslint |
| **Commit-msg** (Git) | Reject non-Conventional Commits | `.githooks/commit-msg` |
| **CI Pipeline** (GitHub Actions) | Full lint + test + verified secret scan | `.github/workflows/ci.yml` → Gitleaks + TruffleHog |
| **OWASP-AI Checklist** (Reviewer) | 5-item AI-specific security audit | `docs/owasp-ai-checklist.md` |
| **Schema Filtering** (Subagents) | Remove disallowed tools per agent | `permissions.allowed_commands` in agent JSON |
| **Auto-rollback** (Pipeline) | Revert to git checkpoint if tests fail | `bin/safe-agent-run.sh` |
| **Loop Prevention** (Runtime) | Max 3 retries, max 15 turns per session | Documented in `docs/rollback-recovery.md` |

---

## Rollback & Recovery

When an agent stage fails, agy-kit ensures the codebase returns to a clean state:

```bash
# Safe run: creates checkpoint → runs agent → verifies tests → auto-rollback on failure
./bin/safe-agent-run.sh coder auth-oauth2 "Implement OAuth2 per SPEC"
```

**Loop prevention rules:** Max 3 retries per failing test → escalate. Max 15 turns per session → auto-exit.

See `docs/rollback-recovery.md` for full transactional workflow.

---

## MCP Integration

Pre-configured MCP servers in `.antigravity/mcp.json`:

| Server | Purpose |
|--------|---------|
| `filesystem` | Scoped local file access (read/write/directory) |
| `github` | Repository management, PR/Issue creation |
| `playwright` | Headless browser automation, E2E testing |
| `sqlite` | Database schema discovery, SQL queries |

---

## Documentation

| Guide | What's inside |
|-------|--------------|
| [orchestration-patterns.md](docs/orchestration-patterns.md) | Sequential, Parallel, Hub-Spoke, Nexus patterns |
| [model-routing.md](docs/model-routing.md) | Routing matrix, cost optimization, OpenTelemetry spans |
| [owasp-ai-checklist.md](docs/owasp-ai-checklist.md) | 5 OWASP items for AI-generated code |
| [prompt-engineering.md](docs/prompt-engineering.md) | Architect/Editor split, error recovery, anti-hallucination |
| [multi-language-adapters.md](docs/multi-language-adapters.md) | 5 languages + monorepo patterns |
| [rollback-recovery.md](docs/rollback-recovery.md) | Git checkpoint, auto-rollback, token budget |
| [cross-tool-compat.md](docs/cross-tool-compat.md) | 7-tool matrix, sync strategy, customization |
| [upgrade-guide.md](docs/upgrade-guide.md) | Semver, non-destructive merge, migration |
| [meta-testing.md](docs/meta-testing.md) | Testing agent scaffolds themselves |
| [memory-guide.md](docs/memory-guide.md) | 4-layer persistent memory |

---

## License

[MIT](LICENSE) — free to use, modify, and distribute.
