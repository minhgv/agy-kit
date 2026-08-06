# agy-kit Configuration for Node.js / Express / TypeScript Projects

This directory provides complete configuration templates and starter files for Node.js / Express / TypeScript services using `agy-kit`.

## Configuration Structure

```text
node_express_config_example/
├── .antigravity/
│   ├── agents/
│   │   ├── planner.json      # Architect agent survey & SPEC creation
│   │   ├── coder.json        # TDD implementation agent (vitest / jest / tsc)
│   │   ├── reviewer.json     # Code review, eslint, npm audit
│   │   └── qa.json           # Playwright / Supertest E2E runner
│   └── mcp.json              # MCP server mappings for Node/TS tooling
├── package.json              # npm package manifest & scripts
├── tsconfig.json             # TypeScript compiler configuration
├── .eslintrc.json            # ESLint rules
├── src/
    └── index.ts              # Express API starter code
└── tests/
    └── index.test.ts         # Vitest / Jest starter test suite
```

## Required Tools & Linters

- **Static Type Checker:** `tsc --noEmit`.
- **Linter & Formatter:** `eslint . --ext .ts`.
- **Test Runner:** `vitest` or `jest`.
- **Security Audit:** `npm audit --audit-level=high`, `gitleaks`.

## Setup & Execution Commands

```bash
# 1. Install dependencies
npm install

# 2. Run TDD pipeline using agy-kit
agy run --agent coder "Implement Express health route in TypeScript with Vitest tests"

# 3. Run Quality Gate audit
agy run --agent reviewer "Audit git diff with ESLint, tsc, and npm audit"
```
