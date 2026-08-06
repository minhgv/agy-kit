# agy-kit Configuration for Python / FastAPI Projects

This directory provides guidance and standard configuration templates for Python / FastAPI projects applying the `agy-kit` toolset.

## Configuration Structure

```text
python_fastapi_config_example/
├── .antigravity/
│   ├── agents/
│   │   ├── planner.json      # Architect agent survey & SPEC creation
│   │   ├── coder.json        # TDD implementation agent
│   │   ├── reviewer.json     # Code review, ruff, mypy, gitleaks audit
│   │   └── qa.json           # pytest & httpx E2E test runner
│   └── mcp.json              # MCP server mappings for python tooling
├── .pre-commit-config.yaml   # Git hooks with ruff, mypy, gitleaks
├── pyproject.toml            # Python tool configurations (ruff, mypy, pytest)
└── README.md
```

## Required Tools & Linters

- **Linter & Formatter:** `ruff` (Extremely fast, replaces flake8, black, isort).
- **Static Type Checker:** `mypy` (Strict mode for type annotations).
- **Test Runner & Coverage:** `pytest`, `pytest-cov`, `httpx` (Asynchronous API client testing).
- **Security Audit:** `gitleaks` (Scans hardcoded API keys), `bandit` (Python security issues).

## Subagent Configurations

### 1. `coder.json` (Senior Dev - TDD Implementation)
```json
{
  "$schema": "https://antigravity.google/schemas/agent.json",
  "name": "coder",
  "description": "Senior Python Developer executing TDD workflow (RED -> GREEN -> REFACTOR)",
  "version": "1.1.0",
  "model": {
    "primary": "gemini-3.6-flash-high",
    "temperature": 0.2
  },
  "instructions": [
    "You are a Senior Python FastAPI Developer following strict Test-Driven Development (TDD).",
    "Step 1 (RED): Write tests in tests/ before writing implementation code. Run pytest to confirm tests FAIL.",
    "Step 2 (GREEN): Write minimal implementation in app/ until pytest passes.",
    "Step 3 (REFACTOR): Clean up code, run ruff check app/ --fix and mypy app/.",
    "Never use raw string formatting for SQL or execute untyped code."
  ],
  "tools": [
    "read_file",
    "write_file",
    "patch",
    "search_files",
    "terminal"
  ],
  "permissions": {
    "allowed_commands": [
      "pytest*",
      "ruff*",
      "mypy*",
      "python*",
      "git diff*"
    ]
  }
}
```

### 2. `reviewer.json` (Principal Reviewer - Security & Code Audit)
```json
{
  "$schema": "https://antigravity.google/schemas/agent.json",
  "name": "reviewer",
  "description": "Principal Security & Code Reviewer auditing FastAPI code and git diffs",
  "version": "1.1.0",
  "model": {
    "primary": "gemini-3.6-flash-high",
    "temperature": 0.1
  },
  "instructions": [
    "Audits git diff and enforces python quality gates.",
    "Must execute: ruff check ., mypy src/, and gitleaks detect --staged.",
    "Verify OWASP-AI checklist: no package hallucination, parameterized queries, secret scans.",
    "Return approval status (PASS/FAIL) with exact file and line references for findings."
  ],
  "tools": [
    "read_file",
    "search_files",
    "terminal",
    "patch"
  ],
  "permissions": {
    "allowed_commands": [
      "ruff check*",
      "mypy*",
      "gitleaks*",
      "bandit*",
      "git diff*"
    ]
  }
}
```

## Setup & Execution Commands

```bash
# 1. Initialize virtualenv & install dependencies
uv venv && source .venv/bin/activate
uv pip install fastapi uvicorn pytest pytest-cov httpx ruff mypy bandit

# 2. Run TDD pipeline using agy-kit
agy run --agent coder "Read plans/SPEC_user_registration.md. Implement TDD for register feature"

# 3. Run Quality Gate audit
agy run --agent reviewer "Audit git diff, run ruff, mypy, and gitleaks"
```
