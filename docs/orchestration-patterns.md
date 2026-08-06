# agy-kit Orchestration Patterns

> Multi-agent orchestration patterns for Antigravity CLI, based on research from Anthropic "Building Effective Agents" and community scaffolds.

## 1. Sequential Pipeline (Default — agy-kit)

```
[Planner] → [Coder] → [Quality Gate] → [QA] → [Reviewer]
```

- **When to use:** Standard SDLC, feature development workflow.
- **Pros:** Simple, deterministic, easy to debug, output of previous phase = input of next phase.
- **Cons:** Long wall-clock time (runs sequentially).

## 2. Parallel Scatter-Gather

```
                    ┌→ [Security Reviewer]
[Reviewer trigger] ─┼→ [Performance Reviewer]  ─→ [Parent Gather]
                    └→ [Style Reviewer]
```

- **When to use:** Review/QA phase requiring multiple independent perspectives.
- **Pros:** Reduces 60-70% wall-clock time for the review/survey phase.
- **How to use:** `delegate_task` with a batch of 3 parallel subagents.

## 3. Hub-and-Spoke (Supervisor-Worker)

```
[Supervisor Agent]
   ├── analyzes goal → decomposes tasks
   ├── delegates to specialist subagents
   ├── collects results
   └── re-plans if needed (Re-planning loop)
```

- **When to use:** Complex tasks requiring dynamic task decomposition.
- **Pros:** Adapts to intermediate results, capable of re-planning.

## 4. Nexus Event-Driven

```
[State Graph / Event Bus]
  on_code_change → trigger QA + Reviewer (parallel)
  if QA fail → trigger Coder (with diff + feedback)
  if Review fail → trigger Coder (with patch suggestions)
```

- **When to use:** CI/CD integration, automated hotfix loops.
- **Requires:** LangGraph, CrewAI, or AutoGen state machine.

## Recommendations from Anthropic

> "Simple orchestration provides higher reliability than overly complex frameworks."
> — Building Effective Agents, Anthropic

**Best practice:** Deterministic workflows (Sequential/Parallel) + Evaluator-Optimizer loop.
agy-kit defaults to Sequential Pipeline + optional Parallel Scatter-Gather for the review phase.
