---
description: "Rollback-aware pipeline — runs 5 stages with auto-rollback on test failure at each stage."
---

# /safe-pipeline

Full 5-step pipeline with git checkpoint + auto-rollback safety net.

## Steps

### Step 0: Create Git Checkpoint
```bash
// turbo
git stash push -m "pre-pipeline-$(date +%s)" || git commit -am "checkpoint: pre-pipeline" --allow-empty
```

### Step 1: Plan
```bash
// turbo
agy run --agent plan "Survey and create SPEC for $ARGUMENTS at plans/SPEC_$(echo $ARGUMENTS | tr ' ' '-').md"
```

### Step 2: TDD (with rollback on failure)
```bash
// turbo
./bin/safe-agent-run.sh coder "$ARGUMENTS" "Read SPEC. Execute TDD: RED → GREEN → REFACTOR."
```

### Step 3: Quality Gate (with rollback on lint failure)
```bash
// turbo
agy run --agent reviewer "Lint + typecheck + gitleaks + OWASP-AI checklist. Fix all issues."
```

### Step 4: E2E QA (with rollback on test failure)
```bash
// turbo
agy run --agent qa "Start local server. Run E2E test. Collect evidence."
```

### Step 5: Review & Commit
```bash
// turbo
agy run --agent reviewer "Pre-commit diff audit + 3-state verification + Conventional Commits."
```
