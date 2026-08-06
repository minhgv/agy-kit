#!/usr/bin/env bash
# safe-agent-run.sh — Isolated Git Worktree Execution & Safe Stage Runner for agy-kit
#
# Usage: ./bin/safe-agent-run.sh <stage> <feature> "<prompt>" [apply_to_primary=true|false]
# Example: ./bin/safe-agent-run.sh coder auth-oauth2 "Implement OAuth2 refresh token" false

set -euo pipefail

STAGE="${1:?Usage: $0 <stage> <feature> '<prompt>' [apply_to_primary]}"
FEATURE="${2:?Feature name required}"
PROMPT="${3:?Prompt required}"
APPLY_TO_PRIMARY="${4:-false}"
AGY_FLAGS="${AGY_FLAGS:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

BASELINE_SHA=$(git -C "$PROJECT_ROOT" rev-parse HEAD)
RUN_ID="run-$(date +%s)-$RANDOM"
WORKTREE_DIR=$(mktemp -d -t "agy-wt-${RUN_ID}-XXXXXX")
WORKTREE_BRANCH="agy-worktree-${FEATURE}-${RUN_ID}"

echo "🔒 Creating isolated Git worktree at: $WORKTREE_DIR (Baseline: ${BASELINE_SHA:0:7})"

# Trap cleanup to guarantee worktree removal without touching primary worktree
cleanup() {
    local exit_code=$?
    if [ -d "$WORKTREE_DIR" ]; then
        echo "🧹 Removing isolated worktree at $WORKTREE_DIR..."
        git -C "$PROJECT_ROOT" worktree remove --force "$WORKTREE_DIR" 2>/dev/null || true
        git -C "$PROJECT_ROOT" branch -D "$WORKTREE_BRANCH" 2>/dev/null || true
    fi
    if [ $exit_code -ne 0 ]; then
        echo "❌ Stage $STAGE failed or was interrupted. Primary worktree remains unchanged."
    fi
    exit $exit_code
}
trap cleanup EXIT INT TERM

# Create isolated detached worktree from baseline SHA
git -C "$PROJECT_ROOT" worktree add -b "$WORKTREE_BRANCH" "$WORKTREE_DIR" "$BASELINE_SHA" >/dev/null

run_tests_in_worktree() {
    local max_attempts=3
    local attempt=1
    local delay=1

    while [ $attempt -le $max_attempts ]; do
        echo "🧪 Running test verification inside worktree (Attempt $attempt/$max_attempts)..."
        local TEST_FAILED=false
        local TEST_OUTPUT=""

        if command -v pytest &>/dev/null && [ -d "$WORKTREE_DIR/tests" ]; then
            TEST_OUTPUT=$(cd "$WORKTREE_DIR" && pytest --tb=short 2>&1) || TEST_FAILED=true
        elif command -v npm &>/dev/null && [ -f "$WORKTREE_DIR/package.json" ]; then
            TEST_OUTPUT=$(cd "$WORKTREE_DIR" && npm test 2>&1) || TEST_FAILED=true
        elif command -v go &>/dev/null && [ -f "$WORKTREE_DIR/go.mod" ]; then
            TEST_OUTPUT=$(cd "$WORKTREE_DIR" && go test ./... 2>&1) || TEST_FAILED=true
        elif command -v cargo &>/dev/null && [ -f "$WORKTREE_DIR/Cargo.toml" ]; then
            TEST_OUTPUT=$(cd "$WORKTREE_DIR" && cargo test 2>&1) || TEST_FAILED=true
        fi

        if [ "$TEST_FAILED" = false ]; then
            echo "$TEST_OUTPUT"
            return 0
        fi

        echo "⚠️ Test attempt $attempt failed."
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

echo "🤖 Executing agent stage [$STAGE] in isolated worktree..."
cd "$WORKTREE_DIR"

if ! agy -p "[$STAGE] $PROMPT" $AGY_FLAGS; then
    echo "❌ Agent execution failed inside worktree."
    exit 1
fi

# Multi-Agent Workspace Path Boundary Check
if [ -f "$PROJECT_ROOT/bin/check-path-boundaries.sh" ]; then
    bash "$PROJECT_ROOT/bin/check-path-boundaries.sh" "$STAGE" "$WORKTREE_DIR"
fi

# Verify tests pass inside worktree
if ! run_tests_in_worktree; then
    echo "❌ Test verification failed inside worktree."
    exit 1
fi

# Package patch or apply if explicitly requested
PATCH_FILE="$PROJECT_ROOT/plans/patch-${FEATURE}-${RUN_ID}.patch"
mkdir -p "$PROJECT_ROOT/plans"
git -C "$WORKTREE_DIR" diff "$BASELINE_SHA" > "$PATCH_FILE"
echo "📦 Produced evidence patch at: $PATCH_FILE"

if [ "$APPLY_TO_PRIMARY" = "true" ]; then
    echo "⚡ Applying patch to primary worktree as explicitly requested..."
    git -C "$PROJECT_ROOT" apply "$PATCH_FILE"
fi

echo "✅ $STAGE completed successfully for feature: $FEATURE"
