---
description: "Full 5-step agentic pipeline — Plan → TDD → Quality Gate → E2E QA → Review & Commit. Auto-runs all steps sequentially with BA & QA skills suite integration."
---

# /pipeline

Execute the complete 5-step agentic engineering workflow for a feature, fully integrated with Business Analysis (BA) and Quality Assurance (QA) skills suite.

## Steps

### Step 1: Plan (BA & Specification)
```bash
// turbo
agy run --agent plan "Survey the relevant module and create a SPEC at plans/SPEC_$(FEATURE).md following SPEC_TEMPLATE.md. Invoke the 'ba-expert' skill to construct the Requirements Traceability Matrix (RTM), 12-Dimensional Edge Case Matrix, Non-Functional Requirements (NFRs), and Data Flow Diagram (DFD). Run ./bin/validate-traceability.sh to verify plan compliance."
```

### Step 2: TDD Implementation (QA Test Gen)
```bash
// turbo
agy run --agent coder "Read plans/SPEC_$(FEATURE).md. Invoke the 'qa-test-gen' skill to auto-generate unit and integration tests covering the 12-Dimensional Edge Case Matrix and mapped RTM requirements. Execute TDD: RED (write tests, verify FAIL) → GREEN (write minimal logic, verify PASS) → REFACTOR. Only modify files listed in the File Mutation Manifest."
```

### Step 3: Quality Gate Audit
```bash
// turbo
agy run --agent reviewer "Run ./bin/scan-dependencies.sh to scan supply chain dependencies. Invoke the 'qa-auditor' skill to execute Quality Gate Audit (L1-L5), produce JSON Audit Contract, evaluate Runtime Risk Matrix, and check OWASP-AI 5-item checklist. Run ./bin/validate-traceability.sh. Fix all issues found. Report: 0 errors, 0 warnings, 0 secrets."
```

### Step 4: E2E QA & Bug Reproduction
```bash
// turbo
agy run --agent qa "Start local server. Invoke the 'qa-reproducer' and 'qa-test-gen' skills to execute E2E test suite according to the Test Plan in SPEC. Test 12-Dimensional edge cases and create Minimal Reproduction Examples (MRE) for any failures. Collect evidence into tests/qa-evidence/."
```

### Step 5: Review & Commit (3-State Verification)
```bash
// turbo
agy run --agent reviewer "Review git diff. Invoke the 'qa-auditor' and 'ba-expert' skills for pre-commit audit and 3-State Verification (declared / tested / observed or CONFIRMED / PLAUSIBLE / REFUTED). Verify RTM status transitions. Run ./bin/validate-traceability.sh. Group commits using Conventional Commits."
```
