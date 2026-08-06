---
description: "Rollback-aware pipeline with BA & QA skills suite — runs 5 stages with auto-rollback on test failure at each stage, verifying RTM and 12-Dimensional Edge Cases."
---

# /safe-pipeline

Full 5-step pipeline with BA & QA skills, git checkpoint, and auto-rollback safety net.

## Steps

### Step 0: Create Git Checkpoint
```bash
// turbo
git stash push -m "pre-pipeline-$(date +%s)" || git commit -am "checkpoint: pre-pipeline" --allow-empty
```

### Step 1: Plan (BA Expert & RTM)
```bash
// turbo
agy run --agent plan "Survey and create SPEC for $ARGUMENTS at plans/SPEC_$(echo $ARGUMENTS | tr ' ' '-').md. Invoke 'ba-expert' skill to construct RTM, 12-Dimensional Edge Case Matrix, NFRs, and DFD. Run ./bin/validate-traceability.sh."
```

### Step 2: TDD (QA Test Gen with rollback on failure)
```bash
// turbo
./bin/safe-agent-run.sh coder "$ARGUMENTS" "Read SPEC. Invoke 'qa-test-gen' skill. Execute TDD: RED → GREEN → REFACTOR covering RTM and 12-Dimensional Edge Cases."
```

### Step 3: Quality Gate Audit (QA Auditor & Dependency Scan)
```bash
// turbo
./bin/scan-dependencies.sh
agy run --agent reviewer "Invoke 'qa-auditor' skill. Lint + typecheck + gitleaks + OWASP-AI checklist. Run ./bin/validate-traceability.sh. Fix all issues."
```

### Step 4: E2E QA (QA Reproducer with rollback on failure)
```bash
// turbo
agy run --agent qa "Start local server. Invoke 'qa-reproducer' skill for MRE pipeline. Run E2E test covering 12-Dimensional edge cases. Collect evidence."
```

### Step 5: Review & Commit (3-State Verification)
```bash
// turbo
agy run --agent reviewer "Invoke 'qa-auditor' and 'ba-expert' skills. Pre-commit diff audit + 3-State Verification + RTM audit + Conventional Commits."
```
