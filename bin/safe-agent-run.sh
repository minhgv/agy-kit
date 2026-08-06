#!/usr/bin/env bash
# safe-agent-run.sh — Run agy stage with auto-rollback safety net & flaky test retry logic
#
# Usage: ./bin/safe-agent-run.sh <stage> <feature> "<prompt>"
# Example: ./bin/safe-agent-run.sh coder auth-oauth2 "Implement OAuth2 refresh token"

set -euo pipefail

STAGE="${1:?Usage: $0 <stage> <feature> '<prompt>'}"
FEATURE="${2:?Feature name required}"
PROMPT="${3:?Prompt required}"

# Function to run tests with exponential backoff and pattern checking
run_tests_with_retry() {
    local max_attempts=3
    local attempt=1
    local delay=1

    while [ $attempt -le $max_attempts ]; do
        echo "🧪 Running test verification (Attempt $attempt/$max_attempts)..."
        local TEST_FAILED=false
        local TEST_OUTPUT=""

        if command -v pytest &>/dev/null && [ -d tests ]; then
            TEST_OUTPUT=$(pytest --tb=short 2>&1) || TEST_FAILED=true
        elif command -v npm &>/dev/null && [ -f package.json ]; then
            TEST_OUTPUT=$(npm test 2>&1) || TEST_FAILED=true
        elif command -v go &>/dev/null && [ -f go.mod ]; then
            TEST_OUTPUT=$(go test ./... 2>&1) || TEST_FAILED=true
        elif command -v cargo &>/dev/null && [ -f Cargo.toml ]; then
            TEST_OUTPUT=$(cargo test 2>&1) || TEST_FAILED=true
        fi

        if [ "$TEST_FAILED" = false ]; then
            echo "$TEST_OUTPUT"
            return 0
        fi

        echo "⚠️ Test attempt $attempt failed."
        # Check against failure memory patterns
        if [ -f .antigravity/failure_memory.json ]; then
            if echo "$TEST_OUTPUT" | grep -iqE "(ECONNREFUSED|address already in use|ResourceTemporarilyUnavailable)"; then
                echo "⚡ Known transient/flaky failure pattern detected! Retrying in ${delay}s..."
            fi
        fi

        if [ $attempt -lt $max_attempts ]; then
            sleep $delay
            delay=$((delay * 2))
            attempt=$((attempt + 1))
        else
            echo "$TEST_OUTPUT"
            return 1
        fi
    done
}

# Pre-checkpoint using git stash push -u (including untracked files)
CHECKPOINT_MSG="checkpoint: pre-${STAGE}-${FEATURE}-$(date +%s)"
HAS_STASH=false
if [ -n "$(git status --porcelain)" ]; then
    git stash push -u -m "$CHECKPOINT_MSG" 2>/dev/null || true
    HAS_STASH=true
    # Re-apply index so workspace stays intact for current run while maintaining stash checkpoint
    git stash apply --index 2>/dev/null || git stash apply 2>/dev/null || true
fi
echo "📌 Checkpoint created: $CHECKPOINT_MSG"

rollback_worktree() {
    echo "❌ Execution/verification failed. Safely rolling back worktree..."
    git reset --hard HEAD 2>/dev/null || true
    git clean -fd 2>/dev/null || true
    if [ "$HAS_STASH" = true ]; then
        git stash pop 2>/dev/null || true
    fi
}

# Run agent stage using official agy CLI syntax
if ! agy -p "[$STAGE] $PROMPT" --dangerously-skip-permissions; then
    rollback_worktree
    exit 1
fi

# Multi-Agent Workspace Path Boundary Check
if [ -f ./bin/check-path-boundaries.sh ]; then
    bash ./bin/check-path-boundaries.sh "$STAGE"
fi

# Verify tests pass with exponential backoff & failure memory check
if ! run_tests_with_retry; then
    rollback_worktree
    echo "💡 Codebase restored. Review errors and retry."
    exit 1
fi

# If succeeded and we created a checkpoint stash, drop the temporary stash
if [ "$HAS_STASH" = true ]; then
    git stash drop 2>/dev/null || true
fi

echo "✅ $STAGE completed successfully for feature: $FEATURE"
