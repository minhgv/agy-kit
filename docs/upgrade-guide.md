# agy-kit Upgrade & Versioning Guide

## Version Tracking

agy-kit tracks its own version in `.antigravity/version.json`:
```json
{
  "scaffold_version": "0.5.0",
  "schema_version": "1.1",
  "compatible_cli_range": "agy >= 1.1.0",
  "last_sync": "2026-08-06T02:25:00Z"
}
```

## Semantic Versioning

| Change Type | Bump | Example |
|-------------|------|---------|
| **MAJOR** | Breaking workflow/directory/schema change | New AGENTS.md format, renamed `.antigravity/` → `.agy/` |
| **MINOR** | New subagent role, new skill, new tool adapter | Add `.codex/` adapter, add `sec-auditor` agent |
| **PATCH** | Prompt tweaks, lint command fixes, docs | Fix typo in reviewer prompt |

## Upgrading agy-kit in Your Project

### Non-Destructive Merge

agy-kit never overwrites your custom rules. Upgrade path:

1. **Pull latest agy-kit** as a remote:
   ```bash
   git remote add agy-kit https://github.com/minhgv/agy-kit.git
   git fetch agy-kit
   ```

2. **Merge selectively** (cherry-pick what you need):
   ```bash
   git merge agy-kit/main --no-commit
   # Review changes, resolve conflicts in AGENTS.md
   # Your custom rules in AGENTS.md are preserved
   git commit -m "chore: upgrade agy-kit to v0.6.0"
   ```

3. **Run sync** to regenerate all tool adapters:
   ```bash
   ./bin/sync-adapters.sh
   ```

### Config Override Pattern

Keep your customizations separate from agy-kit defaults:

```
agy-kit defaults     →  AGENTS.md (framework rules)
your overrides       →  .agy-kit.user.json (project-specific)
user-level prefs     →  ~/.antigravity/config.yaml (global)
```

Priority (highest wins): CLI flags > env vars > `.agy-kit.user.json` > `AGENTS.md` > framework defaults.

## Migration Guides

### v0.4.0 → v0.5.0
- Run `./bin/sync-adapters.sh` to generate new `.claude/`, `.opencode/`, `.codex/` adapters.
- No breaking changes to AGENTS.md or subagent JSON schema.

### v0.1.0 → v0.4.0
- Subagent JSON schema upgraded from v1.0 to v1.1 (added model routing, permissions, context_window).
- Re-generate your agent configs using the v1.1 schema fields or run sync.

## Layered AGENTS.md (Monorepo / Multi-Module)

```
root/AGENTS.md              # Company-wide rules, security policies
  └── packages/auth/AGENTS.md   # Auth-specific rules (inherits root)
      └── src/AGENTS.md             # File-level rules (inherits both)
```

Child AGENTS.md inherits all parent rules and adds module-specific overrides.
Use `@include ./rules/security.md` syntax to compose modular rule files.
