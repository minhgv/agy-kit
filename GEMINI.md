# GEMINI.md — Antigravity-Specific Overrides

> This file takes highest precedence over `AGENTS.md` when Antigravity CLI (`agy`) loads workspace context.

## Model Routing

- **Planning & Architecture tasks** → use `gemini-3.6-flash-high` for deep reasoning.
- **Quick edits & repetitive refactors** → use `gemini-3.6-flash-low` to save quota.
- **Code review & security audit** → use `gemini-3.6-flash-high`.

## OpenTelemetry Tracing

- Enable tracing for all sessions to capture latency, tool calls, and token usage.
- Export to console by default; configure OTLP exporter for production monitoring.

## Declarative Subagents

- Subagents defined in `.antigravity/agents/*.json` are loaded automatically.
- Each subagent has isolated context window and tool permissions.
- Orchestration pattern: planner → coder → reviewer → qa (sequential pipeline).

## Settings.json Safety

- `agy` v1.1.2+ preserves unknown fields in settings.json during updates.
- Never manually wipe settings files — let `agy` manage migrations.
