#!/usr/bin/env bash
# safe-agent-run.sh — Run agy stage with auto-rollback safety net
#
# Usage: ./bin/safe-agent-run.sh <stage> <feature> "<prompt>"
# Example: ./bin/safe-agent-run.sh coder auth-oauth2 "Implement OAuth2 refresh token"

set -euo pipefail

STAGE="${1:?Usage: $0 <stage> <feature> '<prompt>'}"
FEATURE="${2:?Feature name required}"
PROMPT="${3:?Prompt required}"

# Pre-checkpoint
CHECKPOINT_MSG="checkpoint: pre-${STAGE}-${FEATURE}-$(date +%s)"
git stash push -m "$CHECKPOINT_MSG" 2>/dev/null || git commit -am "$CHECKPOINT_MSG" --allow-empty 2>/dev/null || true
echo "📌 Checkpoint created: $CHECKPOINT_MSG"

# Run agent stage
if ! agy run --agent "$STAGE" "$PROMPT"; then
    echo "❌ Agent $STAGE failed. Rolling back to checkpoint..."
    git stash pop 2>/dev/null || git reset --hard HEAD~1 2>/dev/null || true
    exit 1
fi

# Verify tests pass (auto-detect test runner)
echo "🧪 Running test verification..."
TEST_FAILED=false
if command -v pytest &>/dev/null && [ -d tests ]; then
    pytest --tb=short || TEST_FAILED=true
elif command -v npm &>/dev/null && [ -f package.json ]; then
    npm test || TEST_FAILED=true
elif command -v go &>/dev/null && [ -f go.mod ]; then
    go test ./... || TEST_FAILED=true
elif command -v cargo &>/dev/null && [ -f Cargo.toml ]; then
    cargo test || TEST_FAILED=true
fi

if [ "$TEST_FAILED" = true ]; then
    echo "❌ Tests failed after $STAGE. Rolling back to checkpoint..."
    git stash pop 2>/dev/null || git reset --hard HEAD~1 2>/dev/null || true
    echo "💡 Codebase restored. Review errors and retry."
    exit 1
fi

echo "✅ $STAGE completed successfully for feature: $FEATURE"
