#!/usr/bin/env bash
# agy-kit Rust Adapter
set -euo pipefail

echo "🦀 Running Rust adapter checks..."
if [ -f Cargo.toml ]; then
    cargo test
else
    echo "No Cargo.toml found; skipping Rust adapter."
fi
