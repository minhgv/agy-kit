# agy-kit — Model Routing Strategy

> Optimize cost and quality by using different models for each subagent role.

## Routing Matrix

| Role | Model (Primary) | Model (Fallback) | Temperature | Reason |
|------|-----------------|-------------------|-------------|--------|
| **Planner** | gemini-3.6-flash-high | gemini-3.6-flash-low | 0.4 | Requires high system reasoning, large context, accurate dependency analysis |
| **Coder** | gemini-3.6-flash-high | gemini-3.6-flash-low | 0.2 | High coding benchmark, fast code generation, strict TDD compliance |
| **Reviewer** | gemini-3.6-flash-high | gemini-3.6-flash-low | 0.3 | Critical auditing, OWASP detection, DRY/SOLID check, low hallucination |
| **QA** | gemini-3.6-flash-low | gemini-3.6-flash-low | 0.1 | Extremely fast speed, low cost, runs cURL/E2E + collects evidence |

## Cost Optimization

- Use Flash-low for QA → save ~75-80% token cost compared to using flagship for the entire pipeline.
- Planner & Coder need Flash-high because deep reasoning is required.
- Reviewer needs Flash-high to catch security issues.

## Dynamic Fallback Cascading

```json
"model": {
  "primary": "gemini-3.6-flash-high",
  "fallback": "gemini-3.6-flash-low"
}
```

- If primary hits HTTP 429 (rate limit) or 503 (overloaded) → automatically fallback to secondary.
- Workflow is not interrupted.

## OpenTelemetry Tracing

Monitor model performance via 5 core agent spans:
1. `create_agent` — initialization + load spec/tools
2. `invoke_agent_client` — caller → subagent call
3. `invoke_agent_internal` — internal reasoning loop inside subagent
4. `invoke_workflow` — multi-agent orchestration span
5. `execute_tool` — tool execution (read_file, terminal, patch...)

Track attributes: `gen_ai.request.model`, `gen_ai.agent.name`, `gen_ai.usage.input_tokens`, `gen_ai.usage.output_tokens`.
