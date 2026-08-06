#!/usr/bin/env bash
# agy-kit TypeScript Adapter
set -euo pipefail

echo "🟦 Running TypeScript adapter checks..."
if [ -f package.json ]; then
    npm test
else
    echo "No package.json found; skipping TypeScript adapter."
fi
