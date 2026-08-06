#!/usr/bin/env bash
# agy-pipeline.sh — Headless CI runner for agy-kit
#
# Usage: FEATURE=auth-oauth2 ./bin/agy-pipeline.sh
# CI Usage: agy run -p --auto-approve --agent plan "..." (non-interactive)
#
# Requires: agy CLI installed and authenticated

set -euo pipefail

FEATURE="${FEATURE:-unnamed}"
STAGES="${STAGES:-spec,build,gate,qa,review}"
AUTO_APPROVE="${AUTO_APPROVE:---auto-approve}"

echo "🚀 agy-kit Pipeline: feature=$FEATURE stages=$STAGES"

run_stage() {
    local stage="$1"
    echo ""
    echo "━━━ Stage: $stage ━━━"
    case "$stage" in
        spec)
            agy run $AUTO_APPROVE --agent plan \
                "Survey and create SPEC for feature $FEATURE at plans/SPEC_${FEATURE}.md following SPEC_TEMPLATE.md"
            ;;
        build)
            agy run $AUTO_APPROVE --agent coder \
                "Read plans/SPEC_${FEATURE}.md. Execute TDD: RED → GREEN → REFACTOR."
            ;;
        gate)
            agy run $AUTO_APPROVE --agent reviewer \
                "Run lint, typecheck, gitleaks, OWASP-AI checklist. Fix all issues."
            ;;
        qa)
            agy run $AUTO_APPROVE --agent qa \
                "Start local server. Run E2E test. Collect evidence."
            ;;
        review)
            agy run $AUTO_APPROVE --agent reviewer \
                "Review git diff. Pre-commit audit + Conventional Commits."
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
