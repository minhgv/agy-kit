# Getting Started Guide: From Zero to First Feature with agy-kit

Welcome to **agy-kit** — an Agent Engineering Kit optimized for the Antigravity CLI (`agy`). This tutorial will guide you from scratch to fully deploying a REST API feature following the standard 5 steps.

---

## 📋 Environment Setup

System requirements:
- Antigravity CLI (`agy`) v2.0 or higher
- Git & Python 3.11+ (or Node.js / Go depending on your stack)
- `uv` library (for Python) or `npm` / `pnpm` (for JS/TS)

```bash
# 1. Install agy-kit into your project
mkdir my-api-service && cd my-api-service
git init

# Clone agy-kit scaffold
git clone https://github.com/vudovn/agy-kit.git /tmp/agy-kit
cp -r /tmp/agy-kit/{AGENTS.md,GEMINI.md,.antigravity,plans,Makefile,.gitleaks.toml} .
rm -rf /tmp/agy-kit
```

---

## 5 Steps to Build a Feature: `GET /api/v1/healthcheck`

---

### Step 1: Planning & Writing SPEC (`Planner Agent`)

Core rule of agy-kit: **Do not type a single line of code before a SPEC is approved.**

```bash
agy run --agent plan "Inspect the project and create a SPEC for the GET /api/v1/healthcheck feature returning status OK, uptime, and version. Save at plans/SPEC_healthcheck.md"
```

The `planner` agent will inspect the codebase and automatically generate `plans/SPEC_healthcheck.md` with full Use-cases, API schema, and File Mutation Manifest.

---

### Step 2: TDD Red-Green-Refactor Implementation (`Coder Agent`)

Trigger the `coder` subagent to perform TDD:

```bash
agy run --agent coder "Read plans/SPEC_healthcheck.md. Perform TDD: Write RED test first in tests/test_healthcheck.py, run test to confirm FAIL. Then write GREEN logic in app/main.py. Finally Refactor."
```

**Coder Agent Execution Process:**
1. Create `tests/test_healthcheck.py` checking status 200 and response JSON `{"status": "ok"}`.
2. Run `pytest` -> Test **FAIL (RED)** (because endpoint does not exist yet).
3. Edit `app/main.py` adding `GET /api/v1/healthcheck` router.
4. Re-run `pytest` -> Test **PASS (GREEN)**.
5. Automatically run `ruff check app/` and `mypy app/` for clean refactoring.

---

### Step 3: Running Quality Gate Control (`Reviewer Agent`)

Before committing, run security audit and linting:

```bash
agy run --agent reviewer "Audit current git diff. Run ruff check, mypy strict, and scan secrets with gitleaks. Check OWASP-AI checklist."
```

Reviewer Agent will check:
- Are there any hardcoded API keys / passwords in the code?
- Are type hints missing?
- Are there untested functions?

---

### Step 4: E2E Dogfooding Testing (`QA Agent`)

Allow QA Agent to start real server and cURL test directly:

```bash
agy run --agent qa "Start FastAPI app using uvicorn. Run cURL test for endpoint GET /api/v1/healthcheck. Collect evidence of HTTP headers and status code."
```

QA Agent will output E2E evidence log:
```text
HTTP/1.1 200 OK
content-type: application/json
date: Thu, 06 Aug 2026 02:25:00 GMT

{"status": "ok", "uptime": 12.4, "version": "1.0.0"}
```

---

### Step 5: Review & Commit Following Convention (`Reviewer Agent`)

When all quality gates pass, proceed to group standard commit:

```bash
git add .
agy run --agent review "Create git commit formatted according to Conventional Commits for healthcheck feature"
```

Commit result:
```text
feat(healthcheck): add GET /api/v1/healthcheck endpoint with uptime and version
```

---

## 🎯 Summary Cheatsheet

| Phase | Corresponding `agy` Command | Output Artifact |
|-------|----------------------|-----------------|
| **1. Plan** | `agy run --agent plan "..."` | `plans/SPEC_<feature>.md` |
| **2. TDD** | `agy run --agent coder "..."` | Unit/Integration Tests + Source code |
| **3. Gate** | `agy run --agent reviewer "..."` | Lint / Typecheck / Security Audit Report |
| **4. QA** | `agy run --agent qa "..."` | E2E cURL logs & Dogfooding Evidence |
| **5. Commit** | `agy run --agent review "..."` | Git commit Conventional Commits |
