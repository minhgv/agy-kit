#!/usr/bin/env bash
# agy-kit PHP Adapter
set -euo pipefail

echo "🐘 Running PHP adapter checks..."
if [ -f composer.json ]; then
    vendor/bin/phpunit
else
    echo "No composer.json found; skipping PHP adapter."
fi
