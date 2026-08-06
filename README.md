# agy-kit

> **Antigravity-First Agent Engineering Kit (v0.7.0)** — production-ready rules, specialist subagents, slash-command workflows, MCP integration, safety hooks, persistent memory, multi-language support, business analysis core, quality framework, and ideation/stress-testing skills built exclusively for **Antigravity CLI (`agy`)**.

[![Version](https://img.shields.io/badge/scaffold-v0.7.0-blue.svg)](.antigravity/version.json)
[![Platform](https://img.shields.io/badge/target-Antigravity--CLI-emerald.svg)](https://github.com/minhgv/agy-kit)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Benchmarks](https://img.shields.io/badge/evals-13%2F13%20passed%20(100%2F100)-success.svg)](tests/evals/eval_harness.py)

---

## Overview

`agy-kit` is a dedicated scaffold designed 100% exclusively for **Antigravity CLI (`agy`)**. It provides an end-to-end framework for autonomous agentic software engineering, combining an **Architect-Executor model routing strategy**, strict Test-Driven Development (TDD), Business Analysis (BA) core traceability, multi-tiered Quality Gates, System Reliability Layer (SRL) rollbacks, and a complete suite of ideation, stress-testing, and problem-solving skills.

---

## Key Architecture & Features

### 1. Architect-Executor Model Routing

`agy-kit` pairs deep reasoning models for planning and auditing with high-throughput coding models for implementation:

| Subagent | Role | Primary Model | Fallback Model | Command |
|----------|------|---------------|----------------|---------|
| `planner` | Lead System Architect & BA | `zai/glm-5.2` | `gemini-3.6-flash-high` | `agy run --agent plan` |
| `coder` | Senior Developer (TDD) | `gemini-3.6-flash-high` | `gemini-3.6-flash-low` | `agy run --agent build` |
| `reviewer` | Principal Reviewer & Security | `zai/glm-5.2` | `gemini-3.6-flash-high` | `agy run --agent review` |
| `qa` | QA Automation Engineer | `gemini-3.6-flash-high` | `gemini-3.6-flash-low` | `agy run --agent qa` |

### 2. Complete Skills Suite

`agy-kit` includes a complete suite of specialist skills mirrored across `.hermes/skills/` and `.antigravity/skills/`:

1. **`tdd-workflow`**: Enforces strict RED → GREEN → REFACTOR execution cycle with failing test proof logs.
2. **`quality-gate`**: Zero-warning linting, OWASP-AI 5-point security audit, SARIF artifact generation.
3. **`ba-expert`**: Business Analysis Core — Ubiquitous language, 12-Dimensional Business Edge Case Matrix (ACM), Requirements Traceability Matrix (RTM), Zod/Pydantic schemas.
4. **`qa-auditor`**: Structured JSON Audit Contracts and runtime risk matrix evaluation.
5. **`qa-test-gen`**: Automated boundary test plan generation and contract coverage matrices.
6. **`qa-reproducer`**: Minimal Reproducible Example (MRE) bug reproduction pipeline (`reproductions/repro-xxx.py`).
7. **`brainstorming`**: Classifies unknowns into 4 categories (Known knowns, Known unknowns, Unknown knowns, Unknown unknowns) and presents 2–4 concrete option variants with trade-offs.
8. **`grill-me`**: 11-question technical spec stress-testing, assumption challenge, scale limits, and rollback check.
9. **`problem-solving`**: 5 core problem-solving techniques (Simplification Cascades, Collision-Zone Thinking, Meta-Pattern Recognition, Inversion Exercise, Scale Game) with dedicated reference guides in `references/`.

### 3. Complete 9 Slash Workflows

Native slash commands configured in `.antigravity/workflows/`:

- **`/pipeline`**: Full 5-stage sequential lifecycle (Plan → TDD → Gate → QA → Review).
- **`/plan`**: Architecture SPEC authoring, RTM generation, and 12-D edge matrix.
- **`/gate`**: Security scan, OWASP audit, and quality gate verification.
- **`/review`**: Git diff audit, plan-review stamp verification, and conventional commits.
- **`/qa`**: E2E server testing, Playwright/cURL dogfooding, and evidence collection.
- **`/safe-pipeline`**: Pipeline execution backed by automated transactional rollback safety net.
- **`/brainstorm`**: Pre-planning design exploration and 4-category unknown classification.
- **`/grill`**: Pre-implementation 11-question plan stress-testing and scrutiny.
- **`/solve`**: Systematic problem-solving techniques for execution blocks and complexity spirals.

### 4. Tooling & Executable Scripts (`bin/`)

- `bin/agy-pipeline.sh`: Headless CI pipeline runner (`--auto-approve`).
- `bin/safe-agent-run.sh`: Rollback-aware agent execution harness.
- `bin/agy-doctor.sh`: System diagnostics & dependency health checker.
- `bin/validate-agents.sh`: Subagent specification and schema validator.
- `bin/check-path-boundaries.sh`: Multi-agent workspace path boundary checker.
- `bin/synthesize-skill.sh`: Skill auto-synthesis protocol runner.
- `bin/scan-dependencies.sh`: OWASP-AI-01 supply chain & slopsquatting scanner.
- `bin/validate-traceability.sh`: Requirement Traceability Matrix (RTM) & SPEC validator.
- `bin/validate-workflows-sync.sh`: Workflows, agent specs, and skills synchronization validator.
- `bin/validate-brainstorm-skills.sh`: Ideation, stress-testing, and problem-solving skills validator.

### 5. Benchmark Evaluation Harness

`agy-kit` ships with a comprehensive evaluation harness in `tests/evals/eval_harness.py` covering **13 core benchmarks** with a **100/100 pass score**:

1. **Quality Gate Audit Compliance**: Zero lint errors & zero hardcoded secrets.
2. **Subagent Specification Validation**: Agent JSON schema & prompt safety validation.
3. **`agy-doctor` System Diagnostics**: Health check of environment runtimes & tools.
4. **Workspace Path Boundary Check**: Multi-agent file boundary isolation.
5. **Automated Token Cost Tracking**: Token efficiency & API cost estimation.
6. **Supply Chain Security Scan**: OWASP-AI-01 dependency scanning.
7. **Telemetry Metric Exporter**: OpenTelemetry & benchmark summary exporter.
8. **Skill Auto-Synthesis Protocol**: Automated skill creation & validation.
9. **End-to-End Requirement Traceability Audit**: RTM & SPEC compliance audit.
10. **BA & Quality Assurance Framework Docs Validator**: Framework documentation integrity.
11. **Phase 10 BA & QA Skills Suite Benchmark**: BA & QA skills synchronization audit.
12. **Workflows & Skills Sync Validator**: Workflows, subagent specs, and skills alignment.
13. **Phase 12 Brainstorming, Stress-Testing & Problem-Solving Skills Benchmark**: Ideation & problem-solving skills integrity.

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
│   ├── agents/                    # Specialist subagent definitions (v2.0 schema)
│   │   ├── planner.json           # Survey, SPEC authoring & BA (zai/glm-5.2)
│   │   ├── coder.json             # TDD implementation (gemini-3.6-flash-high)
│   │   ├── reviewer.json          # Code review & security audit (zai/glm-5.2)
│   │   └── qa.json                # E2E QA & dogfooding (gemini-3.6-flash-high)
│   ├── mcp.json                   # MCP server integrations (filesystem, github, playwright, sqlite)
│   ├── workflows/                 # 9 Native agy slash commands
│   │   ├── pipeline.md            # /pipeline
│   │   ├── plan.md                # /plan
│   │   ├── gate.md                # /gate
│   │   ├── review.md              # /review
│   │   ├── qa.md                  # /qa
│   │   ├── safe-pipeline.md       # /safe-pipeline
│   │   ├── brainstorm.md          # /brainstorm
│   │   ├── grill.md               # /grill
│   │   └── solve.md               # /solve
│   └── version.json               # Scaffold version tracking (v0.7.0)
├── .githooks/                     # Git security & commit enforcement
│   ├── pre-commit                 # Gitleaks & lint validation
│   └── commit-msg                 # Conventional Commits format validator
├── .github/workflows/ci.yml       # GitHub Actions CI pipeline
├── .hermes/skills/                # Agent Skills Suite
│   ├── tdd-workflow/
│   ├── quality-gate/
│   ├── ba-expert/
│   ├── qa-auditor/
│   ├── qa-test-gen/
│   ├── qa-reproducer/
│   ├── brainstorming/
│   ├── grill-me/
│   └── problem-solving/
├── bin/                           # 10 Executable verification and runner scripts
│   ├── agy-pipeline.sh
│   ├── safe-agent-run.sh
│   ├── agy-doctor.sh
│   ├── validate-agents.sh
│   ├── check-path-boundaries.sh
│   ├── synthesize-skill.sh
│   ├── scan-dependencies.sh
│   ├── validate-traceability.sh
│   ├── validate-workflows-sync.sh
│   └── validate-brainstorm-skills.sh
├── docs/                          # Comprehensive framework & system documentation
│   ├── ba-and-quality-framework.md
│   ├── business-analysis.md
│   ├── quality-framework.md
│   ├── reliability.md
│   ├── orchestration-patterns.md
│   ├── model-routing.md
│   ├── owasp-ai-checklist.md
│   ├── prompt-engineering.md
│   ├── memory-guide.md
│   ├── multi-language-adapters.md
│   ├── rollback-recovery.md
│   └── meta-testing.md
├── tests/evals/                   # Evaluation harness & benchmarks
│   ├── eval_harness.py
│   └── token_calculator.py
└── plans/                         # Technical specifications & templates
    └── SPEC_TEMPLATE.md
```

---

## Quick Start

```bash
# 1. Clone agy-kit
git clone https://github.com/minhgv/agy-kit.git my-project
cd my-project

# 2. Set up git hooks
git config core.hooksPath .githooks

# 3. Run diagnostics & system verification
./bin/agy-doctor.sh

# 4. Run evaluation harness (verifies all 13 benchmarks pass 100/100)
python3 tests/evals/eval_harness.py

# 5. Execute full feature pipeline
make pipeline FEATURE=auth-oauth2
```

---

## Documentation

- [BA Core & Quality Framework](docs/ba-and-quality-framework.md)
- [Business Analysis Architecture](docs/business-analysis.md)
- [Quality Framework & Gates](docs/quality-framework.md)
- [System Reliability Layer](docs/reliability.md)
- [Orchestration Patterns](docs/orchestration-patterns.md)
- [Model Routing Strategy](docs/model-routing.md)
- [OWASP AI Security Checklist](docs/owasp-ai-checklist.md)
- [Prompt Engineering Guide](docs/prompt-engineering.md)
- [Memory Management Guide](docs/memory-guide.md)
- [Multi-Language Adapters](docs/multi-language-adapters.md)
- [Rollback & Recovery Safety](docs/rollback-recovery.md)

---

## License

[MIT](LICENSE) © 2026 Minh Vu
