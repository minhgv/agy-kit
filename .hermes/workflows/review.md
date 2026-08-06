---
description: "Review git diff, check DRY/SOLID/security, invoke qa-auditor & ba-expert skills for 3-State Verification and RTM completion, then create Conventional Commits."
---

# /review

Review all changes, run requirement traceability validation, apply 3-State Verification, and create commits.

## Steps

### Step 1: Pre-Commit Diff & Traceability Audit
```bash
./bin/validate-traceability.sh
```

Invoke the **`reviewer`** subagent (`.agents/agents/reviewer.md`):
- Load the `qa-auditor` and `ba-expert` skills to execute:
  1. PRE-COMMIT DIFF AUDIT — check 5 criteria:
     - Any leftover debug logs (`console.log`, `print`, `dd`, `dump`)?
     - Any files modified OUTSIDE the File Mutation Manifest (SPEC)?
     - Any changes to function signatures or response schemas?
     - Naming and error handling consistent with codebase?
     - Tests written for all new code paths and 12-Dimensional Edge Cases?
  2. THREE-STATE VERIFICATION — classify each concern & RTM item:
     - CONFIRMED (tested/observed): issue or requirement verified (cite line number + trigger path)
     - PLAUSIBLE (declared): needs more testing or observation to confirm
     - REFUTED: not an issue (cite why)
  3. CONVENTIONAL COMMITS — group changed files into meaningful commits:
     - `feat:`, `fix:`, `test:`, `docs:`, `refactor:`, `chore:`
     - DO NOT commit single files one by one.
