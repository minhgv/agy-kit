# agy-kit — Model Routing Strategy

> **Architect-Executor Hybrid Pattern:** Utilize deep extended reasoning (`zai/glm-5.2`) for evaluation, analysis, and planning; leverage high-speed execution (`gemini-3.6-flash-high`) for code generation and testing.

---

## 1. Routing Matrix

| Role | Subagent | Primary Model | Fallback Model | Max Tokens | Rationale |
|------|----------|---------------|----------------|------------|-----------|
| **Architect / Planner** | `planner` | `zai/glm-5.2` | `gemini-3.6-flash-high` | 16,384 | Deep extended reasoning (Thinking Mode) for architectural design, system boundary analysis, and SPEC authoring |
| **Executor / Developer** | `coder` | `gemini-3.6-flash-high` | `gemini-3.6-flash-low` | 16,384 | High coding throughput, fast tool execution, TDD cycle (RED → GREEN → REFACTOR) |
| **Auditor / Evaluator** | `reviewer` | `zai/glm-5.2` | `gemini-3.6-flash-high` | 16,384 | Extended reasoning for OWASP-AI security audit, 3-state verification, and DRY/SOLID code review |
| **QA / Tester** | `qa` | `gemini-3.6-flash-high` | `gemini-3.6-flash-low` | 8,192 | Fast execution speed, cURL/Playwright test runner, log evidence collection |

---

## 2. Why `zai/glm-5.2` for Planning & Review?

1. **Native Extended Reasoning (Thinking Mode):**
   - `glm-5.2` generates detailed internal monologues (`reasoning_tokens`) analyzing edge cases and dependency risks before emitting the final text.
   - Ideal for `planner` (writing SPEC documents) and `reviewer` (auditing git diffs).
2. **Token Budgeting for Thinking Models:**
   - Because `glm-5.2` consumes 300–600 tokens for internal reasoning, `max_tokens` is configured to `16384` to prevent truncation.

---

## 3. Dynamic Fallback Cascading

```json
"model": {
  "primary": "zai/glm-5.2",
  "fallback": "gemini-3.6-flash-high"
}
```

- If `zai/glm-5.2` hits rate limit (HTTP 429) or quota reset window → automatically fall back to `gemini-3.6-flash-high`.
- If delegation fails or quota is exhausted, fall back to `opencode-go/mimo-v2.5`.

---

## 4. OpenTelemetry Tracing & Observability

`agy` tracks token usage separately for reasoning vs output:
- `gen_ai.usage.input_tokens`
- `gen_ai.usage.output_tokens`
- `gen_ai.usage.reasoning_tokens` (for `glm-5.2`)
