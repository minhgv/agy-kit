---
description: "Quick plan-only — create a SPEC without running code. Use when you want to review the plan before implementation."
---

# /plan

Tạo SPEC cho một feature mới mà không viết code.

## Steps

### Step 1: Survey & Plan
```bash
// turbo
agy run --agent plan "Khảo sát codebase liên quan đến $ARGUMENTS. Tạo SPEC tại plans/SPEC_$(slugify $ARGUMENTS).md theo SPEC_TEMPLATE.md."
```

### Step 2: Review SPEC
Đọc SPEC đã tạo. Đợi user review trước khi tiếp tục implementation.
