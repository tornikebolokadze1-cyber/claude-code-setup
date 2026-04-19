#!/usr/bin/env bash
# verify-local-sync.sh
# Byte-level drift detector between a local ~/.claude/ directory and this repo.
# Normalises CRLF -> LF before hashing so Windows checkouts don't produce false positives.
#
# Usage:
#   ./scripts/verify-local-sync.sh [REPO_PATH [LOCAL_CLAUDE_DIR]] [--fix=push]
#
# Arguments:
#   REPO_PATH        Path to the git repo root           (default: .)
#   LOCAL_CLAUDE_DIR Path to the local ~/.claude/ dir    (default: $HOME/.claude)
#   --fix=push       Print a dry-run list of cp commands that would bring the repo
#                    in sync with local (no actual copying is performed)
#
# Exit codes:
#   0  -- clean, no drift detected
#   1  -- drift detected (MISSING_IN_REPO, MISSING_IN_LOCAL, or CONTENT_DIFFER)

set -euo pipefail

# ── Argument parsing ─────────────────────────────────────────────────────────
REPO_PATH="."
LOCAL_DIR="${HOME}/.claude"
FIX_MODE=""

for arg in "$@"; do
  case "$arg" in
    --fix=push) FIX_MODE="push" ;;
    --*)        echo "Unknown flag: $arg" >&2; exit 2 ;;
    *)
      if [ "$REPO_PATH" = "." ]; then
        REPO_PATH="$arg"
      elif [ "$LOCAL_DIR" = "${HOME}/.claude" ]; then
        LOCAL_DIR="$arg"
      fi
      ;;
  esac
done

REPO_PATH="$(cd "$REPO_PATH" && pwd)"
LOCAL_DIR="${LOCAL_DIR%/}"

# ── Scope: which paths to compare ────────────────────────────────────────────
COMPARE_PATHS=(
  "commands"
  "rules"
  "hooks"
  "scripts"
  "archive"
  "templates"
  "install.sh"
  "README.md"
  "LICENSE"
  "CHANGELOG.md"
  "SECURITY.md"
)

# ── Patterns to skip ─────────────────────────────────────────────────────────
SKIP_PATTERNS=(
  "node_modules"
  "__pycache__"
  ".pytest_cache"
  ".venv"
  "*.egg-info"
  "dist"
  "build"
  ".next"
  "*.backup-*"
  "*.pyc"
  "*.log"
  ".DS_Store"
  "package-lock.json"
)

# ── Hash a single file with CRLF normalisation ────────────────────────────────
hash_file() {
  tr -d '\r' < "$1" | sha256sum | awk '{print $1}'
}

# ── Check whether a relative path should be skipped ──────────────────────────
should_skip() {
  local rel="$1"
  for pat in "${SKIP_PATTERNS[@]}"; do
    case "$rel" in
      *"$pat"*) return 0 ;;
    esac
  done
  return 1
}

# ── Collect all leaf files under a directory ─────────────────────────────────
collect_files() {
  local base="$1"
  local rel_root="$2"
  local full="$base/$rel_root"

  [ -e "$full" ] || return 0

  if [ -f "$full" ]; then
    echo "$rel_root"
    return 0
  fi

  find "$full" -type f 2>/dev/null | sed "s|^$full/||" | while IFS= read -r f; do
    local rel="$rel_root/$f"
    should_skip "$rel" && continue
    echo "$rel"
  done
}

# ── Main comparison logic ─────────────────────────────────────────────────────
MISSING_IN_REPO=()
MISSING_IN_LOCAL=()
CONTENT_DIFFER=()
FIX_COMMANDS=()

for path in "${COMPARE_PATHS[@]}"; do
  repo_full="$REPO_PATH/$path"
  local_full="$LOCAL_DIR/$path"

  repo_exists=false
  local_exists=false
  [ -e "$repo_full" ]  && repo_exists=true
  [ -e "$local_full" ] && local_exists=true

  if [ "$repo_exists" = false ] && [ "$local_exists" = false ]; then
    continue
  fi

  if [ "$repo_exists" = false ] && [ "$local_exists" = true ]; then
    MISSING_IN_REPO+=("$path")
    if [ "$FIX_MODE" = "push" ]; then
      FIX_COMMANDS+=("cp -r \"$local_full\" \"$repo_full\"")
    fi
    continue
  fi

  if [ "$repo_exists" = true ] && [ "$local_exists" = false ]; then
    MISSING_IN_LOCAL+=("$path")
    continue
  fi

  # Both exist — file-by-file comparison
  while IFS= read -r rel; do
    [ -z "$rel" ] && continue
    should_skip "$rel" && continue
    repo_file="$REPO_PATH/$rel"
    local_file="$LOCAL_DIR/$rel"

    if [ ! -f "$local_file" ]; then
      MISSING_IN_LOCAL+=("$rel")
      continue
    fi

    repo_hash=$(hash_file "$repo_file")
    local_hash=$(hash_file "$local_file")

    if [ "$repo_hash" != "$local_hash" ]; then
      CONTENT_DIFFER+=("$rel")
      if [ "$FIX_MODE" = "push" ]; then
        dir=$(dirname "$repo_file")
        FIX_COMMANDS+=("mkdir -p \"$dir\" && cp \"$local_file\" \"$repo_file\"")
      fi
    fi
  done < <(collect_files "$REPO_PATH" "$path")

  while IFS= read -r rel; do
    [ -z "$rel" ] && continue
    should_skip "$rel" && continue
    repo_file="$REPO_PATH/$rel"
    if [ ! -e "$repo_file" ]; then
      MISSING_IN_REPO+=("$rel")
      if [ "$FIX_MODE" = "push" ]; then
        local_file="$LOCAL_DIR/$rel"
        dir=$(dirname "$repo_file")
        FIX_COMMANDS+=("mkdir -p \"$dir\" && cp \"$local_file\" \"$repo_file\"")
      fi
    fi
  done < <(collect_files "$LOCAL_DIR" "$path")
done

# ── Report ────────────────────────────────────────────────────────────────────
echo ""
echo "=== verify-local-sync.sh ==="
echo "  Repo : $REPO_PATH"
echo "  Local: $LOCAL_DIR"
echo ""

TOTAL_DRIFT=0

echo "MISSING_IN_REPO  (${#MISSING_IN_REPO[@]} files)"
for f in "${MISSING_IN_REPO[@]}"; do
  echo "  - $f"
  TOTAL_DRIFT=$((TOTAL_DRIFT + 1))
done

echo ""
echo "MISSING_IN_LOCAL (${#MISSING_IN_LOCAL[@]} files)"
for f in "${MISSING_IN_LOCAL[@]}"; do
  echo "  - $f"
  TOTAL_DRIFT=$((TOTAL_DRIFT + 1))
done

echo ""
echo "CONTENT_DIFFER   (${#CONTENT_DIFFER[@]} files)"
for f in "${CONTENT_DIFFER[@]}"; do
  echo "  - $f"
  TOTAL_DRIFT=$((TOTAL_DRIFT + 1))
done

echo ""
if [ "$TOTAL_DRIFT" -eq 0 ]; then
  echo "Result: CLEAN -- repo and local are in sync."
else
  echo "Result: DRIFT DETECTED -- $TOTAL_DRIFT file(s) differ."
fi

if [ "$FIX_MODE" = "push" ] && [ "${#FIX_COMMANDS[@]}" -gt 0 ]; then
  echo ""
  echo "=== --fix=push dry-run (no files were copied) ==="
  echo "Run the following commands to copy local -> repo:"
  echo ""
  for cmd in "${FIX_COMMANDS[@]}"; do
    echo "  $cmd"
  done
fi

echo ""

if [ "$TOTAL_DRIFT" -gt 0 ]; then
  exit 1
fi

exit 0
