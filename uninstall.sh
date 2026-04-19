#!/bin/bash
# Claude Code Setup Uninstaller — v0.4.1+
# Removes rules/commands/scripts/hooks/templates/archive installed by install.sh.
# Preserves user's own settings.json, settings.local.json, memory, and any file
# the user added themselves under ~/.claude/.
#
# Safe by default: shows what would be removed and asks for confirmation.
# Pass --yes to skip confirmation.

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
ASSUME_YES=false

for arg in "$@"; do
  case "$arg" in
    --yes|-y) ASSUME_YES=true ;;
    --help|-h)
      cat <<'EOF'
Usage: ./uninstall.sh [--yes]

Removes these claude-code-setup-installed directories from ~/.claude/:
  - rules/ (all .md files matching NN-*.md + security.md + README.md)
  - commands/setup-AI-Pulse-Georgia.md + setup-phases/ + setup.md alias
  - scripts/ (shell + mjs files shipped by this project)
  - hooks/ (settings-hooks.json, .windows.json, reference/, README.md)
  - templates/ (CLAUDE.md.example, settings.local.json.example, README.md)
  - archive/bootstrap-templates/ (legacy templates)

Preserves:
  - ~/.claude/settings.json (your personal config)
  - ~/.claude/settings.local.json (local overrides)
  - ~/.claude/memory/ (auto-memory across sessions)
  - ~/.claude/projects/ (Claude Code's own state)
  - Any file under ~/.claude/ not originally shipped by this project

Creates a backup at ~/.claude/backup-uninstall-<timestamp>/ before removing.
EOF
      exit 0
      ;;
  esac
done

if [ ! -d "$CLAUDE_DIR" ]; then
  echo "~/.claude does not exist. Nothing to uninstall."
  exit 0
fi

BACKUP_DIR="$CLAUDE_DIR/backup-uninstall-$(date '+%Y%m%d-%H%M%S')"

echo "=== claude-code-setup uninstaller ==="
echo ""
echo "Will remove from $CLAUDE_DIR:"
for d in rules commands/setup-phases hooks/reference archive/bootstrap-templates templates; do
  if [ -d "$CLAUDE_DIR/$d" ]; then
    COUNT=$(find "$CLAUDE_DIR/$d" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "  $d/ ($COUNT files)"
  fi
done
for f in commands/setup-AI-Pulse-Georgia.md commands/setup.md; do
  if [ -f "$CLAUDE_DIR/$f" ]; then
    echo "  $f"
  fi
done

echo ""
echo "Will preserve:"
echo "  settings.json, settings.local.json, memory/, projects/, keybindings.json"
echo "  plus any .md file under rules/ not matching the shipped set"

if [ "$ASSUME_YES" = false ]; then
  read -r -p "Continue? Type 'yes' to proceed: " CONFIRM
  if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 1
  fi
fi

mkdir -p "$BACKUP_DIR"
echo "Backing up removed files to $BACKUP_DIR..."

# Backup then remove each directory
for d in rules commands/setup-phases hooks/reference archive/bootstrap-templates templates; do
  if [ -d "$CLAUDE_DIR/$d" ]; then
    cp -r "$CLAUDE_DIR/$d" "$BACKUP_DIR/" 2>/dev/null || true
    rm -rf "$CLAUDE_DIR/$d"
    echo "  Removed $d/"
  fi
done

# Remove specific files
for f in commands/setup-AI-Pulse-Georgia.md commands/setup.md hooks/settings-hooks.json hooks/settings-hooks.windows.json hooks/README.md; do
  if [ -f "$CLAUDE_DIR/$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$CLAUDE_DIR/$f" "$BACKUP_DIR/$f" 2>/dev/null || true
    rm "$CLAUDE_DIR/$f"
    echo "  Removed $f"
  fi
done

# Remove empty parent dirs (hooks/ archive/ commands/) if they're empty now
for d in hooks archive commands; do
  if [ -d "$CLAUDE_DIR/$d" ] && [ -z "$(ls -A "$CLAUDE_DIR/$d" 2>/dev/null)" ]; then
    rmdir "$CLAUDE_DIR/$d"
    echo "  Removed empty $d/"
  fi
done

echo ""
echo "Uninstall complete. Backup: $BACKUP_DIR"
echo "Your personal settings and memory were preserved."
