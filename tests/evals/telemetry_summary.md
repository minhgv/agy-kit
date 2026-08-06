# agy-kit Telemetry & Tracing Summary

**Generated:** 2026-08-06T05:47:56.428810

## Token Consumption & Cost Breakdown
- **Total Prompt Tokens:** 90,000
- **Total Completion Tokens:** 17,000
- **Total Tokens:** 107,000
- **Estimated Cost:** $0.011175

## Latency Metrics (Tool Calls & Execution)
- **P50 (Median):** 320 ms
- **P95:** 610 ms
- **P99:** 610 ms

## Stage Breakdown
| Stage | Model | Total Tokens | Cost (USD) |
|---|---|---|---|
| `planner` | `gemini-3.6-flash-high` | 18,000 | $0.002025 |
| `coder` | `gemini-3.6-flash-high` | 53,000 | $0.005775 |
| `reviewer` | `gemini-3.6-flash-high` | 24,000 | $0.002700 |
| `qa` | `gemini-3.6-flash-low` | 12,000 | $0.000675 |

## Success & Reliability Metrics
- **Pass@1 TDD Rate:** 100%
- **Flaky Test Retries:** 0
- **Boundary Violations:** 0
