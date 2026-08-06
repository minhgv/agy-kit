---
description: "Quick plan-only — create a SPEC without running code. Use when you want to review the plan before implementation."
---

# /plan

Create a SPEC for a new feature without writing any code.

## Steps

### Step 1: Survey & Plan
```bash
// turbo
agy run --agent plan "Survey the codebase related to $ARGUMENTS. Create a SPEC at plans/SPEC_$(slugify $ARGUMENTS).md following SPEC_TEMPLATE.md."
```

### Step 2: Review SPEC
Read the generated SPEC. Wait for user review before proceeding to implementation.
