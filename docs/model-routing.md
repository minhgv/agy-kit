# agy-kit — Model Routing Strategy

> **Native Antigravity Model Alignment Pattern:** Leverage `gemini-3.6-flash-high` for architectural design, technical planning, implementation, and security code review; utilize `gemini-3.6-flash-low` for QA automation and dynamic fallback cascading.

---

## 1. Routing Matrix

| Role | Subagent | Primary Model | Fallback Model | Max Tokens | Rationale |
|------|----------|---------------|----------------|------------|-----------|
| **Architect / Planner** | `planner` | `gemini-3.6-flash-high` | `gemini-3.6-flash-low` | 16,384 | Deep reasoning and analysis for architectural design, system boundary analysis, and SPEC authoring |
| **Executor / Developer** | `coder` | `gemini-3.6-flash-high` | `gemini-3.6-flash-low` | 16,384 | High coding throughput, fast tool execution, TDD cycle (RED → GREEN → REFACTOR) |
| **Auditor / Evaluator** | `reviewer` | `gemini-3.6-flash-high` | `gemini-3.6-flash-low` | 16,384 | Extended reasoning for OWASP-AI security audit, 3-state verification, and DRY/SOLID code review |
| **QA / Tester** | `qa` | `gemini-3.6-flash-low` | `gemini-3.6-flash-low` | 8,192 | Fast execution speed, cURL/Playwright test runner, log evidence collection |

---

## 2. Why `gemini-3.6-flash-high` for Planning & Review?

1. **Native Antigravity Integration:**
   - Native Antigravity model routing pairs `gemini-3.6-flash-high` across primary engineering subagents (`planner`, `coder`, `reviewer`) for optimal token efficiency, latency, and instruction adherence.
   - Ideal for `planner` (writing SPEC documents) and `reviewer` (auditing git diffs).
2. **Context Window & Performance:**
   - Configured with `max_tokens: 16384` for comprehensive technical specification and detailed code reviews without truncation.

---

## 3. Dynamic Fallback Cascading

```json
"model": {
  "primary": "gemini-3.6-flash-high",
  "fallback": "gemini-3.6-flash-low"
}
```

- If `gemini-3.6-flash-high` hits rate limit (HTTP 429) or quota reset window → automatically fall back to `gemini-3.6-flash-low`.
- Ensures zero session interruption across automated CI/CD pipelines and interactive subagent runs.

---

## 4. OpenTelemetry Tracing & Observability

`agy` tracks token usage separately across stages:
- `gen_ai.usage.input_tokens`
- `gen_ai.usage.output_tokens`
- `gen_ai.usage.reasoning_tokens`
