---
description: "Run E2E QA tests — start local server, send cURL/Playwright tests, collect evidence."
---

# /qa

Run E2E QA testing on a local server.

## Steps

### Step 1: Dogfooding QA
```bash
// turbo
agy run --agent qa "Execute dogfooding test:
1. Start local dev server (if not running). Verify health-check.
2. Run test cases according to the Test Plan in plans/SPEC_*.md:
   - Case 1: Valid payload → HTTP 200/201
   - Case 2: Missing/wrong fields → HTTP 400/422
   - Case 3: SQL injection / XSS payload → HTTP 400/422
   - Case 4: Unauthorized / expired token → HTTP 401/403
3. Collect cURL output, response headers, server logs into tests/qa-evidence/.
4. Report pass/fail per case."
```
