# agy-kit — Cross-Tool Compatibility Guide

> agy-kit is tool-agnostic at its core. The `AGENTS.md` format is the universal standard. Tool-specific configs are adapters.

## Compatibility Matrix

| Tool | Config Location | Format | Status |
|------|----------------|--------|--------|
| **Antigravity CLI (agy)** | `.antigravity/agents/*.json` | JSON schema v1.1 | ✅ Native (primary) |
| **Claude Code** | `.claude/agents/*.md` | Markdown + YAML frontmatter | ✅ Adapter included |
| **OpenCode** | `.opencode/agents.json` | JSON | ✅ Adapter included |
| **Cursor IDE** | `.cursorrules` | Markdown | ✅ Auto-generated |
| **Windsurf** | `.windsurfrules` | Markdown (same as .cursorrules) | ✅ Copy .cursorrules |
| **Codex CLI** | `AGENTS.md` (native) | Markdown | ✅ Uses AGENTS.md directly |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Markdown | ✅ Copy AGENTS.md |
| **Any MCP host** | `.antigravity/mcp.json` | JSON (MCP standard) | ✅ Portable |

## Architecture: Universal Core + Tool Adapters

```
agy-kit/
├── AGENTS.md                   # ← UNIVERSAL CORE (all tools read this)
├── .antigravity/               # ← Antigravity CLI native
│   ├── agents/*.json
│   ├── mcp.json
│   └── workflows/*.md
├── .claude/                    # ← Claude Code adapter
│   └── agents/*.md
├── .opencode/                  # ← OpenCode adapter
│   └── agents.json
├── .cursorrules                # ← Cursor IDE adapter
├── .github/
│   ├── workflows/ci.yml        # ← GitHub Actions CI
│   └── copilot-instructions.md # ← GitHub Copilot adapter
└── ...
```

## How It Works

### 1. AGENTS.md = Single Source of Truth

`AGENTS.md` contains all project rules, conventions, and workflow definitions. Every tool reads it.

### 2. Tool-Specific Agent Adapters

Each tool has its own subagent format:
- **agy**: `.antigravity/agents/planner.json` (rich JSON schema with model routing, permissions)
- **Claude Code**: `.claude/agents/planner.md` (YAML frontmatter + system prompt body)
- **OpenCode**: `.opencode/agents.json` (single file, array of agent objects)

The 4 roles (planner, coder, reviewer, qa) are identical across tools — only the format differs.

### 3. Model Routing Differences

| Tool | How to set model per agent |
|------|---------------------------|
| agy | `model.primary` in JSON |
| Claude Code | `model:` in YAML frontmatter |
| OpenCode | `model:` in agent JSON |
| Cursor | Set in Cursor settings (not per-agent) |

### 4. MCP Portability

`.antigravity/mcp.json` uses the standard MCP server config format. Other MCP hosts (Claude Desktop, Cursor, Windsurf) can import the same servers.

## Customization Without Forking

### Pattern: Layered AGENTS.md
```
# Root AGENTS.md (agy-kit defaults)
packages/auth/AGENTS.md    # ← overrides for auth package
```
Child AGENTS.md inherits parent rules and adds package-specific overrides.

### Pattern: Custom Skills Injection
Drop your own `SKILL.md` files into `.hermes/skills/` — they're auto-loaded by any agent skills-compatible tool.

## Sync Strategy

When updating agent roles:
1. Edit the `.antigravity/agents/*.json` (primary source)
2. Sync to `.claude/agents/*.md` and `.opencode/agents.json` (adapters)
3. Run: `make sync-agents` (coming soon — generates adapters from primary)
