#!/usr/bin/env bash
# agy-pipeline.sh — Headless CI runner for agy-kit
#
# Usage: FEATURE=auth-oauth2 ./bin/agy-pipeline.sh
# CI Usage: agy -p "<prompt>" --dangerously-skip-permissions (non-interactive)
#
# Requires: agy CLI installed and authenticated

set -euo pipefail

FEATURE="${FEATURE:-unnamed}"
STAGES="${STAGES:-spec,build,gate,qa,review}"
AUTO_APPROVE="${AUTO_APPROVE:-}"

if [[ "$AUTO_APPROVE" == *"--dangerously-skip-permissions"* ]]; then
    echo "⚠️ WARNING: Running with --dangerously-skip-permissions (UNSAFE EXECUTION PROFILE)"
fi

echo "🚀 agy-kit Pipeline: feature=$FEATURE stages=$STAGES"

run_stage() {
    local stage="$1"
    echo ""
    echo "━━━ Stage: $stage ━━━"
    case "$stage" in
        spec)
            agy -p "Survey and create SPEC for feature $FEATURE at plans/SPEC_${FEATURE}.md following SPEC_TEMPLATE.md" $AUTO_APPROVE
            ;;
        build)
            agy -p "Read plans/SPEC_${FEATURE}.md. Execute TDD: RED → GREEN → REFACTOR." $AUTO_APPROVE
            ;;
        gate)
            agy -p "Run lint, typecheck, gitleaks, OWASP-AI checklist. Fix all issues." $AUTO_APPROVE
            ;;
        qa)
            agy -p "Start local server. Run E2E test. Collect evidence." $AUTO_APPROVE
            ;;
        review)
            agy -p "Review git diff. Pre-commit audit + Conventional Commits." $AUTO_APPROVE
            ;;
        *)
            echo "❌ Unknown stage: $stage"
            exit 1
            ;;
    esac
}

IFS=',' read -ra STAGE_ARRAY <<< "$STAGES"
for stage in "${STAGE_ARRAY[@]}"; do
    run_stage "$stage"
done

echo ""
echo "✅ Pipeline complete: $FEATURE"
