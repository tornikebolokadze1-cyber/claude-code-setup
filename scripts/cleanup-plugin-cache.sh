#!/usr/bin/env bash
# cleanup-plugin-cache.sh
# Removes stale `temp_git_*` directories from ~/.claude/plugins/cache/
# These are leftover clones from failed or interrupted plugin installs.
#
# Safe to run: only deletes dirs whose name matches the `temp_git_<digits>_<alnum>` pattern.
# Does NOT touch actual installed plugins.
#
# Usage:
#   ./scripts/cleanup-plugin-cache.sh              # dry-run (default)
#   ./scripts/cleanup-plugin-cache.sh --execute    # actually delete
#
# Respects $CLAUDE_CONFIG_DIR (falls back to ~/.claude).

set -euo pipefail

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CACHE_DIR="$CONFIG_DIR/plugins/cache"
EXECUTE=0

for arg in "$@"; do
  case "$arg" in
    --execute|-x) EXECUTE=1 ;;
    --help|-h)
      sed -n '2,15p' "$0"
      exit 0
      ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

if [[ ! -d "$CACHE_DIR" ]]; then
  echo "Cache dir not found: $CACHE_DIR"
  exit 0
fi

cd "$CACHE_DIR"

# Strict pattern: temp_git_<digits>_<alnum>
mapfile -t TARGETS < <(find . -maxdepth 1 -type d -regextype posix-extended \
  -regex './temp_git_[0-9]+_[A-Za-z0-9]+' -printf '%f\n' 2>/dev/null || true)

COUNT=${#TARGETS[@]}
if (( COUNT == 0 )); then
  echo "No stale temp_git_* directories found. Clean already."
  exit 0
fi

echo "Found $COUNT stale temp_git_* directories in $CACHE_DIR:"
for t in "${TARGETS[@]}"; do
  SIZE=$(du -sh "$t" 2>/dev/null | awk '{print $1}')
  printf "  %-45s  %s\n" "$t" "$SIZE"
done

if (( EXECUTE == 0 )); then
  echo ""
  echo "DRY-RUN. Re-run with --execute to actually delete."
  exit 0
fi

echo ""
for t in "${TARGETS[@]}"; do
  rm -rf -- "$t"
done
echo "Removed $COUNT directories."
