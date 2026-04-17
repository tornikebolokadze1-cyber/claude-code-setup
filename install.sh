#!/usr/bin/env bash
# Claude Code Setup Installer
# Copies rules, commands, hooks, templates, and scripts to ~/.claude/
# Flags: --dry-run | --check | --version | --force | --help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
VERSION_FILE="$SCRIPT_DIR/VERSION"
MANIFEST_FILE="$CLAUDE_DIR/.installed-from.json"

# Source shared helpers (collect_files, write_manifest)
# shellcheck source=scripts/install-lib.sh
source "$SCRIPT_DIR/scripts/install-lib.sh"

# Read installer version
if [[ ! -f "$VERSION_FILE" ]]; then
  echo "ERROR: VERSION file not found at $VERSION_FILE" >&2; exit 1
fi
VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"

# ---------------------------------------------------------------------------
# Flag parsing
# ---------------------------------------------------------------------------
DRY_RUN=false; CHECK=false; SHOW_VERSION=false; SHOW_HELP=false; FORCE=false

for arg in "$@"; do
  case "$arg" in
    --dry-run)  DRY_RUN=true ;;
    --check)    CHECK=true ;;
    --version)  SHOW_VERSION=true ;;
    --force)    FORCE=true ;;
    --help|-h)  SHOW_HELP=true ;;
    *) echo "Unknown option: $arg  (use --help)" >&2; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# --version / --help
# ---------------------------------------------------------------------------
if [[ "$SHOW_VERSION" == true ]]; then echo "$VERSION"; exit 0; fi

if [[ "$SHOW_HELP" == true ]]; then
  cat <<'EOF'
Usage: install.sh [OPTIONS]

Options:
  (none)       Install rules, commands, scripts, and bootstrap templates
  --dry-run    Print what WOULD be copied; do not write any files
  --check      Compare installed state to repo; exit 1 if different
  --version    Print installer version and exit
  --force      Overwrite even if current version is already installed
  --help       Show this help text and exit

The installer writes a manifest to ~/.claude/.installed-from.json so it can
detect re-installs and support uninstall.sh.
EOF
  exit 0
fi

# Populate file lists
collect_files

# ---------------------------------------------------------------------------
# --dry-run
# ---------------------------------------------------------------------------
if [[ "$DRY_RUN" == true ]]; then
  echo "=== Dry Run — nothing will be written ==="
  for i in "${!SRC_FILES[@]}"; do
    echo "  COPY  ${SRC_FILES[$i]}"
    echo "    →   ${DST_FILES[$i]}"
  done
  echo ""
  echo "Total: ${#SRC_FILES[@]} file(s) would be installed."
  exit 0
fi

# ---------------------------------------------------------------------------
# --check
# ---------------------------------------------------------------------------
if [[ "$CHECK" == true ]]; then
  missing=0; modified=0; identical=0
  for i in "${!SRC_FILES[@]}"; do
    dst="${DST_FILES[$i]}"; src="${SRC_FILES[$i]}"
    if [[ ! -f "$dst" ]]; then
      echo "  MISSING  $dst"; (( missing++ )) || true
    elif ! cmp -s "$src" "$dst"; then
      echo "  MODIFIED $dst"; (( modified++ )) || true
    else
      (( identical++ )) || true
    fi
  done
  echo ""
  echo "Summary: missing=$missing  modified=$modified  identical=$identical"
  (( missing > 0 || modified > 0 )) && exit 1 || exit 0
fi

# ---------------------------------------------------------------------------
# Default install
# ---------------------------------------------------------------------------
echo "=== Claude Code Setup Installer (v$VERSION) ==="
echo ""

# Already-installed guard
if [[ -f "$MANIFEST_FILE" ]] && [[ "$FORCE" == false ]]; then
  installed_ver=""
  if command -v node &>/dev/null; then
    installed_ver="$(node -e "try{const m=require('$MANIFEST_FILE');process.stdout.write(m.version||'')}catch(e){}" 2>/dev/null || true)"
  fi
  if [[ "$installed_ver" == "$VERSION" ]]; then
    echo "Already installed at current version ($VERSION); use --force to overwrite."
    exit 0
  fi
fi

# Require node for manifest
if ! command -v node &>/dev/null; then
  echo "ERROR: 'node' is required to write the install manifest. Install Node.js and retry." >&2
  exit 1
fi

# Ensure target dir
[[ -d "$CLAUDE_DIR" ]] || { echo "Creating $CLAUDE_DIR..."; mkdir -p "$CLAUDE_DIR"; }

# Backup existing files — timestamped + version
BACKUP_DIR="$HOME/.claude.backup-$(date -u '+%Y%m%dT%H%M%SZ')-v${VERSION}"
NEEDS_BACKUP=false
for dir in rules commands scripts; do
  if [[ -d "$CLAUDE_DIR/$dir" ]] && [[ -n "$(ls -A "$CLAUDE_DIR/$dir" 2>/dev/null)" ]]; then
    NEEDS_BACKUP=true; break
  fi
done
if [[ "$NEEDS_BACKUP" == true ]]; then
  echo "Backing up existing config to $BACKUP_DIR ..."
  mkdir -p "$BACKUP_DIR"
  [[ -d "$CLAUDE_DIR/rules" ]]    && cp -r "$CLAUDE_DIR/rules"    "$BACKUP_DIR/" 2>/dev/null || true
  [[ -d "$CLAUDE_DIR/commands" ]] && cp -r "$CLAUDE_DIR/commands" "$BACKUP_DIR/" 2>/dev/null || true
  [[ -d "$CLAUDE_DIR/scripts" ]]  && cp -r "$CLAUDE_DIR/scripts"  "$BACKUP_DIR/" 2>/dev/null || true
  echo "  Backup saved."
fi

# Copy rules
echo "Installing rules..."
mkdir -p "$CLAUDE_DIR/rules"
cp "$SCRIPT_DIR"/rules/*.md "$CLAUDE_DIR/rules/"
chmod 0644 "$CLAUDE_DIR"/rules/*.md
echo "  $(ls "$SCRIPT_DIR"/rules/*.md | wc -l | tr -d ' ') rule files installed."

# Copy commands
echo "Installing /setup command..."
mkdir -p "$CLAUDE_DIR/commands/setup-phases"
cp "$SCRIPT_DIR/commands/setup.md" "$CLAUDE_DIR/commands/"
chmod 0644 "$CLAUDE_DIR/commands/setup.md"
cp "$SCRIPT_DIR"/commands/setup-phases/*.md "$CLAUDE_DIR/commands/setup-phases/"
chmod 0644 "$CLAUDE_DIR"/commands/setup-phases/*.md
echo "  /setup command installed."

# Copy scripts
echo "Installing scripts..."
mkdir -p "$CLAUDE_DIR/scripts"
cp "$SCRIPT_DIR"/scripts/*.sh "$CLAUDE_DIR/scripts/"
chmod 0755 "$CLAUDE_DIR"/scripts/*.sh
for f in "$SCRIPT_DIR"/scripts/*.mjs; do
  [[ -f "$f" ]] && cp "$f" "$CLAUDE_DIR/scripts/" && chmod 0755 "$CLAUDE_DIR/scripts/$(basename "$f")"
done
echo "  Scripts installed."

# Copy bootstrap templates
echo "Installing bootstrap templates..."
mkdir -p "$CLAUDE_DIR/bootstrap-templates"
cp -r "$SCRIPT_DIR"/bootstrap-templates/. "$CLAUDE_DIR/bootstrap-templates/"
echo "  $(ls -d "$SCRIPT_DIR"/bootstrap-templates/*/ 2>/dev/null | wc -l | tr -d ' ') templates installed."

# Resolve git commit
GIT_HASH="unknown"
if command -v git &>/dev/null && git -C "$SCRIPT_DIR" rev-parse HEAD &>/dev/null 2>&1; then
  GIT_HASH="$(git -C "$SCRIPT_DIR" rev-parse HEAD)"
fi

# Write manifest
write_manifest

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
echo "  Manifest:  $MANIFEST_FILE"
echo ""
echo "Usage: Open Claude Code and type /setup to bootstrap a new project."
echo ""
echo "Done!"
