#!/usr/bin/env bash
# bin/validate-workflows-sync.sh — Workflow, Agent Spec & Skill Alignment Validator
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
echo -e "   ${BLUE}agy-kit Workflows, Agents & Skills Sync Audit${NC}"
echo "=================================================="

WORKFLOWS_DIR=".antigravity/workflows"
AGENTS_DIR=".antigravity/agents"
HERMES_SKILLS_DIR=".hermes/skills"
AGY_SKILLS_DIR=".antigravity/skills"
AGENTS_MIRROR_DIR=".agents"

# 1. Audit Workflow Files Existence
echo ""
echo "Auditing Workflow Files in $WORKFLOWS_DIR..."
REQUIRED_WORKFLOWS=("pipeline.md" "plan.md" "gate.md" "review.md" "qa.md" "safe-pipeline.md")

for wf in "${REQUIRED_WORKFLOWS[@]}"; do
    WF_PATH="$WORKFLOWS_DIR/$wf"
    if [ -f "$WF_PATH" ]; then
        log_ok "Workflow file $wf exists."
    else
        log_fail "Workflow file $wf is missing from $WORKFLOWS_DIR!"
    fi
done

# 2. Audit Workflow Invocations of BA & QA Skills, RTM, 12D Edge Cases & Scripts
echo ""
echo "Auditing Workflow Skill & Tool Invocations..."

# Required skills across workflows
SKILLS=("brainstorming" "ba-expert" "grill-me" "tdd-workflow" "qa-test-gen" "quality-gate" "qa-auditor" "problem-solving" "qa-reproducer" "writing-skills")

for wf in "${REQUIRED_WORKFLOWS[@]}"; do
    WF_PATH="$WORKFLOWS_DIR/$wf"
    [ -f "$WF_PATH" ] || continue

    echo "Checking skills & references in $wf..."

    # Check RTM reference
    if grep -q "RTM" "$WF_PATH"; then
        log_ok "$wf references RTM (Requirements Traceability Matrix)"
    else
        log_fail "$wf missing RTM reference"
    fi

    # Check 12-Dimensional Edge Case reference
    if grep -qi "12-Dimensional" "$WF_PATH" || grep -qi "12D" "$WF_PATH"; then
        log_ok "$wf references 12-Dimensional Edge Case Matrix"
    else
        log_fail "$wf missing 12-Dimensional Edge Case Matrix reference"
    fi

    # Check script references (validate-traceability.sh)
    if grep -q "validate-traceability.sh" "$WF_PATH"; then
        log_ok "$wf references validate-traceability.sh"
    else
        log_fail "$wf missing validate-traceability.sh reference"
    fi
done

# Specific skill invocations check in workflows
if grep -q "ba-expert" "$WORKFLOWS_DIR/pipeline.md" && grep -q "ba-expert" "$WORKFLOWS_DIR/plan.md"; then
    log_ok "ba-expert skill invoked in planning workflows"
else
    log_fail "ba-expert skill missing from planning workflows!"
fi

if grep -q "qa-test-gen" "$WORKFLOWS_DIR/pipeline.md" && grep -q "qa-test-gen" "$WORKFLOWS_DIR/qa.md"; then
    log_ok "qa-test-gen skill invoked in coding & QA workflows"
else
    log_fail "qa-test-gen skill missing from coding/QA workflows!"
fi

if grep -q "qa-auditor" "$WORKFLOWS_DIR/pipeline.md" && grep -q "qa-auditor" "$WORKFLOWS_DIR/gate.md" && grep -q "qa-auditor" "$WORKFLOWS_DIR/review.md"; then
    log_ok "qa-auditor skill invoked in gate & review workflows"
else
    log_fail "qa-auditor skill missing from gate/review workflows!"
fi

if grep -q "qa-reproducer" "$WORKFLOWS_DIR/pipeline.md" && grep -q "qa-reproducer" "$WORKFLOWS_DIR/qa.md"; then
    log_ok "qa-reproducer skill invoked in E2E QA workflows"
else
    log_fail "qa-reproducer skill missing from E2E QA workflows!"
fi

if grep -q "scan-dependencies.sh" "$WORKFLOWS_DIR/gate.md" && grep -q "scan-dependencies.sh" "$WORKFLOWS_DIR/safe-pipeline.md"; then
    log_ok "scan-dependencies.sh referenced in gate workflows"
else
    log_fail "scan-dependencies.sh missing from gate workflows!"
fi

if grep -q "3-State Verification" "$WORKFLOWS_DIR/review.md" && grep -q "3-State Verification" "$WORKFLOWS_DIR/pipeline.md"; then
    log_ok "3-State Verification referenced in review & pipeline workflows"
else
    log_fail "3-State Verification missing from review/pipeline workflows!"
fi

# 3. Audit Agent JSON Specifications Alignment
echo ""
echo "Auditing Agent Specs ($AGENTS_DIR) Alignment with Skills..."

REQUIRED_AGENTS=("planner.json" "coder.json" "reviewer.json" "qa.json")
for agent in "${REQUIRED_AGENTS[@]}"; do
    AGENT_PATH="$AGENTS_DIR/$agent"
    if [ -f "$AGENT_PATH" ]; then
        log_ok "Agent spec $agent exists."
    else
        log_fail "Agent spec $agent missing!"
    fi
done

if [ -f "$AGENTS_DIR/planner.json" ] && grep -q "ba-expert" "$AGENTS_DIR/planner.json"; then
    log_ok "planner.json aligns with ba-expert skill."
else
    log_fail "planner.json missing ba-expert skill reference!"
fi

if [ -f "$AGENTS_DIR/coder.json" ] && (grep -q "qa-test-gen" "$AGENTS_DIR/coder.json" || grep -q "qa-auditor" "$AGENTS_DIR/coder.json"); then
    log_ok "coder.json aligns with QA skills suite."
else
    log_fail "coder.json missing QA skills suite reference!"
fi

if [ -f "$AGENTS_DIR/reviewer.json" ] && grep -q "qa-auditor" "$AGENTS_DIR/reviewer.json"; then
    log_ok "reviewer.json aligns with qa-auditor skill."
else
    log_fail "reviewer.json missing qa-auditor skill reference!"
fi

if [ -f "$AGENTS_DIR/qa.json" ] && grep -q "qa-reproducer" "$AGENTS_DIR/qa.json"; then
    log_ok "qa.json aligns with qa-reproducer skill."
else
    log_fail "qa.json missing qa-reproducer skill reference!"
fi

# 4. Audit Skill Mirroring & Integrity (.hermes/skills <-> .antigravity/skills <-> .agents/skills)
echo ""
echo "Auditing Skill Mirroring and Integrity..."

for skill in "${SKILLS[@]}"; do
    HERMES_SKILL="$HERMES_SKILLS_DIR/$skill/SKILL.md"
    AGY_SKILL="$AGY_SKILLS_DIR/$skill/SKILL.md"
    AGENTS_SKILL="$AGENTS_MIRROR_DIR/skills/$skill/SKILL.md"

    if [ -f "$HERMES_SKILL" ] && [ -f "$AGY_SKILL" ] && [ -f "$AGENTS_SKILL" ]; then
        if cmp -s "$HERMES_SKILL" "$AGY_SKILL" && cmp -s "$AGY_SKILL" "$AGENTS_SKILL"; then
            log_ok "Skill $skill is 100% synchronized across .hermes/, .antigravity/, and .agents/"
        else
            log_fail "Skill $skill content mismatch across .hermes/, .antigravity/, or .agents/!"
        fi
    else
        log_fail "Skill $skill missing from .hermes/skills/, .antigravity/skills/, or .agents/skills/!"
    fi
done

# 5. Audit .agents/ Directory Mirror Structure
echo ""
echo "Auditing .agents/ Directory Mirror Structure..."
if [ -f "$AGENTS_MIRROR_DIR/mcp_config.json" ]; then
    log_ok ".agents/mcp_config.json exists."
else
    log_fail ".agents/mcp_config.json missing!"
fi

for agent in "${REQUIRED_AGENTS[@]}"; do
    if [ -f "$AGENTS_MIRROR_DIR/agents/$agent" ]; then
        log_ok ".agents/agents/$agent exists."
    else
        log_fail ".agents/agents/$agent missing!"
    fi
done

for wf in "${REQUIRED_WORKFLOWS[@]}"; do
    if [ -f "$AGENTS_MIRROR_DIR/workflows/$wf" ]; then
        log_ok ".agents/workflows/$wf exists."
    else
        log_fail ".agents/workflows/$wf missing!"
    fi
done

echo "=================================================="
if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}Workflows Sync Audit Failed with $ERRORS error(s) and $WARNINGS warning(s).${NC}"
    exit 1
else
    echo -e "${GREEN}Workflows Sync Audit Passed Successfully ($WARNINGS warning(s)).${NC}"
    exit 0
fi
