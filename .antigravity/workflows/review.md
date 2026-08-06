---
description: "Review git diff, check DRY/SOLID/security, and create Conventional Commits. Run before pushing."
---

# /review

Review all changes and create commits.

## Steps

### Step 1: Pre-Commit Diff Audit
```bash
// turbo
agy run --agent reviewer "You are a Principal Code Reviewer. Execute:

1. PRE-COMMIT DIFF AUDIT — check 5 criteria:
   - Any leftover debug logs (console.log, print, dd, dump)?
   - Any files modified OUTSIDE the File Mutation Manifest (SPEC)?
   - Any changes to function signatures or response schemas?
   - Naming and error handling consistent with codebase?
   - Tests written for all new code paths?

2. THREE-STATE VERIFICATION — classify each concern:
   - CONFIRMED: issue exists (cite line number + trigger path)
   - PLAUSIBLE: needs more testing to confirm
   - REFUTED: not an issue (cite why)

3. CONVENTIONAL COMMITS — group changed files into meaningful commits:
   - feat:, fix:, test:, docs:, refactor:, chore:
   - DO NOT commit single files one by one."
```
