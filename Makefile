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
	agy run --agent plan "Survey and create SPEC for feature $(FEATURE) at plans/SPEC_$(FEATURE).md following SPEC_TEMPLATE.md"

# Step 2: TDD Implementation
build:
	agy run --agent coder "Read plans/SPEC_$(FEATURE).md. Execute TDD: RED → GREEN → REFACTOR. Only modify files in the File Mutation Manifest."

# Step 3: Quality Gate (lint + security)
gate:
	agy run --agent reviewer "Run lint, typecheck, gitleaks, OWASP-AI checklist. Fix all issues."

# Step 4: E2E QA
qa:
	agy run --agent qa "Start local server. Run cURL/Playwright tests per Test Plan. Collect evidence."

# Step 5: Review & Commit
review:
	agy run --agent reviewer "Review git diff. Pre-commit audit + 3-state verification. Group Conventional Commits."

# Clean QA evidence
clean:
	rm -rf tests/qa-evidence/*
