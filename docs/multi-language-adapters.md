# Multi-Language Toolchain Adapters

> Tự động phát hiện ngôn ngữ và áp dụng toolchain phù hợp. agy-kit hỗ trợ 5 ngôn ngữ.

## Detection Matrix

| Indicator File | Language | Detected |
|----------------|----------|----------|
| `pyproject.toml` / `requirements.txt` | Python | ✅ |
| `go.mod` | Go | ✅ |
| `Cargo.toml` | Rust | ✅ |
| `composer.json` / `phpunit.xml` | PHP | ✅ |
| `package.json` / `tsconfig.json` | Node.js / TypeScript | ✅ |

## Toolchain Adapter Matrix

### Python
```json
{
  "lint": "ruff check .",
  "format": "ruff format --check .",
  "typecheck": "mypy .",
  "test": "pytest --tb=short",
  "security": "bandit -r src/ && gitleaks detect --staged"
}
```

### Go
```json
{
  "lint": "golangci-lint run",
  "format": "gofmt -w .",
  "build": "go build ./...",
  "test": "go test -v ./...",
  "security": "gosec ./... && gitleaks detect --staged"
}
```

### Rust
```json
{
  "lint": "cargo clippy -- -D warnings",
  "format": "cargo fmt --check",
  "build": "cargo check",
  "test": "cargo test",
  "security": "cargo audit && gitleaks detect --staged"
}
```

### PHP (Laravel)
```json
{
  "lint": "vendor/bin/phpstan analyse",
  "format": "vendor/bin/pint --test",
  "test": "vendor/bin/phpunit",
  "security": "vendor/bin/security-checker check && gitleaks detect --staged"
}
```

### Node.js / TypeScript
```json
{
  "lint": "eslint .",
  "format": "prettier --check .",
  "typecheck": "tsc --noEmit",
  "test": "vitest run",
  "security": "npm audit && gitleaks detect --staged"
}
```

## Usage trong Subagent Configs

Inject toolchain commands vào `coder` và `reviewer` subagent `instructions` để tránh agent đoán sai lệnh:

```json
{
  "name": "coder",
  "instructions": [
    "...",
    "Project language: Python. Always use: lint=ruff check ., test=pytest --tb=short, typecheck=mypy .",
    "Do NOT use npm, go, cargo, or other language toolchains."
  ]
}
```

## Monorepo Support

- **Hierarchical context scoping:** `packages/auth/AGENTS.md` → root `AGENTS.md` (auto-resolve up the tree).
- **Path boundary isolation:** `"allow_write": ["packages/auth/**"]` trong subagent permissions.
- **Scoped execution:** `turbo --filter=@app/auth`, `pnpm --filter`, `cargo test -p`.
