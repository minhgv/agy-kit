#!/usr/bin/env bash
# init-agy-kit.sh — Safe Non-Destructive Developer Scaffolding Installer CLI for agy-kit (FR-SAFE-005)
#
# Usage:
#   ./bin/init-agy-kit.sh --target /path/to/project --lang python [--dry-run] [--force]
#   ./bin/init-agy-kit.sh --help

set -euo pipefail

SHOW_HELP=0
DRY_RUN=0
FORCE=0
TARGET_DIR="."
LANG_CHOICE="python"

show_usage() {
    cat << 'EOF'
==================================================
  agy-kit Safe Developer Scaffolding Installer CLI
==================================================
Usage:
  init-agy-kit.sh [OPTIONS]

Options:
  -t, --target DIR     Target directory to scaffold (default: .)
  -l, --lang LANG      Primary project language: python | go | rust | php | ts (default: python)
  --dry-run            Display actions without modifying the filesystem
  -f, --force          Allow overwriting existing files (creates backup automatically)
  -h, --help           Show this help message and exit

Examples:
  ./bin/init-agy-kit.sh --target ./my-app --lang python --dry-run
  ./bin/init-agy-kit.sh --target ./go-service --lang go --force

EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            SHOW_HELP=1
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -f|--force)
            FORCE=1
            shift
            ;;
        -t|--target)
            TARGET_DIR="$2"
            shift 2
            ;;
        -l|--lang)
            LANG_CHOICE="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown option $1"
            show_usage
            exit 1
            ;;
    esac
done

if [[ "$SHOW_HELP" -eq 1 ]]; then
    show_usage
    exit 0
fi

# Normalize language choice
LANG_CHOICE="$(echo "$LANG_CHOICE" | tr '[:upper:]' '[:lower:]')"
case "$LANG_CHOICE" in
    python|py) LANG_CHOICE="python" ;;
    go|golang) LANG_CHOICE="go" ;;
    rust|rs) LANG_CHOICE="rust" ;;
    php|laravel) LANG_CHOICE="php" ;;
    ts|typescript|node|javascript|js) LANG_CHOICE="ts" ;;
    *)
        echo "[ERROR] Unsupported language '$LANG_CHOICE'. Supported: python, go, rust, php, ts"
        exit 1
        ;;
esac

echo "=================================================="
echo "   Scaffolding agy-kit Developer Environment      "
echo "=================================================="
echo "Target Directory : $TARGET_DIR"
echo "Language Choice  : $LANG_CHOICE"
echo "Dry Run          : $DRY_RUN"
echo "Force Overwrite  : $FORCE"
echo ""

if [ "$DRY_RUN" -eq 1 ]; then
    echo "🔍 DRY-RUN MODE ACTIVE: No files will be created or modified."
    echo "Would create directories: $TARGET_DIR/.agents/agents, $TARGET_DIR/.agents/skills, $TARGET_DIR/.agents/workflows"
    echo "Would scaffold: AGENTS.md, mcp_config.json, install-manifest.json, native subagent Markdown specs"
    exit 0
fi

# Safety check for non-destructive behavior
if [ -f "$TARGET_DIR/AGENTS.md" ] && [ "$FORCE" -eq 0 ]; then
    echo "❌ ERROR: Target directory already contains AGENTS.md!"
    echo "Use --force to permit overwriting (an automatic backup will be created)."
    exit 1
fi

if [ "$FORCE" -eq 1 ] && [ -d "$TARGET_DIR/.agents" ]; then
    BACKUP_DIR="${TARGET_DIR}/.agents_backup_$(date +%s)"
    echo "📦 Creating safety backup of existing .agents configuration at $BACKUP_DIR..."
    cp -r "$TARGET_DIR/.agents" "$BACKUP_DIR"
fi

mkdir -p "$TARGET_DIR/.agents/agents"
mkdir -p "$TARGET_DIR/.agents/skills"
mkdir -p "$TARGET_DIR/.agents/workflows"
mkdir -p "$TARGET_DIR/.githooks"
mkdir -p "$TARGET_DIR/plans"
mkdir -p "$TARGET_DIR/docs"

# Copy scaffold assets from src/templates/ if available, otherwise use defaults
TEMPLATES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../src/templates" 2>/dev/null && pwd || echo "")"

if [ -n "$TEMPLATES_DIR" ] && [ -d "$TEMPLATES_DIR" ]; then
    echo "📦 Copying scaffolding assets from $TEMPLATES_DIR..."
    sed "s/\${LANG}/$LANG_CHOICE/g" "$TEMPLATES_DIR/AGENTS.md.tpl" > "$TARGET_DIR/AGENTS.md"
    cp "$TEMPLATES_DIR/mcp_config.json.tpl" "$TARGET_DIR/.agents/mcp_config.json"
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    sed "s/\${TIMESTAMP}/$TIMESTAMP/g" "$TEMPLATES_DIR/version.json.tpl" > "$TARGET_DIR/.agents/version.json"
    cp "$TEMPLATES_DIR/agents/"*.md "$TARGET_DIR/.agents/agents/"
else
    # Fallback to inline default generation
    cat << 'EOF' > "$TARGET_DIR/.agents/version.json"
{
  "version": "1.0.0-RC",
  "schema_version": "2.0.0",
  "generator": "init-agy-kit.sh",
  "installed_at": "2026-08-06T00:00:00Z"
}
EOF
fi

# 4. Installation Manifest
cat << EOF > "$TARGET_DIR/.agents/install-manifest.json"
{
  "installed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "target_directory": "$TARGET_DIR",
  "language": "$LANG_CHOICE",
  "version": "1.0.0-RC",
  "safe_mode": true
}
EOF

# 5. AGENTS.md tailored to language
cat << EOF > "$TARGET_DIR/AGENTS.md"
# AGENTS.md — agy-kit Project Rules ($LANG_CHOICE)

> **agy-kit scaffolded project** ($LANG_CHOICE) — rules, subagents, quality gates, and workflow contracts.

## 1. Planning First Rule
- Features touching >3 files or changing architecture MUST create \`plans/SPEC_<feature>.md\` first.

## 2. Test-Driven Development (TDD)
- Language: **$LANG_CHOICE**
- Cycle: RED -> GREEN -> REFACTOR.

## 3. Strict Quality Gates
- Gate L1: Zero linter/typecheck errors.
- Gate L2: All unit tests pass.
- Gate L3: Integration tests pass.
- Gate L4: E2E boundary tests pass.
- Gate L5: OWASP security audit approved.
EOF

echo "[SUCCESS] agy-kit successfully scaffolded in $TARGET_DIR ($LANG_CHOICE)!"
