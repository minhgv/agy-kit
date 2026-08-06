# agy-kit Telemetry & Tracing Summary

**Generated:** 2026-08-06T04:24:57.926146

## Token Consumption & Cost Breakdown
- **Total Prompt Tokens:** 90,000
- **Total Completion Tokens:** 17,000
- **Total Tokens:** 107,000
- **Estimated Cost:** $0.063125

## Latency Metrics (Tool Calls & Execution)
- **P50 (Median):** 320 ms
- **P95:** 610 ms
- **P99:** 610 ms

## Stage Breakdown
| Stage | Model | Total Tokens | Cost (USD) |
|---|---|---|---|
| `planner` | `zai/glm-5.2` | 18,000 | $0.024000 |
| `coder` | `gemini-3.6-flash-high` | 53,000 | $0.005775 |
| `reviewer` | `zai/glm-5.2` | 24,000 | $0.032000 |
| `qa` | `gemini-3.6-flash-high` | 12,000 | $0.001350 |

## Success & Reliability Metrics
- **Pass@1 TDD Rate:** 100%
- **Flaky Test Retries:** 0
- **Boundary Violations:** 0
