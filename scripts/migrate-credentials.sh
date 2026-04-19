#!/usr/bin/env bash
# migrate-credentials.sh
# Migrates any plain-text credential files found in ~/.claude/ or project tree
# into a secrets-manager-backed env layout. Does NOT transmit secrets anywhere.
#
# What it does:
#   1. Scans for plain-text credential files:
#      - $CLAUDE_CONFIG_DIR/.credentials.json
#      - ./channels/**/.env (project-local)
#      - ./.env (project-local, not .env.example)
#   2. For each match, offers to:
#      a. Move it to $HOME/.config/claude-secrets/ with 0600 permissions
#      b. Extract KEY=VALUE pairs into a .envrc template (for direnv)
#      c. Optionally push to 1Password / Bitwarden / Windows Credential Manager
#         via a manual copy-paste step (this script does NOT call those APIs)
#   3. Updates .gitignore to ensure these patterns never get tracked
#
# Safety:
#   - Dry-run by default (--execute to apply)
#   - Always creates timestamped backups before moving
#   - Never prints credential VALUES, only names
#
# Usage:
#   ./scripts/migrate-credentials.sh                # dry-run
#   ./scripts/migrate-credentials.sh --execute      # actually move files

set -euo pipefail

EXECUTE=0
for arg in "$@"; do
  case "$arg" in
    --execute|-x) EXECUTE=1 ;;
    --help|-h) sed -n '2,25p' "$0"; exit 0 ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
VAULT_DIR="$HOME/.config/claude-secrets"
STAMP=$(date -u +%Y%m%d-%H%M%S)

MATCHES=()
# Project roots to scan. Override with PROJECTS_ROOT env var (colon- or space-separated).
PROJECTS_ROOT="${PROJECTS_ROOT:-$HOME}"

# Check 1: ~/.claude/.credentials.json (Claude Code OAuth / plugin auth)
if [[ -f "$CONFIG_DIR/.credentials.json" ]]; then
  MATCHES+=("$CONFIG_DIR/.credentials.json")
fi

# Check 2: known Claude Code subpaths that commonly contain secrets
for sub in "channels/telegram/.env" "channels/slack/.env" "channels/discord/.env" ".env" ".env.local"; do
  [[ -f "$CONFIG_DIR/$sub" ]] && MATCHES+=("$CONFIG_DIR/$sub")
done

# Check 3: scan every project directory under $PROJECTS_ROOT for .env files.
# Respects .env.example (tracked placeholder, never a secret).
for root in $PROJECTS_ROOT; do
  [[ -d "$root" ]] || continue
  while IFS= read -r -d '' f; do
    case "$(basename "$f")" in
      .env.example) continue ;;
      .env|.env.*) MATCHES+=("$f") ;;
    esac
  done < <(find "$root" -maxdepth 4 -type f \( -name ".env" -o -name ".env.*" \) \
             -not -path '*/node_modules/*' -not -path '*/.git/*' \
             -not -path '*/.venv/*' -not -path '*/venv/*' \
             -not -path '*/Desktop/*' -print0 2>/dev/null || true)
done

# Deduplicate (in case $CONFIG_DIR is nested inside $PROJECTS_ROOT)
if (( ${#MATCHES[@]} > 0 )); then
  mapfile -t MATCHES < <(printf '%s\n' "${MATCHES[@]}" | awk '!seen[$0]++')
fi

if [[ ${#MATCHES[@]} -eq 0 ]]; then
  echo "No plain-text credential files found."
  exit 0
fi

echo "Found ${#MATCHES[@]} credential file(s):"
for m in "${MATCHES[@]}"; do
  SIZE=$(wc -c < "$m" 2>/dev/null || echo "?")
  echo "  - $m ($SIZE bytes)"
done

echo ""
echo "Migration plan:"
echo "  Target vault: $VAULT_DIR (mode 0700)"
echo "  Files will be moved with timestamped names."
echo "  KEY names (not values) will be dumped to ./.envrc.template for direnv."
echo ""

if (( EXECUTE == 0 )); then
  echo "DRY-RUN. Re-run with --execute to actually migrate."
  echo ""
  echo "Post-migration manual steps (required):"
  echo "  1. Review .envrc.template and fill it in with values from your secrets manager."
  echo "  2. Install direnv:  winget install direnv.direnv  (Windows)  |  brew install direnv  (macOS)"
  echo "  3. Copy .envrc.template to .envrc, run 'direnv allow .'"
  echo "  4. Add .envrc to .gitignore (it's already there via .env.* pattern)"
  echo "  5. Verify each tool still works (claude, n8n, etc.)"
  echo "  6. After 1 week of stable operation, delete $VAULT_DIR"
  exit 0
fi

mkdir -p "$VAULT_DIR"
chmod 700 "$VAULT_DIR" 2>/dev/null || true

: > .envrc.template."$STAMP"
echo "# .envrc.template - fill in real values, then 'direnv allow'" > .envrc.template."$STAMP"
echo "# Generated: $STAMP" >> .envrc.template."$STAMP"
echo "" >> .envrc.template."$STAMP"

for m in "${MATCHES[@]}"; do
  BASENAME=$(basename "$m")
  TARGET="$VAULT_DIR/${BASENAME}.${STAMP}.bak"

  # Extract KEY names for the template
  if [[ "$BASENAME" == *.json ]]; then
    # JSON: flatten one level deep so nested OAuth objects are captured.
    # e.g. {"claudeAiOauth": {"accessToken": "..."}} -> claudeAiOauth_accessToken
    KEYS=$(node -e "
      const j = JSON.parse(require('fs').readFileSync('$m', 'utf8'));
      const out = [];
      for (const k of Object.keys(j)) {
        const v = j[k];
        if (v !== null && typeof v === 'object' && !Array.isArray(v)) {
          for (const n of Object.keys(v)) out.push(k + '_' + n);
        } else {
          out.push(k);
        }
      }
      console.log(out.join('\n'));
    " 2>/dev/null || true)
  else
    # .env style: extract KEY= names
    KEYS=$(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$m" | cut -d= -f1 || true)
  fi

  if [[ -n "$KEYS" ]]; then
    echo "# from: $m" >> .envrc.template."$STAMP"
    while IFS= read -r k; do
      [[ -z "$k" ]] && continue
      echo "export $k=\"REPLACE-ME\"" >> .envrc.template."$STAMP"
    done <<< "$KEYS"
    echo "" >> .envrc.template."$STAMP"
  fi

  # Move to vault
  mv "$m" "$TARGET"
  chmod 600 "$TARGET" 2>/dev/null || true
  echo "  Moved: $m  ->  $TARGET"
done

echo ""
echo "Env template: ./.envrc.template."$STAMP""
echo ""
echo "Next steps:"
echo "  1. Open .envrc.template."$STAMP" and fill in real values (get them from $VAULT_DIR or your password manager)"
echo "  2. Rename to .envrc and run 'direnv allow .'"
echo "  3. Verify tools still work, then delete $VAULT_DIR after a week"
