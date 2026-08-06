# Rollback & Recovery — Transactional Code Modifications

> Ensures the codebase always returns to a clean state if the agent pipeline fails.

## Git Checkpointing Workflow

### Before subagent modifies code:
```bash
# Create checkpoint
git stash push -m "pre-agent-checkpoint-$(date +%s)" || \
git commit -am "checkpoint: pre-coder" --allow-empty
```

### After subagent modifies code:
```bash
# Run test runner
npm test  # or pytest, go test, cargo test

# If test FAILS (exit code != 0):
git reset --hard HEAD~1  # or git stash pop
# → Codebase returns to original clean state
```

## Auto-Rollback on Test Failure

```bash
#!/usr/bin/env bash
# bin/safe-agent-run.sh — Run agy with auto-rollback safety net

set -euo pipefail
STAGE="$1"
FEATURE="$2"

# Pre-checkpoint
git stash push -u -m "pre-${STAGE}-${FEATURE}" 2>/dev/null || true

# Run agent stage
if ! agy -p "[$STAGE] $3" --dangerously-skip-permissions; then
    echo "❌ Agent $STAGE failed. Rolling back..."
    git reset --hard HEAD && git clean -fd
    exit 1
fi

# Verify (test must pass)
if ! npm test 2>/dev/null || ! pytest 2>/dev/null; then
    echo "❌ Tests failed after $STAGE. Rolling back..."
    git reset --hard HEAD && git clean -fd
    exit 1
fi

echo "✅ $STAGE completed successfully."
```

## Loop Prevention Rules

| Rule | Threshold | Action |
|------|-----------|--------|
| Max retries per failing test | 3 attempts | STOP, escalate to human |
| Max turns per session | 15 turns | Auto-exit, save checkpoint |
| Token budget soft cap | 75-80% | Warn agent: summarize + finalize |
| Token budget hard cap | 100% | Force-exit session |
| Context compaction trigger | 85% of context window | 4-stage compression or downgrade model |

## Session Crash Recovery

State saved at `.antigravity/checkpoints/state.json`:
```json
{
  "feature": "auth-oauth2",
  "last_completed_stage": "plan",
  "next_stage": "build",
  "git_checkpoint": "abc1234",
  "timestamp": "2026-08-06T02:00:00Z"
}
```

When resuming: read state → jump to `next_stage` → restore `git_checkpoint`.

## Clean Slate Retry Pattern

Instead of fixing on top of broken code:
1. Rollback code to a clean checkpoint
2. Pass error logs from the previous run into the next prompt
3. Agent retries from scratch with information about the occurred error
