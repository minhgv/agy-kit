# agy-kit Configuration for Go / Gin Projects

This directory provides complete configuration templates and starter files for Go / Gin microservices using `agy-kit`.

## Configuration Structure

```text
go_gin_config_example/
├── .antigravity/
│   ├── agents/
│   │   ├── planner.json      # Architect agent survey & SPEC creation
│   │   ├── coder.json        # TDD implementation agent (go test)
│   │   ├── reviewer.json     # Code review, golangci-lint, govulncheck audit
│   │   └── qa.json           # Go E2E & HTTP test runner
│   └── mcp.json              # MCP server mappings for Go tooling
├── golangci.yml              # golangci-lint strict configuration
├── go.mod                    # Go module file
├── main.go                   # Gin REST API starter code
└── main_test.go              # Go unit test starter suite
```

## Required Tools & Linters

- **Linter:** `golangci-lint` (runs errcheck, staticcheck, govet, ineffassign).
- **Vulnerability Scanner:** `govulncheck` (Go vulnerability database scanner).
- **Test Runner:** `go test -race -v -cover ./...`.
- **Security Audit:** `gitleaks` (Scans hardcoded API keys and credentials).

## Setup & Execution Commands

```bash
# 1. Verify Go module setup
go mod tidy

# 2. Run TDD pipeline using agy-kit
agy run --agent coder "Implement user authentication endpoint in Go Gin"

# 3. Run Quality Gate audit
agy run --agent reviewer "Audit git diff with golangci-lint and govulncheck"
```
