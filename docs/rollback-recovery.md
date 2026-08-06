# Rollback & Recovery — Transactional Code Modifications

> Đảm bảo codebase luôn về trạng thái sạch nếu agent pipeline thất bại.

## Git Checkpointing Workflow

### Trước khi subagent can thiệp code:
```bash
# Tạo checkpoint
git stash push -m "pre-agent-checkpoint-$(date +%s)" || \
git commit -am "checkpoint: pre-coder" --allow-empty
```

### Sau khi subagent sửa code:
```bash
# Chạy test runner
npm test  # hoặc pytest, go test, cargo test

# Nếu test FAIL (exit code != 0):
git reset --hard HEAD~1  # hoặc git stash pop
# → Codebase về trạng thái nguyên bản sạch
```

## Auto-Rollback on Test Failure

```bash
#!/usr/bin/env bash
# bin/safe-agent-run.sh — Run agy with auto-rollback safety net

set -euo pipefail
STAGE="$1"
FEATURE="$2"

# Pre-checkpoint
git stash push -m "pre-${STAGE}-${FEATURE}" 2>/dev/null || true

# Run agent stage
if ! agy run --agent "$STAGE" "$3"; then
    echo "❌ Agent $STAGE failed. Rolling back..."
    git stash pop 2>/dev/null || git reset --hard HEAD~1
    exit 1
fi

# Verify (test must pass)
if ! npm test 2>/dev/null || ! pytest 2>/dev/null; then
    echo "❌ Tests failed after $STAGE. Rolling back..."
    git stash pop 2>/dev/null || git reset --hard HEAD~1
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

State lưu tại `.antigravity/checkpoints/state.json`:
```json
{
  "feature": "auth-oauth2",
  "last_completed_stage": "plan",
  "next_stage": "build",
  "git_checkpoint": "abc1234",
  "timestamp": "2026-08-06T02:00:00Z"
}
```

Khi resume: đọc state → jump đến `next_stage` → restore `git_checkpoint`.

## Clean Slate Retry Pattern

Thay vì sửa trên nền code hỏng:
1. Rollback code về checkpoint sạch
2. Gửi log lỗi của lần chạy trước vào prompt tiếp theo
3. Agent làm lại từ đầu với thông tin về lỗi đã xảy ra
