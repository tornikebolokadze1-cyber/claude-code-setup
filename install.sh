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
  [ -d "$CLAUDE_DIR/rules" ] && cp -r "$CLAUDE_DIR/rules" "$BACKUP_DIR/" 2>/dev/null || true
  [ -d "$CLAUDE_DIR/commands" ] && cp -r "$CLAUDE_DIR/commands" "$BACKUP_DIR/" 2>/dev/null || true
  [ -d "$CLAUDE_DIR/scripts" ] && cp -r "$CLAUDE_DIR/scripts" "$BACKUP_DIR/" 2>/dev/null || true
  echo "  Backup saved."
fi

# Copy rules
echo "Installing rules..."
mkdir -p "$CLAUDE_DIR/rules"
cp "$SCRIPT_DIR"/rules/*.md "$CLAUDE_DIR/rules/"
echo "  $(ls "$SCRIPT_DIR"/rules/*.md | wc -l | tr -d ' ') rule files installed."

# Copy commands
echo "Installing /setup command..."
mkdir -p "$CLAUDE_DIR/commands"
cp "$SCRIPT_DIR"/commands/setup.md "$CLAUDE_DIR/commands/"
echo "  /setup command installed."

# Copy scripts
echo "Installing scripts..."
mkdir -p "$CLAUDE_DIR/scripts"
cp "$SCRIPT_DIR"/scripts/*.sh "$CLAUDE_DIR/scripts/"
chmod +x "$CLAUDE_DIR/scripts/"*.sh
echo "  Scripts installed."

# Copy bootstrap templates
echo "Installing bootstrap templates..."
mkdir -p "$CLAUDE_DIR/bootstrap-templates"
cp -r "$SCRIPT_DIR"/bootstrap-templates/* "$CLAUDE_DIR/bootstrap-templates/"
echo "  $(ls -d "$SCRIPT_DIR"/bootstrap-templates/*/ | wc -l | tr -d ' ') templates installed."

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
echo "  Command:   $CLAUDE_DIR/commands/setup.md"
echo "  Scripts:   $CLAUDE_DIR/scripts/"
echo "  Templates: $CLAUDE_DIR/bootstrap-templates/ ($(ls -d "$CLAUDE_DIR/bootstrap-templates/"*/ 2>/dev/null | wc -l | tr -d ' ') templates)"
echo ""
echo "Usage: Open Claude Code and type /setup to bootstrap a new project."
echo ""
echo "Done!"
