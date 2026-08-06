---
description: "Full 5-step agentic pipeline — Plan → TDD → Quality Gate → E2E QA → Review & Commit. Auto-runs all steps sequentially."
---

# /pipeline

Execute the complete 5-step agentic engineering workflow for a feature.

## Steps

### Step 1: Plan
```bash
// turbo
agy run --agent plan "Survey the relevant module and create a SPEC at plans/SPEC_$(FEATURE).md following SPEC_TEMPLATE.md. Include: goals/non-goals, data flow, file mutation manifest, test plan, definition of done."
```

### Step 2: TDD Implementation
```bash
// turbo
agy run --agent coder "Read plans/SPEC_$(FEATURE).md. Execute TDD: RED (write tests, verify FAIL) → GREEN (write minimal logic, verify PASS) → REFACTOR. Only modify files listed in the File Mutation Manifest."
```

### Step 3: Quality Gate
```bash
// turbo
agy run --agent reviewer "Run lint + typecheck. Scan with gitleaks. Check OWASP-AI 5-item checklist. Fix all issues found. Report: 0 errors, 0 warnings, 0 secrets."
```

### Step 4: E2E QA
```bash
// turbo
agy run --agent qa "Start local server. Run cURL/Playwright tests according to the Test Plan in SPEC. Collect evidence into tests/qa-evidence/."
```

### Step 5: Review & Commit
```bash
// turbo
agy run --agent reviewer "Review git diff. Check for: leftover debug logs, out-of-scope files, API contract changes, test coverage. Group commits using Conventional Commits."
```
