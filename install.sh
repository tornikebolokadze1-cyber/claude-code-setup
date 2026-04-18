#!/bin/bash
# Claude Code Setup Installer
# Copies rules, commands, hooks, templates, and scripts to ~/.claude/

set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude Code Setup Installer ==="
echo ""

# Check if ~/.claude exists
if [ ! -d "$CLAUDE_DIR" ]; then
  echo "Creating $CLAUDE_DIR..."
  mkdir -p "$CLAUDE_DIR"
fi

# Backup existing files
BACKUP_DIR="$CLAUDE_DIR/backup-$(date '+%Y%m%d-%H%M%S')"
NEEDS_BACKUP=false

for dir in rules commands scripts; do
  if [ -d "$CLAUDE_DIR/$dir" ] && [ "$(ls -A "$CLAUDE_DIR/$dir" 2>/dev/null)" ]; then
    NEEDS_BACKUP=true
    break
  fi
done

if [ "$NEEDS_BACKUP" = true ]; then
  echo "Backing up existing config to $BACKUP_DIR..."
  mkdir -p "$BACKUP_DIR"
  [ -d "$CLAUDE_DIR/rules" ]    && cp -r "$CLAUDE_DIR/rules"    "$BACKUP_DIR/" 2>/dev/null || true
  [ -d "$CLAUDE_DIR/commands" ] && cp -r "$CLAUDE_DIR/commands" "$BACKUP_DIR/" 2>/dev/null || true
  [ -d "$CLAUDE_DIR/scripts" ]  && cp -r "$CLAUDE_DIR/scripts"  "$BACKUP_DIR/" 2>/dev/null || true
  echo "  Backup saved."
fi

# Copy rules
echo "Installing rules..."
mkdir -p "$CLAUDE_DIR/rules"
cp "$SCRIPT_DIR"/rules/*.md "$CLAUDE_DIR/rules/"
echo "  $(ls "$SCRIPT_DIR"/rules/*.md | wc -l | tr -d ' ') rule files installed."

# Copy commands
echo "Installing /setup-AI-Pulse-Georgia command and phase files..."
mkdir -p "$CLAUDE_DIR/commands/setup-phases"
cp "$SCRIPT_DIR"/commands/setup-AI-Pulse-Georgia.md "$CLAUDE_DIR/commands/"
cp "$SCRIPT_DIR"/commands/setup-phases/*.md "$CLAUDE_DIR/commands/setup-phases/"
cp "$SCRIPT_DIR"/commands/setup.md "$CLAUDE_DIR/commands/"
echo "  /setup-AI-Pulse-Georgia command installed (+ phase files + deprecation alias)."

# Copy scripts (including verify-local-sync.sh)
echo "Installing scripts..."
mkdir -p "$CLAUDE_DIR/scripts"
cp "$SCRIPT_DIR"/scripts/*.sh "$CLAUDE_DIR/scripts/"
chmod +x "$CLAUDE_DIR/scripts/"*.sh
echo "  Scripts installed ($(ls "$SCRIPT_DIR"/scripts/*.sh | wc -l | tr -d ' ') files)."
echo "  verify-local-sync.sh is now available at: $CLAUDE_DIR/scripts/verify-local-sync.sh"

# Copy bootstrap templates (including CLAUDE.md and .env.example per template)
echo "Installing bootstrap templates..."
mkdir -p "$CLAUDE_DIR/bootstrap-templates"
cp -r "$SCRIPT_DIR"/bootstrap-templates/* "$CLAUDE_DIR/bootstrap-templates/"
echo "  $(ls -d "$SCRIPT_DIR"/bootstrap-templates/*/ | wc -l | tr -d ' ') templates installed."
echo "  Each template includes: CLAUDE.md, .env.example, STRUCTURE.md"

# Hooks notice
echo ""
echo "=== Hooks Configuration ==="
echo "Hooks need to be added to your settings.json manually."
echo "The hooks config is at: hooks/settings-hooks.json"
echo ""
echo "To add hooks, merge the content into:"
echo "  $CLAUDE_DIR/settings.json"
echo ""

# Summary
echo "=== Installation Complete ==="
echo ""
echo "Installed:"
echo "  Rules:     $CLAUDE_DIR/rules/ ($(ls "$CLAUDE_DIR/rules/"*.md 2>/dev/null | wc -l | tr -d ' ') files)"
echo "  Command:   $CLAUDE_DIR/commands/setup-AI-Pulse-Georgia.md (+ setup-phases/)"
echo "  Scripts:   $CLAUDE_DIR/scripts/ ($(ls "$CLAUDE_DIR/scripts/"*.sh 2>/dev/null | wc -l | tr -d ' ') files)"
echo "  Templates: $CLAUDE_DIR/bootstrap-templates/ ($(ls -d "$CLAUDE_DIR/bootstrap-templates/"*/ 2>/dev/null | wc -l | tr -d ' ') templates)"
echo ""
echo "Usage:"
echo "  Primary:    /setup-AI-Pulse-Georgia  — bootstrap any new or existing project"
echo "  Deprecated: /setup                   — alias, will be removed in v0.3"
echo ""
echo "Sync verification:"
echo "  Run '$CLAUDE_DIR/scripts/verify-local-sync.sh' any time to check"
echo "  that your local ~/.claude/ is in sync with the repo."
echo ""
echo "Done!"
