---
description: "Interactive design exploration & unknown classification — map unknown categories, present 2-4 option variants with trade-offs before writing code."
---

# /brainstorm

Explore design variants, classify unknowns, and validate architecture decisions using the 'brainstorming' skill before entering code implementation or planning.

## Steps

### Step 1: Unknown Classification & Variant Generation
```bash
// turbo
agy run --agent plan "Invoke the 'brainstorming' skill for feature $ARGUMENTS:
1. Classify unknowns into 4 categories: Known knowns, Known unknowns, Unknown knowns, and Unknown unknowns.
2. Present 2-4 concrete design variants, each naming the specific trade-offs it accepts.
3. Highlight assumptions and ask key architecture, data-model, or UX questions one at a time."
```

### Step 2: Design Validation & Handoff
```bash
// turbo
agy run --agent plan "Validate the approved design variant against project conventions. Ensure hard gate is respected before proceeding to SPEC creation via /plan."
```
