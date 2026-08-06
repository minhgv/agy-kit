# agy-kit

> **Antigravity-First Agent Engineering Kit (v1.0-RC)** — experimental, AGY-native rules, specialist subagents, slash-command workflows, MCP integration, safety hooks, isolated worktree execution, multi-language support, business analysis core, quality framework, and template synchronization built exclusively for **Google Antigravity CLI (`agy`)**.

[![Version](https://img.shields.io/badge/scaffold-v1.0--RC-orange.svg)](.agents/version.json)
[![Platform](https://img.shields.io/badge/target-Antigravity--CLI-emerald.svg)](https://github.com/minhgv/agy-kit)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-experimental--in--progress-yellow.svg)](docs/PRD_agy_kit.md)

---

## Overview

`agy-kit` is a dedicated scaffold designed 100% exclusively for **Antigravity CLI (`agy`)**. It provides an end-to-end framework for autonomous agentic software engineering, combining an **Architect-Executor model routing strategy**, strict Test-Driven Development (TDD), Business Analysis (BA) core traceability, multi-tiered Quality Gates, isolated Git worktree execution, template synchronization, and a complete suite of ideation, stress-testing, and problem-solving skills.

---

## Key Architecture & Features

### 1. AGY-Native Subagents (`.agents/agents/*.md`)

`agy-kit` defines native Markdown subagents with YAML frontmatter conforming strictly to the official Antigravity subagent specification:

| Subagent | Role | Primary Model | Fallback Model | Spec Path |
|----------|------|---------------|----------------|-----------|
| `planner` | Lead System Architect & BA | `gemini-3.6-flash-high` | `gemini-3.6-flash-low` | [planner.md](file:///.agents/agents/planner.md) |
| `coder` | Senior Developer (TDD) | `gemini-3.6-flash-high` | `gemini-3.6-flash-low` | [coder.md](file:///.agents/agents/coder.md) |
| `reviewer` | Principal Reviewer & Security | `gemini-3.6-flash-high` | `gemini-3.6-flash-low` | [reviewer.md](file:///.agents/agents/reviewer.md) |
| `qa` | QA Automation Engineer | `gemini-3.6-flash-low` | `gemini-3.6-flash-low` | [qa.md](file:///.agents/agents/qa.md) |

### 2. Complete 14 Slash Workflows

Native slash commands configured in `.agents/workflows/` and `.antigravity/workflows/`:

| Phase / Category | Workflow | Description |
|---|---|---|
| **Ideation** | `/brainstorm` | Phân loại 4 nhóm unknowns, tạo 2-4 biến thể thiết kế |
| **Specification** | `/plan` | Lập SPEC, RTM (Traceability), DFD, 12D Edge Case Matrix |
| **Stress Testing** | `/grill` | Thử thách 11 câu hỏi soi rủi ro architecture |
| **Full Lifecycle** | `/pipeline` | Quy trình 5 bước khép kín (Plan → TDD → Gate → QA → Review) |
| **Safe Execution** | `/safe-pipeline` | Chạy 5 bước trên Git worktree cô lập + auto-rollback khi lỗi |
| **Quality Gate** | `/gate` | Kiểm định linter, secret scan, OWASP-AI 5 điểm & ranh giới path |
| **Code Review** | `/review` | Audit git diff, 3-State Verification & Conventional Commits |
| **E2E QA** | `/qa` | Playwright/cURL dogfooding & tạo MRE tái tạo lỗi (`reproductions/`) |
| **Troubleshooting** | `/solve` | Gỡ bế tắc bằng 5 kỹ thuật suy luận (Simplification, Inversion...) |
| **Diagnostics** | `/doctor` | Chẩn đoán sức khỏe môi trường, CLI version & toolchain |
| **Scaffolding** | `/init` | Khởi tạo agy-kit scaffold vào repository mới |
| **Memory** | `/learn` | Trích xuất bài học & quy tắc mới vào `MEMORY.md` |
| **Scheduling** | `/schedule` | Cấu hình timer / background audit task định kỳ |
| **Migration** | `/migrate` | Chuyển đổi cấu hình cũ v0.7.x sang AGY 2.0 chuẩn |

### 3. Hybrid `src/` Directory Architecture

`src/` separates installer template assets from internal Python package logic:
- `src/templates/`: Stores canonical template assets (`AGENTS.md.tpl`, `mcp_config.json.tpl`, `version.json.tpl`, `agents/*.md`, `workflows/*.md`) unrolled by `./bin/init-agy-kit.sh`.
- `src/agy_kit/`: Core Python package containing `orchestrator.py` (state machine), `worktree.py` (Git worktree manager), `validators.py` (path safety), and `cli.py`.

### 4. Template Drift Verification & Sync

Keep working assets and scaffolding templates 100% in sync:
- `make sync-templates`: Automatically updates `src/templates/` from `.agents/`.
- `bin/sync-templates.sh --check`: Fails Quality Gate CI if templates and live assets diverge.

### 5. Multi-Language Toolchain Adapters

Integrated test and linter adapters in `agy-kit/adapters/`:
- **Python**: pytest + ruff + mypy + pip-audit (`python.sh`)
- **TypeScript**: vitest + tsc + eslint + npm audit (`typescript.sh`)
- **Go**: go test + golangci-lint + govulncheck (`go.sh`)
- **Rust**: cargo test + clippy + cargo audit (`rust.sh`)
- **PHP**: phpunit + phpstan + composer audit (`php.sh`)

---

## Directory Structure

```text
agy-kit/
├── AGENTS.md                      # Core rules & system instructions for agy
├── GEMINI.md                      # Antigravity model routing & tracing overrides
├── MEMORY.md                      # Persistent project memory & learned rules
├── Makefile                       # Command wrapper (make pipeline, make doctor, etc.)
├── .agents/                       # Native AGY 2.0 Configuration
│   ├── agents/                    # Subagent specifications (.md format)
│   ├── mcp_config.json            # MCP server integrations
│   ├── skills/                    # Specialized skills suite
│   └── workflows/                 # 14 Native slash command workflows
├── src/                           # Hybrid Architecture Root
│   ├── templates/                 # Scaffolding templates for new projects
│   └── agy_kit/                   # Core Python package (orchestrator, worktree, validators)
├── agy-kit/adapters/              # 5 Language toolchain adapters (Python, TS, Go, Rust, PHP)
├── bin/                           # Executable scripts & diagnostics
│   ├── agy-doctor.sh
│   ├── init-agy-kit.sh
│   ├── safe-agent-run.sh
│   ├── sync-templates.sh
│   └── validate-agents.sh
├── tests/                         # Test pyramid & evaluation suite
│   ├── unit/                      # Unit tests
│   ├── fixtures/                  # Fake AGY simulator CLI
│   └── evals/                     # Benchmark suite (eval_harness.py, meta_eval_harness.py)
└── plans/                         # Technical specifications & templates
    └── SPEC_TEMPLATE.md
```

---

## End-to-End Workflow for New Projects

### Phase 1: Initialize Project
```bash
# 1. Scaffold agy-kit into a target project directory
./bin/init-agy-kit.sh --target ./my-app --lang python

# 2. Run environment diagnostics
/doctor
```

### Phase 2: Ideation & Architecture
```bash
# 3. Brainstorm unknown categories & option variants (optional)
/brainstorm "OAuth2 refresh token service"

# 4. Generate SPEC, RTM, 12D Edge Case Matrix
/plan "OAuth2 refresh token service"

# 5. Stress-test plan with 11 scrutiny questions
/grill "OAuth2 refresh token service"
```

### Phase 3: Safe TDD Implementation
```bash
# 6. Execute 5-stage pipeline with isolated Git worktree & auto-rollback
/safe-pipeline "OAuth2 refresh token service"
```

### Phase 4: Quality Gate & E2E QA
```bash
# 7. Run static analysis, secret scan, OWASP-AI checklist
/gate

# 8. Run E2E dogfooding tests & produce MRE bug reproductions
/qa
```

### Phase 5: Code Review & Memory Handoff
```bash
# 9. Audit 3-state verification & group Conventional Commits
/review

# 10. Extract learned rules into MEMORY.md
/learn "Token revocation pattern"
```

---

## Command Reference (`Makefile`)

```bash
make doctor              # Run system health diagnostics
make validate            # Run subagent, workflow sync & template drift audit
make verify-eval         # Run meta-eval & 5 synthetic fault injection tests
make sync-templates      # Synchronize active assets to src/templates/
make pipeline FEATURE=x  # Run full 5-step pipeline for feature
make check-boundaries    # Verify multi-agent path boundaries
make scan-deps           # Run OWASP-AI supply chain security scan
```

---

## Documentation

- [BA Core & Quality Framework](docs/ba-and-quality-framework.md)
- [Multi-Language Adapters](docs/multi-language-adapters.md)
- [Rollback & Recovery Safety](docs/rollback-recovery.md)
- [OWASP AI Security Checklist](docs/owasp-ai-checklist.md)
- [Target PRD](docs/PRD_agy_kit.md)

---

## License

[MIT](LICENSE) © 2026 Minh Vu
