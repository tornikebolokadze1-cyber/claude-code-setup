#!/bin/bash
# Claude Code Setup Installer — v0.4.0
# Copies rules, commands, hooks, archived templates, and scripts to ~/.claude/
# New in v0.4: templates moved to archive/; /setup-AI-Pulse-Georgia now delegates
# to community scaffolders (create-next-app, cookiecutter, etc.) and layers
# Claude Code conventions on top instead of copying monolithic archetypes.

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude Code Setup Installer (v0.4.0) ==="
echo ""

# Ensure ~/.claude exists
if [ ! -d "$CLAUDE_DIR" ]; then
  echo "Creating $CLAUDE_DIR..."
  mkdir -p "$CLAUDE_DIR"
fi

# Backup existing files (rules/commands/scripts) if non-empty
BACKUP_DIR="$CLAUDE_DIR/backup-$(date '+%Y%m%d-%H%M%S')"
NEEDS_BACKUP=false

for dir in rules commands scripts; do
  if [ -d "$CLAUDE_DIR/$dir" ] && [ -n "$(ls -A "$CLAUDE_DIR/$dir" 2>/dev/null || true)" ]; then
    NEEDS_BACKUP=true
    break
  fi
done

if [ "$NEEDS_BACKUP" = true ]; then
  echo "Backing up existing config to $BACKUP_DIR..."
  mkdir -p "$BACKUP_DIR"
  for dir in rules commands scripts; do
    if [ -d "$CLAUDE_DIR/$dir" ]; then
      cp -r "$CLAUDE_DIR/$dir" "$BACKUP_DIR/" 2>/dev/null || true
    fi
  done
  echo "  Backup saved."
fi

# Helper: count files matching a glob, handling paths with spaces correctly.
# Uses find so spaces in $HOME ("AI Pulse Georgia") do not break the count.
count_glob() {
  local pattern="$1"
  local dir="${pattern%/*}"
  local name="${pattern##*/}"
  local maxdepth=1
  # If pattern ends in /, caller wants a directory count
  if [ "${pattern: -1}" = "/" ]; then
    dir="${pattern%/}"
    dir="${dir%/*}"
    find "$dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' '
    return
  fi
  find "$dir" -maxdepth "$maxdepth" -name "$name" -type f 2>/dev/null | wc -l | tr -d ' '
}

# Copy rules
echo "Installing rules..."
mkdir -p "$CLAUDE_DIR/rules"
cp "$SCRIPT_DIR"/rules/*.md "$CLAUDE_DIR/rules/"
RULE_COUNT=$(count_glob "$SCRIPT_DIR/rules/*.md")
echo "  $RULE_COUNT rule files installed."

# Copy commands
echo "Installing /setup-AI-Pulse-Georgia command and phase files..."
mkdir -p "$CLAUDE_DIR/commands/setup-phases"
cp "$SCRIPT_DIR"/commands/setup-AI-Pulse-Georgia.md "$CLAUDE_DIR/commands/"
cp "$SCRIPT_DIR"/commands/setup-phases/*.md "$CLAUDE_DIR/commands/setup-phases/"
if [ -f "$SCRIPT_DIR/commands/setup.md" ]; then
  cp "$SCRIPT_DIR/commands/setup.md" "$CLAUDE_DIR/commands/"
fi
echo "  /setup-AI-Pulse-Georgia command installed (+ phase files + deprecation alias)."

# Copy scripts (shell + Node.js utilities)
echo "Installing scripts..."
mkdir -p "$CLAUDE_DIR/scripts"
cp "$SCRIPT_DIR"/scripts/*.sh "$CLAUDE_DIR/scripts/"
for mjs in "$SCRIPT_DIR"/scripts/*.mjs; do
  if [ -f "$mjs" ]; then
    cp "$mjs" "$CLAUDE_DIR/scripts/"
  fi
done
chmod +x "$CLAUDE_DIR/scripts/"*.sh
SH_COUNT=$(count_glob "$SCRIPT_DIR/scripts/*.sh")
MJS_COUNT=$(count_glob "$SCRIPT_DIR/scripts/*.mjs")
echo "  Scripts installed ($SH_COUNT shell + $MJS_COUNT Node.js files)."
echo "  verify-local-sync.sh    -> $CLAUDE_DIR/scripts/verify-local-sync.sh"
echo "  validate-install.sh     -> $CLAUDE_DIR/scripts/validate-install.sh"
echo "  patch-settings-2026.mjs -> $CLAUDE_DIR/scripts/patch-settings-2026.mjs"

# Copy hooks (settings-hooks.json, .windows.json, reference/ gallery)
if [ -d "$SCRIPT_DIR/hooks" ]; then
  echo "Installing hooks..."
  mkdir -p "$CLAUDE_DIR/hooks/reference"
  if [ -f "$SCRIPT_DIR/hooks/settings-hooks.json" ]; then
    cp "$SCRIPT_DIR/hooks/settings-hooks.json" "$CLAUDE_DIR/hooks/"
  fi
  if [ -f "$SCRIPT_DIR/hooks/settings-hooks.windows.json" ]; then
    cp "$SCRIPT_DIR/hooks/settings-hooks.windows.json" "$CLAUDE_DIR/hooks/"
  fi
  if [ -f "$SCRIPT_DIR/hooks/README.md" ]; then
    cp "$SCRIPT_DIR/hooks/README.md" "$CLAUDE_DIR/hooks/"
  fi
  if [ -d "$SCRIPT_DIR/hooks/reference" ]; then
    cp "$SCRIPT_DIR/hooks/reference/"*.json "$CLAUDE_DIR/hooks/reference/" 2>/dev/null || true
  fi
  HOOKS_COUNT=$(count_glob "$SCRIPT_DIR/hooks/reference/*.json")
  echo "  Hooks installed (baseline + $HOOKS_COUNT reference hooks)."
  echo "  NOTE: hooks are NOT auto-wired into settings.json. See hooks/README.md for activation."
fi

# Copy templates (CLAUDE.md.example + settings.local.json.example)
if [ -d "$SCRIPT_DIR/templates" ]; then
  echo "Installing templates..."
  mkdir -p "$CLAUDE_DIR/templates"
  cp "$SCRIPT_DIR/templates/"* "$CLAUDE_DIR/templates/" 2>/dev/null || true
  TEMPLATES_DOCS_COUNT=$(count_glob "$SCRIPT_DIR/templates/*")
  echo "  Templates installed ($TEMPLATES_DOCS_COUNT reference files)."
fi

# Copy archived bootstrap templates (deprecated — kept for backward compat &
# for stacks without mature community scaffolders, e.g. n8n-workflow)
if [ -d "$SCRIPT_DIR/archive/bootstrap-templates" ]; then
  echo "Installing archived bootstrap templates..."
  mkdir -p "$CLAUDE_DIR/archive/bootstrap-templates"
  cp -r "$SCRIPT_DIR"/archive/bootstrap-templates/* "$CLAUDE_DIR/archive/bootstrap-templates/"
  TEMPLATE_COUNT=$(count_glob "$SCRIPT_DIR/archive/bootstrap-templates/*/")
  echo "  $TEMPLATE_COUNT archived templates installed under archive/."
  echo "  NOTE: templates are DEPRECATED as of v0.4. /setup-AI-Pulse-Georgia now"
  echo "  delegates to community scaffolders (create-next-app, cookiecutter, etc.)"
  echo "  and layers Claude Code conventions on top. Archived templates remain"
  echo "  available as a fallback for stacks without mature community scaffolders."
elif [ -d "$SCRIPT_DIR/bootstrap-templates" ]; then
  # Pre-v0.4 layout — copy from legacy location with deprecation warning
  echo "Installing bootstrap templates (legacy v0.3 layout detected)..."
  mkdir -p "$CLAUDE_DIR/bootstrap-templates"
  cp -r "$SCRIPT_DIR"/bootstrap-templates/* "$CLAUDE_DIR/bootstrap-templates/"
  TEMPLATE_COUNT=$(count_glob "$SCRIPT_DIR/bootstrap-templates/*/")
  echo "  $TEMPLATE_COUNT templates installed (legacy layout)."
fi

# Hooks notice — post-install reminder
echo ""
echo "=== Hooks Configuration ==="
echo "Baseline hooks are at: $CLAUDE_DIR/hooks/settings-hooks.json"
echo "Reference gallery:     $CLAUDE_DIR/hooks/reference/ (20 opt-in hooks)"
echo ""
echo "Hooks are NOT auto-wired. To activate baseline hooks, merge the JSON"
echo "into $CLAUDE_DIR/settings.json manually. See $CLAUDE_DIR/hooks/README.md"
echo "for the exact jq one-liner."
echo ""

# Summary
INSTALLED_RULES=$(count_glob "$CLAUDE_DIR/rules/*.md")
INSTALLED_SCRIPTS=$(count_glob "$CLAUDE_DIR/scripts/*.sh")
INSTALLED_TEMPLATES=0
if [ -d "$CLAUDE_DIR/archive/bootstrap-templates" ]; then
  INSTALLED_TEMPLATES=$(count_glob "$CLAUDE_DIR/archive/bootstrap-templates/*/")
fi

echo "=== Installation Complete ==="
echo ""
echo "Installed:"
echo "  Rules:     $CLAUDE_DIR/rules/ ($INSTALLED_RULES files)"
echo "  Command:   $CLAUDE_DIR/commands/setup-AI-Pulse-Georgia.md (+ setup-phases/)"
echo "  Scripts:   $CLAUDE_DIR/scripts/ ($INSTALLED_SCRIPTS files)"
echo "  Archive:   $CLAUDE_DIR/archive/bootstrap-templates/ ($INSTALLED_TEMPLATES archived templates)"
echo ""
echo "Usage:"
echo "  Primary:    /setup-AI-Pulse-Georgia  — bootstrap any new or existing project"
echo "  Deprecated: /setup                   — alias, kept for muscle-memory"
echo ""
echo "Sync verification:"
echo "  Run '$CLAUDE_DIR/scripts/verify-local-sync.sh' any time to check"
echo "  that your local ~/.claude/ is in sync with the repo."
echo ""
echo "Done!"
