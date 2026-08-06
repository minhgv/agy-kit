# Subagent Context Window Management & Progressive File Hydration

## 1. Overview & Operational Principles

When working with large enterprise codebases (>50k LOC) or extensive pull requests, sending complete file contents or massive unified diffs into subagent prompt context exceeds standard LLM context windows or causes prompt truncation, loss of instruction adherence, and HTTP 413 (Payload Too Large) API rejections.

To prevent context exhaustion and maximize reasoning quality across agent execution stages (`planner`, `coder`, `reviewer`, `qa`), `agy-kit` enforces strict token budgeting, progressive file hydration, diff chunking, and log truncation protocols.

---

## 2. Token Budget Allocation Table

For any single interaction turn, total subagent prompt context is capped at **30,000 tokens** (~120 KB of text). Context is allocated across functional buckets as follows:

| Category | Token Allocation | Description & Constraints |
| :--- | :--- | :--- |
| **System Prompt & Rules** | 4,000 tokens | Core system prompt, safety directives, AGENTS.md rules, and prompt leak prevention directives. |
| **Task Spec / Context** | 6,000 tokens | Active feature `plans/SPEC_<feature>.md`, user instruction, and task parameters. |
| **Hydrated Source / Diffs** | 20,000 tokens | Maximum active source code files (max 5 active files per edit turn) or diff chunks (max 500 lines per block). |
| **Safety Buffer** | 10,000 tokens | Reserved token headroom for LLM response generation, multi-turn tool calling schemas, and error diagnostics. |
| **Total Context Cap** | **30,000 tokens** | Hard turn-level context ceiling across all subagent operations. |

---

## 3. Progressive File Hydration Protocol

Subagents MUST follow a three-phase hydration workflow rather than loading entire repositories into context:

1. **Phase A (Discovery & Indexing):**
   - Query repository structure up to depth 3 (`search_files` or file tree inspection).
   - Inspect module headers, key exports, or AST symbol outlines.
2. **Phase B (Targeted Hydration):**
   - Read only files explicitly enumerated in the target `SPEC.md` File Mutation Manifest.
   - Maintain a maximum of **5 active files** in the prompt context window per editing turn.
3. **Phase C (Budget Enforcement & Eviction):**
   - Evict inactive or unmodified files from active context memory before switching modules.
   - If additional context is required, query specific functions/lines via targeted tools (`search_files` or line-ranged `read_file`).

---

## 4. Large Diff Chunking Protocol

When performing code reviews, security audits, or QA validation on pull requests and large feature branches:

- **Threshold:** Unified diffs exceeding **500 lines** (or ~8,000 tokens) MUST NOT be ingested as a single prompt payload.
- **Chunking Strategy:** Diffs are broken down by file or logical module into blocks of at most 500 lines.
- **Sequential Processing:** Subagents (`reviewer`, `qa`) audit each chunk independently and accumulate structured findings.
- **Aggregation:** Merged audit reports are synthesized into a final review or QA verification report.

---

## 5. Output & Log Truncation Rules

- **Test Runner Output:** Truncate test output logs to the **last 100 lines** before passing back to error diagnosis context.
- **Linter & Compiler Logs:** Filter repetitive error stacks, summarizing warnings and isolating root cause stack traces.
