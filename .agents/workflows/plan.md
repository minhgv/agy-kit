---
description: "Quick plan-only — create a SPEC with BA expert skill, RTM, and 12-Dimensional Edge Case Matrix without running code."
---

# /plan

Create a SPEC for a new feature using the 'ba-expert' skill, RTM, and 12-Dimensional Edge Case Matrix.

## Steps

### Step 1: Survey & BA Plan
```bash
// turbo
agy run --agent plan "Survey the codebase related to $ARGUMENTS. Invoke the 'ba-expert' skill to construct the Requirements Traceability Matrix (RTM), 12-Dimensional Edge Case Matrix, NFRs, and DFD. Create a SPEC at plans/SPEC_$(slugify $ARGUMENTS).md following SPEC_TEMPLATE.md."
```

### Step 2: Traceability Audit & User Review
```bash
// turbo
./bin/validate-traceability.sh
```
Read the generated SPEC and verify RTM completeness and 12-Dimensional edge cases before proceeding to implementation.
