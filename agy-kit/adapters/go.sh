#!/usr/bin/env bash
# agy-kit Go Adapter
set -euo pipefail

echo "🐹 Running Go adapter checks..."
if [ -f go.mod ]; then
    go test ./...
else
    echo "No go.mod found; skipping Go adapter."
fi
