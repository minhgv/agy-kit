# agy-kit

> **Antigravity-first agent engineering kit** — rules, skills, specialist agents, workflows, MCP integration, safety hooks, OpenTelemetry tracing, and orchestration patterns.
>
> Scaffolding tối ưu cho dự án lập trình với [Antigravity CLI](https://antigravity.google) (`agy`).

## Why agy-kit?

| Vấn đề | agy-kit giải quyết |
|--------|-------------------|
| Agent "bay vào code" ngay lập tức, bỏ qua thiết kế | **Planning First Rule** — ép Agent tạo SPEC trước |
| Không có test, code không ổn định | **TDD workflow** — Red → Green → Refactor bắt buộc |
| Commit lặt vặt, git log lộn xộn | **Conventional Commits** — gom commit theo nhóm việc |
| Không có QA thực tế, chỉ test trên giấy | **E2E Dogfooding** — cURL/Playwright trên local server |
| Bảo mật kém, lộ API key | **Security Audit Gate** — Gitleaks + TruffleHog + OWASP-AI checklist |
| Agent dùng model đắt cho task đơn giản | **Model Routing** — Flash-low cho QA, Flash-high cho Plan/Code/Review |

## Quick Start

### Cách 1: Copy scaffold vào project mới

```bash
git clone https://github.com/vudovn/agy-kit.git
cp -r agy-kit/{AGENTS.md,GEMINI.md,.antigravity,.hermes,plans,tests,.pre-commit-config.yaml,.gitleaks.toml} /path/to/your-project/
```

### Cách 2: Dùng làm GitHub template

1. Vào `https://github.com/vudovn/agy-kit`
2. Click **"Use this template"** → **"Create a new repository"**

## Cấu trúc thư mục

```text
agy-kit/
├── AGENTS.md                     # Project rules (auto-loaded by agy)
├── GEMINI.md                     # Antigravity-specific overrides (highest precedence)
├── .antigravity/
│   ├── agents/                   # Declarative subagent definitions (v1.1 schema)
│   │   ├── planner.json          # Lead Architect — surveys + writes SPEC
│   │   ├── coder.json            # Senior Dev — TDD implementation
│   │   ├── reviewer.json         # Principal Reviewer — code review + OWASP-AI security
│   │   └── qa.json               # QA Engineer — E2E testing + dogfooding
│   └── mcp.json                  # MCP server config (filesystem, github, playwright, sqlite)
├── .hermes/skills/               # Reusable SKILL.md workflows
│   ├── tdd-workflow/             # Red→Green→Refactor procedure
│   └── quality-gate/             # Lint, typecheck, OWASP, secret scan
├── .github/workflows/ci.yml      # CI: lint + test + Gitleaks + TruffleHog
├── .pre-commit-config.yaml       # Git pre-commit hooks (ruff, gitleaks)
├── .gitleaks.toml                # Custom secret scanning rules
├── plans/                        # Technical specifications (SPEC_*.md)
├── tests/                        # Unit, integration, and E2E test suites
├── docs/
│   ├── orchestration-patterns.md # Sequential, Parallel, Hub-Spoke, Nexus patterns
│   ├── model-routing.md          # Model routing matrix + cost optimization
│   └── owasp-ai-checklist.md     # OWASP security checklist for AI-generated code
├── examples/                     # Example prompts and workflows
└── README.md
```

## 5-Step Agentic Engineering Workflow

```
[1. Plan/Spec] → [2. TDD] → [3. Quality Gate] → [4. E2E QA] → [5. Review & Commit]
```

### 1. Plan / Spec Phase
```bash
agy run --agent plan "Khảo sát module [MODULE] và viết SPEC cho tính năng [FEATURE]. Ghi vào plans/SPEC_[FEATURE].md"
```

### 2. TDD Implementation
```bash
agy run "Đọc plans/SPEC_[FEATURE].md. Viết test trước (RED), chạy test xác nhận FAIL. Viết logic tối thiểu (GREEN). Refactor. Báo cáo coverage."
```

### 3. Quality Gates & Security
```bash
agy run "Chạy lint, typecheck. Quét hardcode secrets (gitleaks) + OWASP-AI checklist. Sửa mọi lỗi phát hiện."
```

### 4. E2E QA
```bash
agy run --agent qa "Khởi động local server. Chạy cURL test: valid (200), invalid (400), unauthorized (401). Thu thập evidence."
```

### 5. Code Review & Commit
```bash
agy run --agent review "Review git diff. Kiểm tra DRY/SOLID/OWASP. Gom commit Conventional Commits."
```

## Declarative Subagents (v1.1 — Schema Filtering + Model Routing)

| Agent | Vai trò | Model | Temp | Tools (allowed) |
|-------|---------|-------|------|-----------------|
| `planner` | Lead Architect | flash-high | 0.4 | read_file, search_files, web_search |
| `coder` | Senior Dev (TDD) | flash-high | 0.2 | read_file, write_file, search_files, terminal, patch |
| `reviewer` | Principal Reviewer | flash-high | 0.3 | read_file, terminal, search_files, patch |
| `qa` | QA Engineer | flash-low | 0.1 | terminal, read_file, write_file |

**Dual-Constraint Security:** Prompt định hướng hành vi + Schema filtering khóa tool ngoài allowlist. (Bài học từ CVE-2026-22708 — cần kết hợp OS runtime sandboxing.)

## MCP Integration

Pre-configured MCP servers trong `.antigravity/mcp.json`:
- **Filesystem** — scoped file access
- **GitHub** — PR/Issue management
- **Playwright** — headless browser/E2E testing
- **SQLite** — database queries

## Safety Hooks

| Hook | Layer | Công cụ |
|------|-------|---------|
| Pre-commit | Git | ruff, eslint, gitleaks |
| CI Pipeline | GitHub Actions | Gitleaks + TruffleHog (verified) |
| OWASP-AI Checklist | Reviewer agent | 5-item AI-specific security audit |
| Schema Filtering | Agent definition | Tool allowlist per subagent |

## License

MIT
