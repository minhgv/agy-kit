---
description: "Run quality gate only — lint, typecheck, gitleaks, OWASP security scan on current changes."
---

# /gate

Chạy Quality Gate audit cho các thay đổi hiện tại.

## Steps

### Step 1: Security & Quality Audit
```bash
// turbo
agy run --agent reviewer "Thực hiện Quality Gate Audit:
1. LINT & TYPECHECK: Chạy linter và type checker. Sửa mọi warning/error.
2. SECRET SCAN: Chạy gitleaks trên staged diff. Nếu phát hiện secret → remove + patch.
3. OWASP-AI CHECKLIST:
   - OWASP-AI-01: Verify imports against lockfiles
   - OWASP-AI-02: Check authorization trên endpoints
   - OWASP-AI-03: No SQL injection / shell=True
   - OWASP-AI-04: No hardcoded credentials
   - OWASP-AI-05: Least-privilege tool execution
4. Báo cáo pass/fail cho từng item."
```
