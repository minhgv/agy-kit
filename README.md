# agy-kit

> **Antigravity-first agent engineering kit** — rules, skills, specialist agents, workflows, persistent memory, MCP guidance, orchestration, and native safety hooks.
>
> Scaffolding tối ưu cho dự án lập trình với [Antigravity CLI](https://antigravity.google) (`agy`).

## Why agy-kit?

| Vấn đề | agy-kit giải quyết |
|--------|-------------------|
| Agent "bay vào code" ngay lập tức, bỏ qua thiết kế | **Planning First Rule** — ép Agent tạo SPEC trước |
| Không có test, code không ổn định | **TDD workflow** — Red → Green → Refactor bắt buộc |
| Commit lặt vặt, git log lộn xộn | **Conventional Commits** — gom commit theo nhóm việc |
| Không có QA thực tế, chỉ test trên giấy | **E2E Dogfooding** — cURL/Playwright trên local server |
| Bảo mật kém, lộ API key | **Security Audit Gate** — quét OWASP trước merge |

## Quick Start

### Cách 1: Copy scaffold vào project mới

```bash
# Clone agy-kit
git clone https://github.com/vudovn/agy-kit.git ~/code/github/agy-kit

# Copy vào project mới
cp -r ~/code/github/agy-kit/{AGENTS.md,GEMINI.md,.antigravity,plans,tests} /path/to/your-project/
```

### Cách 2: Dùng làm template (GitHub "Use this template")

1. Vào `https://github.com/vudovn/agy-kit`
2. Click **"Use this template"** → **"Create a new repository"**

## Cấu trúc thư mục

```text
agy-kit/
├── AGENTS.md                  # Project rules & agent constraints (auto-loaded by agy)
├── GEMINI.md                  # Antigravity-specific overrides (highest precedence)
├── .antigravity/agents/       # Declarative subagent definitions
│   ├── planner.json           # Lead Architect — surveys + writes SPEC
│   ├── coder.json             # Senior Dev — TDD implementation
│   ├── reviewer.json          # Principal Reviewer — code review + security + commits
│   └── qa.json                # QA Engineer — E2E testing + dogfooding
├── plans/                     # Technical specifications (SPEC_*.md)
├── tests/                     # Unit, integration, and E2E test suites
├── .hermes/skills/            # Reusable SKILL.md workflows (TDD, Quality Gate)
├── docs/                      # Documentation and guides
├── examples/                  # Example prompts and workflows
└── README.md                  # This file
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
agy run "Chạy lint, typecheck. Quét hardcode secrets + OWASP. Sửa mọi lỗi phát hiện."
```

### 4. E2E QA

```bash
agy run --agent qa "Khởi động local server. Chạy cURL test: valid payload (200), invalid payload (400), unauthorized (401). Thu thập evidence."
```

### 5. Code Review & Commit

```bash
agy run --agent review "Review git diff. Kiểm tra DRY/SOLID/Security. Gom commit Conventional Commits."
```

## Declarative Subagents

| Agent | Vai trò | Model mặc định | Trigger |
|-------|---------|----------------|---------|
| `planner` | Lead Architect — khảo sát, viết SPEC | gemini-3.6-flash-high | `--agent plan` |
| `coder` | Senior Dev — TDD Red→Green→Refactor | gemini-3.6-flash-high | `--agent build` |
| `reviewer` | Principal Reviewer — review + security + commit | gemini-3.6-flash-high | `--agent review` |
| `qa` | QA Engineer — E2E + dogfooding | gemini-3.6-flash-high | `--agent qa` |

## Tương thích

- **Antigravity CLI (`agy`)** v1.1.0+ — full support (declarative subagents, OpenTelemetry, AGENTS.md)
- **OpenCode** — SKILL.md format tương thích 100%, chỉ khác thư mục config (`.opencode/` vs `.antigravity/`)
- **Claude Code / Codex** — AGENTS.md format tương thích (chỉ thị dự án chung)

## License

MIT
