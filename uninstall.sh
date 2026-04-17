#!/usr/bin/env bash
# Claude Code Setup Uninstaller
# Reads ~/.claude/.installed-from.json to know what was installed,
# then moves those files to a timestamped backup directory.
# NEVER deletes outright — always moves first.

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
MANIFEST_FILE="$CLAUDE_DIR/.installed-from.json"

# ---------------------------------------------------------------------------
# Flag parsing
# ---------------------------------------------------------------------------
DRY_RUN=false
SHOW_HELP=false
LIST_FILES=false
PURGE=false
YES=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --list)    LIST_FILES=true ;;
    --purge)   PURGE=true ;;
    --yes)     YES=true ;;
    --help|-h) SHOW_HELP=true ;;
    *)
      echo "Unknown option: $arg  (use --help)" >&2
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# --help
# ---------------------------------------------------------------------------
if [[ "$SHOW_HELP" == true ]]; then
  cat <<'EOF'
Usage: uninstall.sh [OPTIONS]

Options:
  (none)     Move installed files to ~/.claude.uninstalled-<timestamp>/
  --dry-run  Print what would be moved; do not move anything
  --list     Show the files recorded in the install manifest and exit
  --purge    After moving, permanently delete the backup dir (requires confirmation)
  --yes      Skip interactive confirmation for --purge
  --help     Show this help text and exit

Note: ~/.claude/settings.json is NEVER touched. See output for which keys to remove manually.
EOF
  exit 0
fi

# ---------------------------------------------------------------------------
# Require node for manifest reading
# ---------------------------------------------------------------------------
if ! command -v node &>/dev/null; then
  echo "ERROR: 'node' is required to read the install manifest. Install Node.js and retry." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Build the list of installed files
# (from manifest, or conservative fallback)
# ---------------------------------------------------------------------------
declare -a INSTALLED_FILES=()

if [[ -f "$MANIFEST_FILE" ]]; then
  # Read file list from JSON manifest (paths relative to $HOME)
  mapfile -t INSTALLED_FILES < <(node -e "
    const m = require('$MANIFEST_FILE');
    (m.files || []).forEach(f => console.log(process.env.HOME + '/' + f));
  " 2>/dev/null || true)
  MANIFEST_VERSION="$(node -e "try{const m=require('$MANIFEST_FILE');process.stdout.write(m.version||'unknown')}catch(e){process.stdout.write('unknown')}" 2>/dev/null || echo "unknown")"
else
  echo "WARNING: $MANIFEST_FILE not found. Using conservative fallback list." >&2
  echo "Manual cleanup may be needed for hooks/settings added via hooks/README.md." >&2
  MANIFEST_VERSION="unknown"
  # Conservative fallback
  FALLBACK_RULES=("$CLAUDE_DIR/rules/01-auto-checkpoint.md" "$CLAUDE_DIR/rules/02-scope-control.md"
    "$CLAUDE_DIR/rules/03-error-recovery.md" "$CLAUDE_DIR/rules/04-visual-verification.md"
    "$CLAUDE_DIR/rules/05-session-management.md" "$CLAUDE_DIR/rules/06-destructive-actions.md"
    "$CLAUDE_DIR/rules/07-backup-strategy.md" "$CLAUDE_DIR/rules/08-communication.md"
    "$CLAUDE_DIR/rules/09-vague-prompt-handling.md" "$CLAUDE_DIR/rules/10-testing.md"
    "$CLAUDE_DIR/rules/11-ui-verification.md" "$CLAUDE_DIR/rules/12-memory.md"
    "$CLAUDE_DIR/rules/13-typescript-standards.md" "$CLAUDE_DIR/rules/14-python-standards.md"
    "$CLAUDE_DIR/rules/15-go-standards.md" "$CLAUDE_DIR/rules/16-production-standards.md"
    "$CLAUDE_DIR/rules/17-development-workflow.md" "$CLAUDE_DIR/rules/security.md")
  INSTALLED_FILES=(
    "${FALLBACK_RULES[@]}"
    "$CLAUDE_DIR/commands/setup.md"
    "$CLAUDE_DIR/commands/setup-phases/phase-0.md"
    "$CLAUDE_DIR/commands/setup-phases/phase-1.md"
    "$CLAUDE_DIR/commands/setup-phases/phase-2.md"
    "$CLAUDE_DIR/scripts/cleanup-backups.sh"
    "$CLAUDE_DIR/scripts/session-metrics.sh"
  )
fi

# Also uninstall the manifest file itself
INSTALLED_FILES+=("$MANIFEST_FILE")

# ---------------------------------------------------------------------------
# --list
# ---------------------------------------------------------------------------
if [[ "$LIST_FILES" == true ]]; then
  echo "Installed files (version: $MANIFEST_VERSION):"
  for f in "${INSTALLED_FILES[@]}"; do
    if [[ -f "$f" ]]; then
      echo "  [present]  $f"
    else
      echo "  [missing]  $f"
    fi
  done
  exit 0
fi

# ---------------------------------------------------------------------------
# Destination backup dir
# ---------------------------------------------------------------------------
UNINSTALL_DIR="$HOME/.claude.uninstalled-$(date -u '+%Y%m%dT%H%M%SZ')"

# ---------------------------------------------------------------------------
# --dry-run
# ---------------------------------------------------------------------------
if [[ "$DRY_RUN" == true ]]; then
  echo "=== Dry Run — nothing will be moved ==="
  echo "Would create: $UNINSTALL_DIR/"
  for f in "${INSTALLED_FILES[@]}"; do
    [[ -f "$f" ]] && echo "  MOVE  $f" || echo "  SKIP  $f  (not found)"
  done
  exit 0
fi

# ---------------------------------------------------------------------------
# Default: move installed files to backup dir
# ---------------------------------------------------------------------------
echo "=== Claude Code Setup Uninstaller ==="
echo "Uninstalling version: $MANIFEST_VERSION"
echo ""

moved=0; skipped=0
mkdir -p "$UNINSTALL_DIR"

for f in "${INSTALLED_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    # Preserve relative directory structure
    rel_dir="$(dirname "${f#"$HOME/"}")"
    mkdir -p "$UNINSTALL_DIR/$rel_dir"
    mv "$f" "$UNINSTALL_DIR/$rel_dir/"
    (( moved++ )) || true
    echo "  moved: $f"
  else
    (( skipped++ )) || true
  fi
done

echo ""
echo "Moved $moved file(s) to $UNINSTALL_DIR/  ($skipped not found, skipped)"
echo ""

# --purge: delete the backup dir after moving
if [[ "$PURGE" == true ]]; then
  if [[ "$YES" == false ]]; then
    read -r -p "Permanently delete $UNINSTALL_DIR? This CANNOT be undone. Type YES to confirm: " confirm
    if [[ "$confirm" != "YES" ]]; then
      echo "Purge cancelled. Files remain in $UNINSTALL_DIR/"
      exit 0
    fi
  fi
  rm -rf "$UNINSTALL_DIR"
  echo "Purged: $UNINSTALL_DIR deleted."
fi

echo "To fully reset: remove the backup dir at $HOME/.claude.uninstalled-* after verifying nothing important is in it."
echo ""
echo "NOTE: ~/.claude/settings.json was NOT modified."
echo "      To complete the reset, remove the 'hooks' key from that file manually."
