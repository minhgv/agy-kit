# Meta-Testing agy-kit — Testing Agent Scaffolds Themselves

> How to verify that your subagents behave correctly, prompts don't regress, and safety hooks fire.

## 3 Testing Layers

### Layer 1: Meta-Tests (Deterministic Scaffold Tests)

Test the scaffold infrastructure, not the LLM. Fast, deterministic, runs on every PR.

```yaml
# tests/meta/test_spec_parsing.py
def test_spec_template_has_7_sections():
    """Verify SPEC_TEMPLATE.md has all required sections."""
    content = open('plans/SPEC_TEMPLATE.md').read()
    for section in ['Executive Summary', 'Architecture', 'Schema',
                     'File Mutation', 'Test Plan', 'Backward', 'Definition of Done']:
        assert section in content

# tests/meta/test_rollback.py
def test_git_checkpoint_creates_stash():
    """Verify safe-agent-run.sh creates a git checkpoint."""
    # Run script, verify stash was created
    pass

# tests/meta/test_loop_breaker.py
def test_loop_breaker_fires_after_3_retries():
    """Verify max_turns=15 and retry limit enforcement."""
    pass

# tests/meta/test_agent_json_valid.py
def test_all_agent_configs_are_valid_json():
    """Verify .antigravity/agents/*.json parse correctly."""
    import json, glob
    for f in glob.glob('.antigravity/agents/*.json'):
        json.load(open(f))  # raises if invalid
```

### Layer 2: Agent Trajectory Evals

Evaluate the agent's problem-solving path. Slower, runs weekly or pre-release.

| Metric | What it measures | Target |
|--------|-----------------|--------|
| Task Completion Rate | % of golden tasks completed | ≥ 90% |
| Tool Call Efficiency | Redundant tool calls per task | ≤ 2 |
| Rule Compliance Score | % of lint/style rules followed | ≥ 95% |
| Token Efficiency | Tokens used per completed task | Baseline ±10% |

**Golden tasks:** 10-20 reference features with known correct output. Run each agent role against them.

### Layer 3: Prompt Regression Testing

Catch prompt drift when you edit agent instructions.

```bash
# Using Promptfoo
npx promptfoo eval \
  --prompts .opencode/agents.json \
  --tests tests/prompt-regression/*.yaml \
  --assertions tests/assertions/*.yaml
```

Run old prompt + new prompt on 50+ scenarios, compare with LLM-as-a-Judge + regex assertions.

## CI Integration

```yaml
# .github/workflows/eval.yml
name: Agent Evals
on: [pull_request]
jobs:
  meta-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pytest tests/meta/ -v          # Fast (< 1 min)
  weekly-evals:
    if: github.event.schedule == '0 6 * * 1'  # Weekly Monday
    runs-on: ubuntu-latest
    steps:
      - run: npx promptfoo eval             # Full eval (slow)
```

## Tools

| Tool | Use Case |
|------|----------|
| **Promptfoo** | Prompt regression testing, A/B comparison |
| **Inspect AI** | Agent trajectory evaluation |
| **DeepEval** | LLM output quality scoring |
| **pytest/vitest** | Deterministic scaffold meta-tests |
