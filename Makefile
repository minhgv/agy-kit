# agy-kit Makefile — Chain agy commands into automated pipelines
#
# Usage:
#   make pipeline FEATURE=auth-oauth2
#   make spec FEATURE=auth-oauth2
#   make build FEATURE=auth-oauth2
#   make gate
#   make qa
#   make review
#   make doctor
#   make validate
#   make check-boundaries
#   make eval-cost
#   make test-recovery
#   make check-traceability
#   make validate-ba
#   make validate-phase10
#   make validate-workflows-sync
#   make validate-phase11

FEATURE ?= unnamed

.PHONY: pipeline spec build gate qa review doctor validate check-boundaries eval-cost test-recovery scan-deps synthesize-skill export-telemetry check-traceability validate-ba validate-phase10 validate-workflows-sync validate-phase11 validate-brainstorm clean

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

# Health & Diagnostics
doctor:
	./bin/agy-doctor.sh

# Subagent Specification & Requirement Traceability Validation
validate: check-traceability validate-workflows-sync
	./bin/validate-agents.sh

# Workflow & Skill Synchronization Audit Target
validate-workflows-sync:
	@chmod +x bin/validate-workflows-sync.sh
	@./bin/validate-workflows-sync.sh

# Requirement Traceability Audit Target
check-traceability:
	@chmod +x bin/validate-traceability.sh
	@./bin/validate-traceability.sh

# Business Analysis & QA Framework Benchmark Validation
validate-ba: check-traceability
	@python3 tests/evals/eval_harness.py

# Phase 10 Business Analysis, QA Skills & System Reliability Target
validate-phase10: check-traceability
	@chmod +x bin/validate-phase10-ba-qa.sh
	@./bin/validate-phase10-ba-qa.sh
	@python3 tests/evals/eval_harness.py

# Phase 11 Business Analysis, QA Skills Suite & System Reliability Target
validate-phase11: check-traceability validate-workflows-sync
	@chmod +x bin/validate-phase10-ba-qa.sh
	@./bin/validate-phase10-ba-qa.sh
	@chmod +x bin/validate-workflows-sync.sh
	@./bin/validate-workflows-sync.sh
	@python3 tests/evals/eval_harness.py

# Phase 12 Brainstorming, Grill-Me & Problem Solving Target
validate-brainstorm: check-traceability validate-workflows-sync
	@chmod +x bin/validate-brainstorm-skills.sh
	@./bin/validate-brainstorm-skills.sh
	@python3 tests/evals/eval_harness.py

# Multi-Agent Workspace Boundary Check
check-boundaries:
	@bash ./bin/check-path-boundaries.sh

# Automated Token Cost Calculation
eval-cost:
	@python3 tests/evals/token_calculator.py

# Test Recovery & Flaky Test Runner Test Target
test-recovery:
	@bash ./bin/safe-agent-run.sh coder test-feature "Testing recovery"

# Multi-Language Supply Chain Scanner
scan-deps:
	@bash ./bin/scan-dependencies.sh

# Skill Auto-Synthesis CLI
synthesize-skill:
	@bash ./bin/synthesize-skill.sh --name "example-skill" --category "devops" --description "Example synthesized skill"

# Export Telemetry Summary & Benchmark Metrics
export-telemetry:
	@python3 tests/evals/export_telemetry_summary.py

# Clean QA evidence
clean:
	rm -rf tests/qa-evidence/*
