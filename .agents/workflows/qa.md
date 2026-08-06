---
description: "Run E2E QA tests using qa-test-gen & qa-reproducer skills — start local server, send cURL/Playwright tests, reproduce bugs with MRE pipeline, collect evidence, and audit RTM."
---

# /qa

Run E2E QA testing on a local server using 'qa-test-gen' and 'qa-reproducer' skills suite.

## Steps

### Step 1: Dogfooding QA & Bug Reproduction (qa-reproducer & qa-test-gen)
```bash
// turbo
agy run --agent qa "Execute dogfooding test suite using 'qa-test-gen' and 'qa-reproducer' skills:
1. Start local dev server (if not running). Verify health-check.
2. Run test cases according to the Test Plan in plans/SPEC_*.md covering the 12-Dimensional Edge Case Matrix:
   - Case 1: Valid payload → HTTP 200/201
   - Case 2: Missing/wrong fields → HTTP 400/422
   - Case 3: SQL injection / XSS payload → HTTP 400/422
   - Case 4: Unauthorized / expired token → HTTP 401/403
   - Case 5: 12-Dimensional Edge Cases (Unicode, Concurrency, Boundary, Timezone, Scale, Network failure)
3. For any failures, invoke 'qa-reproducer' to build Minimal Reproduction Examples (MRE) and format JSON Bug Reproduction Schema.
4. Collect cURL output, response headers, server logs into tests/qa-evidence/.
5. Report pass/fail per case."
```

### Step 2: Traceability & RTM Update
```bash
// turbo
./bin/validate-traceability.sh
```
