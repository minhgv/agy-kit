#!/usr/bin/env bash
# bin/validate-brainstorm-skills.sh — Phase 12 Brainstorming, Grill-Me & Problem Solving Validator
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
echo -e "   ${BLUE}agy-kit Phase 12 Brainstorming, Grill & Solve Audit${NC}"
echo "=================================================="

HERMES_SKILLS_DIR=".hermes/skills"
AGY_SKILLS_DIR=".antigravity/skills"
WORKFLOWS_DIR=".antigravity/workflows"
AGENTS_DIR=".antigravity/agents"

# 1. Audit Skill Existence & Perfect Synchronization
echo ""
echo "1. Auditing Skill Files & Mirroring (.hermes <-> .antigravity)..."

CORE_SKILLS=("brainstorming" "grill-me" "problem-solving")
for skill in "${CORE_SKILLS[@]}"; do
    HERMES_SKILL="$HERMES_SKILLS_DIR/$skill/SKILL.md"
    AGY_SKILL="$AGY_SKILLS_DIR/$skill/SKILL.md"

    if [ -f "$HERMES_SKILL" ] && [ -f "$AGY_SKILL" ]; then
        if cmp -s "$HERMES_SKILL" "$AGY_SKILL"; then
            log_ok "Skill $skill is 100% synchronized between .hermes/ and .antigravity/"
        else
            log_fail "Skill $skill content mismatch between .hermes/ and .antigravity/!"
        fi
    else
        log_fail "Skill $skill missing from .hermes/skills/ or .antigravity/skills/!"
    fi
done

# Audit problem-solving reference files
PS_REFERENCES=(
    "attribution.md"
    "collision-zone-thinking.md"
    "inversion-exercise.md"
    "meta-pattern-recognition.md"
    "scale-game.md"
    "simplification-cascades.md"
    "when-stuck.md"
)

echo "Auditing problem-solving reference files..."
for ref in "${PS_REFERENCES[@]}"; do
    H_REF="$HERMES_SKILLS_DIR/problem-solving/references/$ref"
    A_REF="$AGY_SKILLS_DIR/problem-solving/references/$ref"

    if [ -f "$H_REF" ] && [ -f "$A_REF" ]; then
        if cmp -s "$H_REF" "$A_REF"; then
            log_ok "Reference $ref is 100% synchronized between .hermes/ and .antigravity/"
        else
            log_fail "Reference $ref content mismatch between .hermes/ and .antigravity/!"
        fi
    else
        log_fail "Reference $ref missing from .hermes/ or .antigravity/!"
    fi
done

# 2. Audit Specific Skill Content Requirements
echo ""
echo "2. Auditing Skill Content Requirements..."

BRAINSTORM_FILE="$HERMES_SKILLS_DIR/brainstorming/SKILL.md"
if [ -f "$BRAINSTORM_FILE" ]; then
    if grep -q "Known knowns" "$BRAINSTORM_FILE" && \
       grep -q "Known unknowns" "$BRAINSTORM_FILE" && \
       grep -q "Unknown knowns" "$BRAINSTORM_FILE" && \
       grep -q "Unknown unknowns" "$BRAINSTORM_FILE"; then
        log_ok "brainstorming skill contains 4-category unknown classification."
    else
        log_fail "brainstorming skill missing 4-category unknown classification!"
    fi
fi

GRILL_FILE="$HERMES_SKILLS_DIR/grill-me/SKILL.md"
if [ -f "$GRILL_FILE" ]; then
    if grep -q "assumptions" "$GRILL_FILE" && \
       grep -q "most likely thing to fail" "$GRILL_FILE" && \
       grep -q "rollback plan" "$GRILL_FILE"; then
        log_ok "grill-me skill contains mandatory scrutiny questions & rollback checks."
    else
        log_fail "grill-me skill missing scrutiny questions or rollback checks!"
    fi
fi

PS_FILE="$HERMES_SKILLS_DIR/problem-solving/SKILL.md"
if [ -f "$PS_FILE" ]; then
    if grep -q "Simplification Cascades" "$PS_FILE" && \
       grep -q "Collision-Zone Thinking" "$PS_FILE" && \
       grep -q "Meta-Pattern Recognition" "$PS_FILE" && \
       grep -q "Inversion Exercise" "$PS_FILE" && \
       grep -q "Scale Game" "$PS_FILE"; then
        log_ok "problem-solving skill contains all 5 core problem-solving techniques."
    else
        log_fail "problem-solving skill missing core techniques!"
    fi
fi

# 3. Audit Dedicated Slash-Command Workflows
echo ""
echo "3. Auditing Workflows in $WORKFLOWS_DIR..."

WORKFLOWS=("brainstorm.md" "grill.md" "solve.md")
for wf in "${WORKFLOWS[@]}"; do
    WF_PATH="$WORKFLOWS_DIR/$wf"
    if [ -f "$WF_PATH" ]; then
        log_ok "Workflow $wf exists."
    else
        log_fail "Workflow $wf missing from $WORKFLOWS_DIR!"
    fi
done

if grep -q "brainstorming" "$WORKFLOWS_DIR/brainstorm.md" && grep -q "/brainstorm" "$WORKFLOWS_DIR/brainstorm.md"; then
    log_ok "brainstorm.md correctly invokes brainstorming skill & /brainstorm command."
else
    log_fail "brainstorm.md missing skill or command reference!"
fi

if grep -q "grill-me" "$WORKFLOWS_DIR/grill.md" && grep -q "/grill" "$WORKFLOWS_DIR/grill.md"; then
    log_ok "grill.md correctly invokes grill-me skill & /grill command."
else
    log_fail "grill.md missing skill or command reference!"
fi

if grep -q "problem-solving" "$WORKFLOWS_DIR/solve.md" && grep -q "/solve" "$WORKFLOWS_DIR/solve.md"; then
    log_ok "solve.md correctly invokes problem-solving skill & /solve command."
else
    log_fail "solve.md missing skill or command reference!"
fi

# 4. Audit Agent Specifications for Phase 12 Skills
echo ""
echo "4. Auditing Agent JSON Specs ($AGENTS_DIR) for Phase 12 Skills..."

AGENTS=("planner.json" "coder.json" "reviewer.json" "qa.json")
for agent in "${AGENTS[@]}"; do
    AGENT_PATH="$AGENTS_DIR/$agent"
    if [ -f "$AGENT_PATH" ]; then
        if grep -q "brainstorming" "$AGENT_PATH" && grep -q "grill-me" "$AGENT_PATH" && grep -q "problem-solving" "$AGENT_PATH"; then
            log_ok "$agent updated with Phase 12 skills (brainstorming, grill-me, problem-solving)."
        else
            log_fail "$agent missing Phase 12 skill references!"
        fi
    else
        log_fail "Agent spec $agent missing!"
    fi
done

# 5. Audit Documentation for Phase 12 Content
echo ""
echo "5. Auditing Documentation (AGENTS.md & docs/ba-and-quality-framework.md)..."

if grep -q "Problem Solving, Ideation & Stress Testing" "AGENTS.md"; then
    log_ok "AGENTS.md contains Section 9 (Problem Solving, Ideation & Stress Testing)."
else
    log_fail "AGENTS.md missing Section 9!"
fi

FRAMEWORK_DOC="docs/ba-and-quality-framework.md"
if [ -f "$FRAMEWORK_DOC" ]; then
    if grep -q "Brainstorming" "$FRAMEWORK_DOC" && grep -q "Stress Testing" "$FRAMEWORK_DOC" && grep -q "Problem Solving" "$FRAMEWORK_DOC"; then
        log_ok "docs/ba-and-quality-framework.md contains Phase 12 Ideation, Stress Testing, and Problem Solving protocols."
    else
        log_fail "docs/ba-and-quality-framework.md missing Phase 12 protocols!"
    fi
else
    log_fail "docs/ba-and-quality-framework.md not found!"
fi

echo "=================================================="
if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}Phase 12 Audit Failed with $ERRORS error(s) and $WARNINGS warning(s).${NC}"
    exit 1
else
    echo -e "${GREEN}Phase 12 Audit Passed Successfully ($WARNINGS warning(s)).${NC}"
    exit 0
fi
