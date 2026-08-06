#!/usr/bin/env bash
# bin/validate-phase10-ba-qa.sh — Phase 10 Business Analysis & Quality Framework Validator
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

log_ok() { echo -e "  [${GREEN}OK${NC}] $1"; }
log_warn() { echo -e "  [${YELLOW}WARN${NC}] $1"; WARNINGS=$((WARNINGS + 1)); }
log_fail() { echo -e "  [${RED}FAIL${NC}] $1"; ERRORS=$((ERRORS + 1)); }

echo "=================================================="
echo -e "   ${BLUE}agy-kit Phase 10 BA-QA & Reliability Audit${NC}"
echo "=================================================="

# 1. Audit BA & QA Skill Existence & Mirroring
SKILLS=("ba-expert" "qa-auditor" "qa-test-gen" "qa-reproducer")

for skill in "${SKILLS[@]}"; do
    HERMES_SKILL=".hermes/skills/$skill/SKILL.md"
    AGY_SKILL=".antigravity/skills/$skill/SKILL.md"
    
    echo "Auditing skill: $skill..."
    if [ -f "$HERMES_SKILL" ]; then
        log_ok "Skill $skill found in .hermes/skills/"
    else
        log_fail "Skill $skill missing from .hermes/skills/"
    fi
    
    if [ -f "$AGY_SKILL" ]; then
        log_ok "Skill $skill found in .antigravity/skills/"
    else
        log_fail "Skill $skill missing from .antigravity/skills/"
    fi
    
    if [ -f "$HERMES_SKILL" ] && [ -f "$AGY_SKILL" ]; then
        if cmp -s "$HERMES_SKILL" "$AGY_SKILL"; then
            log_ok "Skill $skill mirrored perfectly between .hermes/ and .antigravity/"
        else
            log_fail "Skill $skill content mismatch between .hermes/ and .antigravity/!"
        fi
    fi
done

# 2. Audit Specific Skill Content Requirements
echo ""
echo "Auditing Skill Content Requirements..."

BA_EXPERT_FILE=".hermes/skills/ba-expert/SKILL.md"
if [ -f "$BA_EXPERT_FILE" ]; then
    if grep -q "12-Dimensional Business Edge-Case Matrix" "$BA_EXPERT_FILE" && \
       grep -q "Bounded Contexts" "$BA_EXPERT_FILE" && \
       grep -q "Ubiquitous Language" "$BA_EXPERT_FILE" && \
       grep -q "Zod" "$BA_EXPERT_FILE"; then
        log_ok "ba-expert skill contains 12-Dimensional Matrix, Bounded Contexts, Ubiquitous Language, and Zod/Pydantic schemas."
    else
        log_fail "ba-expert skill missing mandatory BA matrix or domain modeling constructs!"
    fi
fi

QA_AUDITOR_FILE=".hermes/skills/qa-auditor/SKILL.md"
if [ -f "$QA_AUDITOR_FILE" ]; then
    if grep -q "audit_summary" "$QA_AUDITOR_FILE" && grep -q "Runtime Risk Matrix" "$QA_AUDITOR_FILE"; then
        log_ok "qa-auditor skill contains JSON Audit Contract & Runtime Risk Matrix."
    else
        log_fail "qa-auditor skill missing JSON Audit Contract or Runtime Risk Matrix!"
    fi
fi

QA_TEST_GEN_FILE=".hermes/skills/qa-test-gen/SKILL.md"
if [ -f "$QA_TEST_GEN_FILE" ]; then
    if grep -q "test_plan" "$QA_TEST_GEN_FILE" && grep -q "Boundary Coverage" "$QA_TEST_GEN_FILE"; then
        log_ok "qa-test-gen skill contains JSON Test Plan Schema & Boundary Coverage rules."
    else
        log_fail "qa-test-gen skill missing JSON Test Plan Schema or Boundary Coverage rules!"
    fi
fi

QA_REPRODUCER_FILE=".hermes/skills/qa-reproducer/SKILL.md"
if [ -f "$QA_REPRODUCER_FILE" ]; then
    if grep -q "reproduction_summary" "$QA_REPRODUCER_FILE" && grep -q "Minimal Reproduction Example" "$QA_REPRODUCER_FILE"; then
        log_ok "qa-reproducer skill contains JSON Bug Reproduction Schema & MRE pipeline."
    else
        log_fail "qa-reproducer skill missing JSON Bug Reproduction Schema or MRE pipeline!"
    fi
fi

# 3. Audit SPEC_TEMPLATE.md
TEMPLATE_FILE="plans/SPEC_TEMPLATE.md"
echo ""
echo "Auditing SPEC_TEMPLATE.md for Phase 10 Artefacts..."
if [ -f "$TEMPLATE_FILE" ]; then
    if grep -q "RTM" "$TEMPLATE_FILE" && grep -q "ACM" "$TEMPLATE_FILE" && grep -q "NFR" "$TEMPLATE_FILE" && grep -q "DFD" "$TEMPLATE_FILE"; then
        log_ok "SPEC_TEMPLATE.md contains RTM, ACM (12-Edge Matrix), NFR, and DFD sections."
    else
        log_fail "SPEC_TEMPLATE.md missing Phase 10 RTM/ACM/NFR/DFD sections!"
    fi
else
    log_fail "SPEC_TEMPLATE.md not found!"
fi

# 4. Audit Framework Documentation
echo ""
echo "Auditing Phase 10 Framework Documentation..."
DOCS=("docs/ba-and-quality-framework.md" "docs/business-analysis.md" "docs/quality-framework.md" "docs/reliability.md")

for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        log_ok "Documentation file $doc exists."
    else
        log_fail "Documentation file $doc missing!"
    fi
done

# 5. Audit Agent JSON Specifications
echo ""
echo "Auditing Agent JSON Specifications for Phase 10 Instructions..."
AGENTS_DIR=".antigravity/agents"

if grep -q "ba-expert" "$AGENTS_DIR/planner.json" && grep -q "12-Dimensional" "$AGENTS_DIR/planner.json"; then
    log_ok "planner.json updated with Phase 10 BA-expert & 12-Dimensional matrix instructions."
else
    log_fail "planner.json missing Phase 10 BA instructions!"
fi

if grep -q "ba-expert" "$AGENTS_DIR/coder.json" && grep -q "qa-auditor" "$AGENTS_DIR/coder.json"; then
    log_ok "coder.json updated with Phase 10 BA & QA skills instructions."
else
    log_fail "coder.json missing Phase 10 skill references!"
fi

if grep -q "plan-review" "$AGENTS_DIR/reviewer.json" && grep -q "ba-expert" "$AGENTS_DIR/reviewer.json"; then
    log_ok "reviewer.json updated with plan-review gate & Phase 10 instructions."
else
    log_fail "reviewer.json missing plan-review gate instructions!"
fi

if grep -q "qa-reproducer" "$AGENTS_DIR/qa.json" && grep -q "qa-auditor" "$AGENTS_DIR/qa.json"; then
    log_ok "qa.json updated with QA skills & MRE bug reproduction pipeline instructions."
else
    log_fail "qa.json missing QA skills or bug reproduction instructions!"
fi

echo "=================================================="
if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}Phase 10 BA-QA Audit Failed with $ERRORS error(s) and $WARNINGS warning(s).${NC}"
    exit 1
else
    echo -e "${GREEN}Phase 10 BA-QA Audit Passed Successfully ($WARNINGS warning(s)).${NC}"
    exit 0
fi
