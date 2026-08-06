# agy-kit Contributing Guide

## How to Contribute

### Reporting Issues
- Use GitHub Issues for bug reports and feature requests.
- Include: tool version, language, OS, steps to reproduce.

### Adding Language Support
1. Add the language to `docs/multi-language-adapters.md` (detection file + toolchain commands).
2. Add example config to `examples/` if the language needs special setup.
3. Update `.pre-commit-config.yaml` with the language's linter hooks.

### Adding Tool Adapters
1. Create the tool's config directory (e.g., `.newtool/agents/`).
2. Map the 4 standard roles (planner, coder, reviewer, qa) to the tool's format.
3. Document in `docs/cross-tool-compat.md`.

### Improving Prompts
1. Edit the relevant workflow file in `.antigravity/workflows/`.
2. Sync changes to `.claude/agents/*.md` if the prompt changes are role-level.
3. Test with a real feature before submitting PR.

### Contribution Workflow
```bash
# Fork & clone
git clone https://github.com/YOUR_USERNAME/agy-kit.git
cd agy-kit

# Create feature branch
git checkout -b feat/add-rust-support

# Make changes (follow Conventional Commits)
# ... edit files ...

# Test your changes
# - Verify all JSON/YAML files are valid
# - Verify agent configs load in target tool

# Commit & push
git add -A
git commit -m "feat: add Rust language adapter"
git push origin feat/add-rust-support

# Open PR
gh pr create --title "feat: add Rust language adapter" --body "..."
```

## Versioning

agy-kit follows [Semantic Versioning](https://semver.org/):

| Change Type | Version Bump | Example |
|-------------|-------------|---------|
| Breaking scaffold change | MAJOR (1.0.0 → 2.0.0) | New required AGENTS.md format |
| New feature/adapter | MINOR (1.0.0 → 1.1.0) | Add `.claude/` adapter |
| Bug fix / doc improvement | PATCH (1.0.0 → 1.0.1) | Fix typo in prompt |

## License

MIT — free to use, modify, and distribute.
