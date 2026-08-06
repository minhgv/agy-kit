---
description: "Run quality gate only — lint, typecheck, gitleaks, OWASP security scan on current changes."
---

# /gate

Run the Quality Gate audit on current changes.

## Steps

### Step 1: Security & Quality Audit
```bash
// turbo
agy run --agent reviewer "Execute Quality Gate Audit:
1. LINT & TYPECHECK: Run linter and type checker. Fix all warnings/errors.
2. SECRET SCAN: Run gitleaks on staged diff. If secrets found → remove + patch.
3. OWASP-AI CHECKLIST:
   - OWASP-AI-01: Verify imports against lockfiles
   - OWASP-AI-02: Check authorization on endpoints
   - OWASP-AI-03: No SQL injection / shell=True
   - OWASP-AI-04: No hardcoded credentials
   - OWASP-AI-05: Least-privilege tool execution
4. Report pass/fail for each item."
```
