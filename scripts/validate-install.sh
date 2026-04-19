#!/usr/bin/env bash
# validate-install.sh — "doctor" health check for claude-code-setup installations.
# Flags: --json (machine-readable), --verbose
# Exit: 0 if no FAIL, 1 if any FAIL found.

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"

# ---------------------------------------------------------------------------
# Flag parsing
# ---------------------------------------------------------------------------
JSON_OUT=false
VERBOSE=false

for arg in "$@"; do
  case "$arg" in
    --json)    JSON_OUT=true ;;
    --verbose) VERBOSE=true ;;
    --help|-h)
      echo "Usage: validate-install.sh [--json] [--verbose]"
      echo "  --json     Output results as a JSON array"
      echo "  --verbose  Print extra detail for each check"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg  (use --help)" >&2
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Result accumulator
# ---------------------------------------------------------------------------
declare -a RESULTS=()   # "name|status|hint" tuples
HAS_FAIL=false

record() {
  local name="$1" status="$2" hint="$3"
  RESULTS+=("${name}|${status}|${hint}")
  [[ "$status" == "FAIL" ]] && HAS_FAIL=true
  if [[ "$VERBOSE" == true ]] && [[ "$JSON_OUT" == false ]]; then
    echo "  [$status] $name — $hint"
  fi
}

# ---------------------------------------------------------------------------
# Check 1: manifest present
# ---------------------------------------------------------------------------
INSTALLED_VERSION="(not installed)"
if [[ -f "$CLAUDE_DIR/.installed-from.json" ]]; then
  if command -v node &>/dev/null; then
    INSTALLED_VERSION="$(node -e "try{const m=require('$CLAUDE_DIR/.installed-from.json');process.stdout.write(m.version||'?')}catch(e){process.stdout.write('?')}" 2>/dev/null || echo "?")"
  fi
  record "manifest" "OK" "version $INSTALLED_VERSION"
else
  record "manifest" "WARN" ".installed-from.json missing — run install.sh to create it"
fi

# ---------------------------------------------------------------------------
# Check 2: 18 rule files present
# ---------------------------------------------------------------------------
RULE_COUNT=0
if [[ -d "$CLAUDE_DIR/rules" ]]; then
  RULE_COUNT="$(ls "$CLAUDE_DIR/rules/"*.md 2>/dev/null | wc -l | tr -d ' ')"
fi
if (( RULE_COUNT == 18 )); then
  record "rules_count" "OK" "$RULE_COUNT/18 rule files present"
elif (( RULE_COUNT > 18 )); then
  record "rules_count" "WARN" "$RULE_COUNT rule files found (expected 18); extra files present"
else
  record "rules_count" "FAIL" "Only $RULE_COUNT/18 rule files present — re-run install.sh"
fi

# ---------------------------------------------------------------------------
# Check 3: setup.md entrypoint under 100 lines
# ---------------------------------------------------------------------------
SETUP_FILE="$CLAUDE_DIR/commands/setup.md"
if [[ -f "$SETUP_FILE" ]]; then
  LINE_COUNT="$(wc -l < "$SETUP_FILE" | tr -d ' ')"
  if (( LINE_COUNT <= 100 )); then
    record "setup_md_size" "OK" "setup.md is $LINE_COUNT lines"
  else
    record "setup_md_size" "WARN" "setup.md has $LINE_COUNT lines (expected ≤100); may have grown"
  fi
else
  record "setup_md_size" "FAIL" "commands/setup.md not found — re-run install.sh"
fi

# ---------------------------------------------------------------------------
# Check 4: setup-phases all present
# ---------------------------------------------------------------------------
PHASES_OK=true
MISSING_PHASES=""
for phase in 0 1 2; do
  pf="$CLAUDE_DIR/commands/setup-phases/phase-${phase}.md"
  if [[ ! -f "$pf" ]]; then
    PHASES_OK=false
    MISSING_PHASES="${MISSING_PHASES} phase-${phase}.md"
  fi
done
if [[ "$PHASES_OK" == true ]]; then
  record "setup_phases" "OK" "phase-0.md phase-1.md phase-2.md all present"
else
  record "setup_phases" "FAIL" "Missing:${MISSING_PHASES} — re-run install.sh"
fi

# ---------------------------------------------------------------------------
# Check 5: settings.json has "hooks" key
# ---------------------------------------------------------------------------
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
if [[ -f "$SETTINGS_FILE" ]]; then
  if grep -q '"hooks"' "$SETTINGS_FILE" 2>/dev/null; then
    record "hooks_merged" "OK" "settings.json contains a 'hooks' key"
  else
    record "hooks_merged" "WARN" "settings.json exists but has no 'hooks' key — see hooks/README.md"
  fi
else
  record "hooks_merged" "WARN" "settings.json not found — hooks may not be configured"
fi

# ---------------------------------------------------------------------------
# Check 6: plugin cache size warning (>5 GB)
# ---------------------------------------------------------------------------
CACHE_DIR="$CLAUDE_DIR/plugins/cache"
if [[ -d "$CACHE_DIR" ]]; then
  # du outputs in 512-byte blocks on some systems; use -sk for kibibytes
  CACHE_KB="$(du -sk "$CACHE_DIR" 2>/dev/null | cut -f1 || echo 0)"
  CACHE_GB_APPROX=$(( CACHE_KB / 1048576 ))
  if (( CACHE_KB > 5242880 )); then   # 5 GB in KB
    record "cache_size" "WARN" "Plugin cache is ~${CACHE_GB_APPROX}GB (>5GB) — consider running cleanup-plugin-cache.sh"
  else
    record "cache_size" "OK" "Plugin cache size is within limits"
  fi
else
  record "cache_size" "OK" "Plugin cache directory does not exist (nothing to warn about)"
fi

# ---------------------------------------------------------------------------
# Check 7: no .credentials.json in ~/.claude/ (security)
# ---------------------------------------------------------------------------
CRED_FILE="$CLAUDE_DIR/.credentials.json"
if [[ -f "$CRED_FILE" ]]; then
  record "no_credentials_json" "FAIL" ".credentials.json found in ~/.claude/ — remove or relocate it (security risk)"
else
  record "no_credentials_json" "OK" "No stray .credentials.json in ~/.claude/"
fi

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
if [[ "$JSON_OUT" == true ]]; then
  # Emit a JSON array
  echo "["
  total="${#RESULTS[@]}"
  for (( i=0; i<total; i++ )); do
    IFS='|' read -r name status hint <<< "${RESULTS[$i]}"
    comma=","
    (( i == total - 1 )) && comma=""
    printf '  {"name":"%s","status":"%s","hint":"%s"}%s\n' \
      "$name" "$status" "$hint" "$comma"
  done
  echo "]"
else
  echo "=== Claude Code Setup — Install Validation ==="
  echo ""
  for entry in "${RESULTS[@]}"; do
    IFS='|' read -r name status hint <<< "$entry"
    printf "  %-24s  %-4s  %s\n" "$name" "$status" "$hint"
  done
  echo ""
  if [[ "$HAS_FAIL" == true ]]; then
    echo "Result: FAIL — one or more checks failed. See hints above."
  else
    echo "Result: OK — all required checks passed."
  fi
fi

[[ "$HAS_FAIL" == true ]] && exit 1 || exit 0
