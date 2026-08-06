---
description: "Run E2E QA tests — start local server, send cURL/Playwright tests, collect evidence."
---

# /qa

Chạy E2E QA testing trên local server.

## Steps

### Step 1: Dogfooding QA
```bash
// turbo
agy run --agent qa "Thực hiện dogfooding test:
1. Khởi chạy local dev server (nếu chưa chạy). Verify health-check.
2. Chạy test cases theo Test Plan trong plans/SPEC_*.md:
   - Case 1: Valid payload → HTTP 200/201
   - Case 2: Missing/wrong fields → HTTP 400/422
   - Case 3: SQL injection / XSS payload → HTTP 400/422
   - Case 4: Unauthorized / expired token → HTTP 401/403
3. Thu thập cURL output, response headers, server logs vào tests/qa-evidence/.
4. Báo cáo pass/fail per case."
```
