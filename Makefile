# agy-kit Makefile — Chain agy commands into automated pipelines
#
# Usage:
#   make pipeline FEATURE=auth-oauth2
#   make spec FEATURE=auth-oauth2
#   make build FEATURE=auth-oauth2
#   make gate
#   make qa
#   make review

FEATURE ?= unnamed

.PHONY: pipeline spec build gate qa review clean

# Full 5-step pipeline
pipeline: spec build gate qa review
	@echo "✅ Pipeline complete for feature: $(FEATURE)"

# Step 1: Create SPEC
spec:
	agy run --agent plan "Khảo sát và tạo SPEC cho tính năng $(FEATURE) tại plans/SPEC_$(FEATURE).md theo SPEC_TEMPLATE.md"

# Step 2: TDD Implementation
build:
	agy run --agent coder "Đọc plans/SPEC_$(FEATURE).md. Thực hiện TDD: RED → GREEN → REFACTOR. Chỉ sửa file trong File Mutation Manifest."

# Step 3: Quality Gate (lint + security)
gate:
	agy run --agent reviewer "Chạy lint, typecheck, gitleaks, OWASP-AI checklist. Sửa mọi lỗi."

# Step 4: E2E QA
qa:
	agy run --agent qa "Khởi động local server. Chạy cURL/Playwright test theo Test Plan. Thu thập evidence."

# Step 5: Review & Commit
review:
	agy run --agent reviewer "Review git diff. Pre-commit audit + 3-state verification. Gom Conventional Commits."

# Clean QA evidence
clean:
	rm -rf tests/qa-evidence/*
