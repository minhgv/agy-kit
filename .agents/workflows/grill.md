---
description: "Rigorous stress testing of plans and specifications — apply 11 scrutiny questions to expose hidden assumptions, risks, and failure modes before writing code."
---

# /grill

Stress-test plans, ADRs, and technical specifications using the 'grill-me' skill with 11 scrutiny questions before committing to implementation.

## Steps

### Step 1: 11-Question Scrutiny & Risk Exposure
```bash
// turbo
agy run --agent reviewer "Invoke the 'grill-me' skill to stress-test the proposed plan or SPEC for $ARGUMENTS:
1. Evaluate all 11 scrutiny questions:
   - What assumptions are you making that could be wrong?
   - What's the most likely thing to fail?
   - What if X is 10x larger / smaller / slower?
   - What's the cost of being wrong?
   - What's the simplest way to test this?
   - What's the hardest part? Why?
   - What's the rollback plan?
   - What would make this a mistake?
   - Who disagrees with this? Why?
   - What's the non-goal everyone forgets?
   - What are we not talking about?
2. Surface hidden risks and force concrete answers rather than 'figure it out later'."
```

### Step 2: Plan Hardening & Verification
```bash
// turbo
agy run --agent planner "Update the technical specification to address all identified vulnerabilities, record answers to all scrutiny questions, and confirm plan resilience before code implementation."
```
