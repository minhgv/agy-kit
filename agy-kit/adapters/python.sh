#!/usr/bin/env bash
# agy-kit Python Adapter
set -euo pipefail

echo "🐍 Running Python adapter checks..."
if command -v pytest &>/dev/null; then
    pytest --tb=short
else
    python3 -m unittest discover -s tests
fi
