#!/usr/bin/env bash
# init-agy-kit.sh — Developer Scaffolding Installer CLI for agy-kit
#
# Usage:
#   ./bin/init-agy-kit.sh --target /path/to/project --lang python
#   ./bin/init-agy-kit.sh --help

set -euo pipefail

SHOW_HELP=0
TARGET_DIR="."
LANG_CHOICE="python"

show_usage() {
    cat << 'EOF'
==================================================
  agy-kit Developer Scaffolding Installer CLI
==================================================
Usage:
  init-agy-kit.sh [OPTIONS]

Options:
  -t, --target DIR     Target directory to scaffold (default: .)
  -l, --lang LANG      Primary project language: python | go | rust | php | ts (default: python)
  -h, --help           Show this help message and exit

Examples:
  ./bin/init-agy-kit.sh --target ./my-app --lang python
  ./bin/init-agy-kit.sh --target ./go-service --lang go
  ./bin/init-agy-kit.sh --target ./rust-crate --lang rust
  ./bin/init-agy-kit.sh --target ./laravel-app --lang php
  ./bin/init-agy-kit.sh --target ./express-api --lang ts

Scaffolded Artifacts:
  - .antigravity/        (Subagent specs: planner, coder, reviewer, qa & version.json)
  - AGENTS.md            (Root project rules & quality gates for language)
  - .githooks/           (Pre-commit security & quality hooks)
  - skills/              (Core agy-kit agent skills)
  - workflows/           (Agentic workflow pipelines)
  - Language Config      (pyproject.toml / golangci.yml / Cargo.toml / phpstan.neon / tsconfig.json)

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            SHOW_HELP=1
            shift
            ;;
        -t|--target)
            TARGET_DIR="$2"
            shift 2
            ;;
        -l|--lang)
            LANG_CHOICE="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown option $1"
            show_usage
            exit 1
            ;;
    esac
done

if [[ "$SHOW_HELP" -eq 1 ]]; then
    show_usage
    exit 0
fi

# Normalize language choice
LANG_CHOICE="$(echo "$LANG_CHOICE" | tr '[:upper:]' '[:lower:]')"
case "$LANG_CHOICE" in
    python|py)
        LANG_CHOICE="python"
        ;;
    go|golang)
        LANG_CHOICE="go"
        ;;
    rust|rs)
        LANG_CHOICE="rust"
        ;;
    php|laravel)
        LANG_CHOICE="php"
        ;;
    ts|typescript|node|javascript|js)
        LANG_CHOICE="ts"
        ;;
    *)
        echo "[ERROR] Unsupported language '$LANG_CHOICE'. Supported: python, go, rust, php, ts"
        exit 1
        ;;
esac

echo "=================================================="
echo "   Scaffolding agy-kit Developer Environment      "
echo "=================================================="
echo "Target Directory : $TARGET_DIR"
echo "Language Choice  : $LANG_CHOICE"
echo ""

mkdir -p "$TARGET_DIR/.antigravity/agents"
mkdir -p "$TARGET_DIR/.antigravity/skills"
mkdir -p "$TARGET_DIR/.antigravity/workflows"
mkdir -p "$TARGET_DIR/.githooks"
mkdir -p "$TARGET_DIR/skills"
mkdir -p "$TARGET_DIR/workflows"
mkdir -p "$TARGET_DIR/plans"
mkdir -p "$TARGET_DIR/docs"

# 1. Version file
cat << 'EOF' > "$TARGET_DIR/.antigravity/version.json"
{
  "version": "0.7.0",
  "schema_version": "2.0.0",
  "generator": "init-agy-kit.sh",
  "installed_at": "2026-08-06T00:00:00Z"
}
EOF

# 2. MCP JSON
cat << 'EOF' > "$TARGET_DIR/.antigravity/mcp.json"
{
  "mcpServers": {
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git"]
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
EOF

# 3. Subagent specs (.antigravity/agents/*.json)
cat << 'EOF' > "$TARGET_DIR/.antigravity/agents/planner.json"
{
  "name": "planner",
  "description": "Architect subagent responsible for codebase survey, SPEC creation, RTM & edge-case matrix.",
  "version": "2.0.0",
  "model": {
    "primary": "gemini-3.6-flash-high",
    "fallback": "gemini-3.6-flash-low"
  },
  "instructions": [
    "Survey codebase and write SPEC at plans/SPEC_<feature>.md.",
    "Produce RTM, DFD, NFR register entry, and 12-dimensional edge matrix.",
    "Propose at least 3 design variants and run grill-me self-stress testing."
  ],
  "tools": ["read_file", "write_file", "search_files", "terminal"]
}
EOF

cat << EOF > "$TARGET_DIR/.antigravity/agents/coder.json"
{
  "name": "coder",
  "description": "Senior Developer — implements features using strict TDD (RED -> GREEN -> REFACTOR) for $LANG_CHOICE.",
  "version": "2.0.0",
  "model": {
    "primary": "gemini-3.6-flash-high",
    "fallback": "gemini-3.6-flash-low"
  },
  "instructions": [
    "Execute TDD for $LANG_CHOICE: RED (failing tests) -> GREEN (pass tests) -> REFACTOR (clean code).",
    "Enforce L1 linter and L2 unit test gates. Auto-rollback after 3 failing attempts."
  ],
  "tools": ["read_file", "write_file", "search_files", "terminal", "patch"]
}
EOF

cat << EOF > "$TARGET_DIR/.antigravity/agents/reviewer.json"
{
  "name": "reviewer",
  "description": "Code and security reviewer auditing diffs, linters, and security scanners for $LANG_CHOICE.",
  "version": "2.0.0",
  "model": {
    "primary": "gemini-3.6-flash-high",
    "fallback": "gemini-3.6-flash-low"
  },
  "instructions": [
    "Audit git diff against OWASP-AI checklist and language quality standards.",
    "Verify 3-state verification (pre, action, post) and emit plan-review stamp."
  ],
  "tools": ["read_file", "search_files", "terminal", "patch"]
}
EOF

cat << EOF > "$TARGET_DIR/.antigravity/agents/qa.json"
{
  "name": "qa",
  "description": "QA subagent executing end-to-end integration and dogfooding test suites.",
  "version": "2.0.0",
  "model": {
    "primary": "gemini-3.6-flash-low",
    "fallback": "gemini-3.6-flash-high"
  },
  "instructions": [
    "Execute L4 E2E boundary test suites and record test evidence.",
    "Verify 100% of RTM acceptance criteria."
  ],
  "tools": ["read_file", "write_file", "search_files", "terminal"]
}
EOF

# 4. AGENTS.md tailored to language
cat << EOF > "$TARGET_DIR/AGENTS.md"
# AGENTS.md — agy-kit Project Rules ($LANG_CHOICE)

> **agy-kit scaffolded project** ($LANG_CHOICE) — rules, subagents, quality gates, and workflow contracts.

## 1. Planning First Rule
- Features touching >3 files or changing architecture MUST create \`plans/SPEC_<feature>.md\` first.
- Includes RTM, DFD, 12-dimensional edge matrix, and 3 design variants.

## 2. Test-Driven Development (TDD)
- Language: **$LANG_CHOICE**
- Cycle: RED -> GREEN -> REFACTOR.
- Unit test coverage target: >= 85% line, 75% branch.

## 3. Strict Quality Gates
- Gate L1: Zero linter/typecheck errors.
- Gate L2: All unit tests pass.
- Gate L3: Integration tests pass.
- Gate L4: E2E boundary tests pass.
- Gate L5: OWASP security audit & plan-review stamp approved.

## 4. Rollback & Reliability
- Git checkpoint created before code mutations.
- Maximum 3 retries on test failure before auto-rollback and escalation.
- Maximum 15 turns per subagent session.
EOF

# 5. Pre-commit hook (.githooks/pre-commit)
cat << 'EOF' > "$TARGET_DIR/.githooks/pre-commit"
#!/usr/bin/env bash
# agy-kit pre-commit quality gate hook
set -euo pipefail
echo "Executing agy-kit pre-commit quality check..."

# Secret scanning
if command -v gitleaks &>/dev/null; then
    gitleaks detect --staged --verbose
else
    git diff --cached | grep -iE '(api_key|password|secret|private_key)' && { echo "Error: Potential secret detected!"; exit 1; } || true
fi

echo "Pre-commit check passed!"
EOF
chmod +x "$TARGET_DIR/.githooks/pre-commit"

# 6. Core Skills & Workflows starters
cat << 'EOF' > "$TARGET_DIR/skills/ba-expert.md"
# Skill: Business Analysis Expert
Enforces SPEC, RTM, DFD, and 12-Dimensional Edge Case Matrix generation.
EOF

cat << 'EOF' > "$TARGET_DIR/workflows/pipeline.yml"
name: agy-kit-pipeline
steps:
  - plan
  - build
  - gate
  - qa
  - review
EOF

# 7. Language specific config file template
case "$LANG_CHOICE" in
    python)
        cat << 'EOF' > "$TARGET_DIR/pyproject.toml"
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.mypy]
strict = true
ignore_missing_imports = true

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --cov=src"
EOF
        ;;
    go)
        cat << 'EOF' > "$TARGET_DIR/golangci.yml"
run:
  timeout: 5m
linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
EOF
        cat << 'EOF' > "$TARGET_DIR/go.mod"
module example.com/app

go 1.22
EOF
        ;;
    rust)
        cat << 'EOF' > "$TARGET_DIR/Cargo.toml"
[package]
name = "example-app"
version = "0.1.0"
edition = "2021"

[dependencies]
EOF
        cat << 'EOF' > "$TARGET_DIR/clippy.toml"
avoid-breaking-exported-api = false
EOF
        ;;
    php)
        cat << 'EOF' > "$TARGET_DIR/composer.json"
{
  "name": "example/app",
  "description": "Scaffolded PHP Laravel Application",
  "require": {
    "php": "^8.2"
  },
  "require-dev": {
    "phpstan/phpstan": "^1.10",
    "phpunit/phpunit": "^10.0"
  }
}
EOF
        cat << 'EOF' > "$TARGET_DIR/phpstan.neon"
parameters:
  level: 8
  paths:
    - app
    - tests
EOF
        ;;
    ts)
        cat << 'EOF' > "$TARGET_DIR/package.json"
{
  "name": "example-express-app",
  "version": "1.0.0",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "test": "vitest run",
    "lint": "eslint ."
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "vitest": "^1.0.0",
    "eslint": "^8.0.0"
  }
}
EOF
        cat << 'EOF' > "$TARGET_DIR/tsconfig.json"
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist"
  },
  "include": ["src/**/*"]
}
EOF
        ;;
esac

echo "[SUCCESS] agy-kit successfully scaffolded in $TARGET_DIR ($LANG_CHOICE)!"
echo "Scaffolded files:"
echo "  - $TARGET_DIR/.antigravity/version.json"
echo "  - $TARGET_DIR/.antigravity/mcp.json"
echo "  - $TARGET_DIR/.antigravity/agents/{planner,coder,reviewer,qa}.json"
echo "  - $TARGET_DIR/AGENTS.md"
echo "  - $TARGET_DIR/.githooks/pre-commit"
echo "  - $TARGET_DIR/skills/ba-expert.md"
echo "  - $TARGET_DIR/workflows/pipeline.yml"
