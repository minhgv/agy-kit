# agy-kit Configuration for Rust / Axum Projects

This directory provides complete configuration templates and starter files for Rust / Axum web services using `agy-kit`.

## Configuration Structure

```text
rust_axum_config_example/
├── .antigravity/
│   ├── agents/
│   │   ├── planner.json      # Architect agent survey & SPEC creation
│   │   ├── coder.json        # TDD implementation agent (cargo test)
│   │   ├── reviewer.json     # Code review, cargo clippy, cargo audit
│   │   └── qa.json           # Rust E2E test runner
│   └── mcp.json              # MCP server mappings for Rust tooling
├── Cargo.toml                # Cargo manifest
├── clippy.toml               # Cargo Clippy linter configuration
└── src/
    └── lib.rs                # Axum service starter code & unit tests
```

## Required Tools & Linters

- **Linter & Code Format:** `cargo clippy -- -D warnings`, `cargo fmt --check`.
- **Security Audit:** `cargo audit` (Vulnerability scanning for crates), `gitleaks`.
- **Test Runner:** `cargo test`.

## Setup & Execution Commands

```bash
# 1. Run TDD pipeline using agy-kit
agy run --agent coder "Implement Axum health check handler with cargo test"

# 2. Run Quality Gate audit
agy run --agent reviewer "Audit git diff with cargo clippy and cargo audit"
```
