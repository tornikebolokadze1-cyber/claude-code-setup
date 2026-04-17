#!/usr/bin/env bash
# install-lib.sh — shared helpers for install.sh
# Source this file; do not execute directly.

# Populates SRC_FILES[] and DST_FILES[] arrays.
# Requires: SCRIPT_DIR, CLAUDE_DIR to be set by caller.
collect_files() {
  local src rel
  declare -g -a SRC_FILES=()
  declare -g -a DST_FILES=()

  # rules/*.md
  for src in "$SCRIPT_DIR"/rules/*.md; do
    [[ -f "$src" ]] || continue
    SRC_FILES+=("$src")
    DST_FILES+=("$CLAUDE_DIR/rules/$(basename "$src")")
  done

  # commands/setup.md
  SRC_FILES+=("$SCRIPT_DIR/commands/setup.md")
  DST_FILES+=("$CLAUDE_DIR/commands/setup.md")

  # commands/setup-phases/*.md
  for src in "$SCRIPT_DIR"/commands/setup-phases/*.md; do
    [[ -f "$src" ]] || continue
    SRC_FILES+=("$src")
    DST_FILES+=("$CLAUDE_DIR/commands/setup-phases/$(basename "$src")")
  done

  # scripts/*.sh and *.mjs
  for src in "$SCRIPT_DIR"/scripts/*.sh "$SCRIPT_DIR"/scripts/*.mjs; do
    [[ -f "$src" ]] || continue
    SRC_FILES+=("$src")
    DST_FILES+=("$CLAUDE_DIR/scripts/$(basename "$src")")
  done

  # bootstrap-templates (recursive)
  while IFS= read -r -d '' src; do
    rel="${src#"$SCRIPT_DIR/bootstrap-templates/"}"
    SRC_FILES+=("$src")
    DST_FILES+=("$CLAUDE_DIR/bootstrap-templates/$rel")
  done < <(find "$SCRIPT_DIR/bootstrap-templates" -type f -print0 2>/dev/null)
}

# Write the install manifest to MANIFEST_FILE.
# Requires: VERSION, GIT_HASH, SCRIPT_DIR, MANIFEST_FILE, SRC_FILES[], DST_FILES[]
write_manifest() {
  local timestamp list_json i rel
  timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  list_json=""
  for i in "${!DST_FILES[@]}"; do
    rel="${DST_FILES[$i]#"$HOME/"}"
    list_json="${list_json}\"${rel}\","
  done
  list_json="${list_json%,}"

  node -e "
const fs = require('fs');
const manifest = {
  version: '${VERSION}',
  git_commit: '${GIT_HASH}',
  installed_at: '${timestamp}',
  source_path: '${SCRIPT_DIR}',
  files: [${list_json}]
};
fs.writeFileSync('${MANIFEST_FILE}', JSON.stringify(manifest, null, 2) + '\n');
"
  chmod 0644 "$MANIFEST_FILE"
}
