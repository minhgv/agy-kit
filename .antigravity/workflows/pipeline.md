---
description: "Full 5-step agentic pipeline — Plan → TDD → Quality Gate → E2E QA → Review & Commit. Auto-runs all steps sequentially."
---

# /pipeline

Thực hiện toàn bộ 5 bước agentic engineering workflow cho một feature.

## Steps

### Step 1: Plan
```bash
// turbo
agy run --agent plan "Khảo sát module liên quan và tạo SPEC tại plans/SPEC_$(FEATURE).md theo SPEC_TEMPLATE.md. Bao gồm: goals/non-goals, data flow, file mutation manifest, test plan, definition of done."
```

### Step 2: TDD Implementation
```bash
// turbo
agy run --agent coder "Đọc plans/SPEC_$(FEATURE).md. Thực hiện TDD: RED (viết test, verify FAIL) → GREEN (viết logic tối thiểu, verify PASS) → REFACTOR. Chỉ sửa file trong File Mutation Manifest."
```

### Step 3: Quality Gate
```bash
// turbo
agy run --agent reviewer "Chạy lint + typecheck. Quét gitleaks. Kiểm tra OWASP-AI 5-item checklist. Sửa mọi lỗi phát hiện. Báo cáo: 0 error, 0 warning, 0 secret."
```

### Step 4: E2E QA
```bash
// turbo
agy run --agent qa "Khởi động local server. Chạy cURL/Playwright test theo Test Plan trong SPEC. Thu thập evidence vào tests/qa-evidence/."
```

### Step 5: Review & Commit
```bash
// turbo
agy run --agent reviewer "Review git diff. Kiểm tra: debug log thừa, file ngoài scope, API contract, test coverage. Gom commit Conventional Commits."
```
