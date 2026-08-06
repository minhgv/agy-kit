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
                "Khảo sát và tạo SPEC cho tính năng $FEATURE tại plans/SPEC_${FEATURE}.md theo SPEC_TEMPLATE.md"
            ;;
        build)
            agy run $AUTO_APPROVE --agent coder \
                "Đọc plans/SPEC_${FEATURE}.md. Thực hiện TDD: RED → GREEN → REFACTOR."
            ;;
        gate)
            agy run $AUTO_APPROVE --agent reviewer \
                "Chạy lint, typecheck, gitleaks, OWASP-AI checklist. Sửa mọi lỗi."
            ;;
        qa)
            agy run $AUTO_APPROVE --agent qa \
                "Khởi động local server. Chạy E2E test. Thu thập evidence."
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
