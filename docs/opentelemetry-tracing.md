# OpenTelemetry (OTLP) Tracing for Antigravity CLI (`agy`)

> **Observability Guide** — Track token consumption, tool latency, subagent invocation trees, and LLM cost natively in Antigravity CLI.

---

## Overview

Antigravity CLI (`agy`) natively supports OpenTelemetry (OTLP) tracing. When enabled, `agy` emits GenAI semantic conventions tracing spans for every agent invocation, tool call, and model response.

---

## 1. Environment Configuration

Export the following environment variables before running `agy` commands or in your `~/.bashrc` / CI environment:

```bash
# Enable native OpenTelemetry tracing in agy
export ANTIGRAVITY_OTEL_ENABLED=true

# OTLP Exporter Endpoint (gRPC or HTTP/protobuf)
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"

# Service Name for Telemetry Categorization
export OTEL_SERVICE_NAME="agy-kit-pipeline"

# Optional: Add environment attributes
export OTEL_RESOURCE_ATTRIBUTES="deployment.environment=production,team=platform-engineering"
```

---

## 2. Telemetry Span Hierarchy

`agy` builds a hierarchical span tree during execution:

```
invoke_workflow (/pipeline)
├── invoke_agent_client (planner)
│   ├── invoke_agent_internal
│   │   ├── chat (gemini-3.6-flash-high)
│   │   └── execute_tool (read_file)
│   └── chat (gemini-3.6-flash-high)
├── invoke_agent_client (coder)
│   ├── execute_tool (write_file)
│   └── execute_tool (terminal)
└── invoke_agent_client (reviewer)
    └── chat (gemini-3.6-flash-high)
```

---

## 3. GenAI Semantic Attributes Tracked

| Attribute | Description | Example |
|-----------|-------------|---------|
| `gen_ai.system` | AI provider / CLI engine | `antigravity` |
| `gen_ai.agent.name` | Subagent ID | `planner`, `coder`, `reviewer`, `qa` |
| `gen_ai.request.model` | Model requested | `gemini-3.6-flash-high` |
| `gen_ai.usage.input_tokens` | Prompt tokens consumed | `4210` |
| `gen_ai.usage.output_tokens` | Response tokens generated | `850` |
| `gen_ai.tool.name` | Tool executed | `terminal`, `write_file`, `search_files` |
| `gen_ai.tool.status` | Execution status | `success`, `error` |

---

## 4. Local Visualizers (Jaeger / Prometheus / Grafana)

You can launch a local Jaeger collector using Docker to view live traces:

```bash
docker run -d --name jaeger \
  -e COLLECTOR_OTLP_ENABLED=true \
  -p 16686:16686 \
  -p 4317:4317 \
  jaegertracing/all-in-one:latest
```

Open `http://localhost:16686` in your browser to inspect subagent execution graphs and token latency.
