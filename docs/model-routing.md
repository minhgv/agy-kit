# agy-kit — Model Routing Strategy

> Tối ưu chi phí và chất lượng bằng cách dùng model khác nhau cho từng subagent role.

## Routing Matrix

| Role | Model (Primary) | Model (Fallback) | Temperature | Lý do |
|------|-----------------|-------------------|-------------|-------|
| **Planner** | gemini-3.6-flash-high | gemini-3.6-flash-low | 0.4 | Cần system reasoning cao, context lớn, phân tích dependency chính xác |
| **Coder** | gemini-3.6-flash-high | gemini-3.6-flash-low | 0.2 | Coding benchmark cao, sinh code nhanh, tuân thủ TDD strict |
| **Reviewer** | gemini-3.6-flash-high | gemini-3.6-flash-low | 0.3 | Critical auditing, OWASP detection, DRY/SOLID check, hallucination thấp |
| **QA** | gemini-3.6-flash-low | gemini-3.6-flash-low | 0.1 | Tốc độ cực nhanh, chi phí thấp, chỉ chạy cURL/E2E + thu thập evidence |

## Cost Optimization

- Dùng Flash-low cho QA → tiết kiệm ~75-80% token cost so với dùng flagship cho toàn pipeline.
- Planner & Coder cần Flash-high vì cần reasoning sâu.
- Reviewer cần Flash-high để catch security issues.

## Dynamic Fallback Cascading

```json
"model": {
  "primary": "gemini-3.6-flash-high",
  "fallback": "gemini-3.6-flash-low"
}
```

- Nếu primary bị HTTP 429 (rate limit) hoặc 503 (overloaded) → tự động fallback sang secondary.
- Workflow không bị gián đoạn.

## OpenTelemetry Tracing

Monitor model performance qua 5 core agent spans:
1. `create_agent` — khởi tạo + load spec/tools
2. `invoke_agent_client` — caller → subagent call
3. `invoke_agent_internal` — reasoning loop bên trong subagent
4. `invoke_workflow` — multi-agent orchestration span
5. `execute_tool` — tool execution (read_file, terminal, patch...)

Track attributes: `gen_ai.request.model`, `gen_ai.agent.name`, `gen_ai.usage.input_tokens`, `gen_ai.usage.output_tokens`.
