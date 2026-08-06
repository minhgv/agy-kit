# agy-kit Orchestration Patterns

> Multi-agent orchestration patterns cho Antigravity CLI, dựa trên research từ Anthropic "Building Effective Agents" và community scaffolds.

## 1. Sequential Pipeline (Default — agy-kit)

```
[Planner] → [Coder] → [Quality Gate] → [QA] → [Reviewer]
```

- **Khi nào dùng:** SDLC chuẩn, feature development workflow.
- **Ưu điểm:** Đơn giản, deterministic, dễ debug, output phase trước = input phase sau.
- **Nhược điểm:** Wall-clock time dài (chạy tuần tự).

## 2. Parallel Scatter-Gather

```
                    ┌→ [Security Reviewer]
[Reviewer trigger] ─┼→ [Performance Reviewer]  ─→ [Parent Gather]
                    └→ [Style Reviewer]
```

- **Khi nào dùng:** Phase review/QA cần nhiều góc nhìn độc lập.
- **Ưu điểm:** Giảm 60-70% wall-clock time cho phase review/survey.
- **Cách dùng:** `delegate_task` với batch 3 subagents song song.

## 3. Hub-and-Spoke (Supervisor-Worker)

```
[Supervisor Agent]
   ├── analyzes goal → decomposes tasks
   ├── delegates to specialist subagents
   ├── collects results
   └── re-plans if needed (Re-planning loop)
```

- **Khi nào dùng:** Task phức tạp, cần dynamic task decomposition.
- **Ưu điểm:** Thích ứng với kết quả trung gian, có thể re-plan.

## 4. Nexus Event-Driven

```
[State Graph / Event Bus]
  on_code_change → trigger QA + Reviewer (parallel)
  if QA fail → trigger Coder (with diff + feedback)
  if Review fail → trigger Coder (with patch suggestions)
```

- **Khi nào dùng:** CI/CD integration, automated hotfix loops.
- **Cần:** LangGraph, CrewAI, hoặc AutoGen state machine.

## Khuyến nghị từ Anthropic

> "Orchestration đơn giản mang lại độ tin cậy cao hơn các framework quá phức tạp."
> — Building Effective Agents, Anthropic

**Best practice:** Workflows deterministic (Sequential/Parallel) + Evaluator-Optimizer loop.
agy-kit mặc định dùng Sequential Pipeline + optional Parallel Scatter-Gather cho review phase.
