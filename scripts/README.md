# scripts/

Utility scripts for the claude-code-setup repo. All scripts target POSIX `sh` / `bash` and
must run in both Git Bash on Windows and on Linux/macOS CI.

---

## verify-local-sync.sh

**Purpose:** Byte-level drift detector between your local `~/.claude/` directory and this
repo. Catches exactly the class of drift that occurs when you update rules or templates
locally but forget to push them back to the repo.

**When to run:** Before every PR to main; after any local rule/template edit.

```bash
./scripts/verify-local-sync.sh [REPO_PATH [LOCAL_CLAUDE_DIR]] [--fix=push]
```

| Argument | Default | Description |
|---|---|---|
| `REPO_PATH` | `.` | Path to the git repo root |
| `LOCAL_CLAUDE_DIR` | `$HOME/.claude` | Path to your local `~/.claude/` directory |
| `--fix=push` | off | Print dry-run `cp` commands to sync local → repo (no files are copied) |

**Exit codes:**
- `0` — clean, no drift
- `1` — drift detected (`MISSING_IN_REPO`, `MISSING_IN_LOCAL`, or `CONTENT_DIFFER`)

**Output categories:**
- `MISSING_IN_REPO` — file exists locally but not in the repo
- `MISSING_IN_LOCAL` — file exists in the repo but not locally
- `CONTENT_DIFFER` — file exists in both but hashes differ (CRLF-normalised)

**Example:**
```bash
# Check from repo root (default paths)
./scripts/verify-local-sync.sh

# Explicit paths
./scripts/verify-local-sync.sh /path/to/repo /home/me/.claude

# Dry-run fix list
./scripts/verify-local-sync.sh . ~/.claude --fix=push
```

---

## cleanup-backups.sh

**Purpose:** Removes timestamped backup directories that `install.sh` creates under
`~/.claude/backup-YYYYMMDD-HHMMSS/` when it detects an existing config.

```bash
~/.claude/scripts/cleanup-backups.sh [--older-than DAYS]
```

| Argument | Default | Description |
|---|---|---|
| `--older-than DAYS` | `7` | Only delete backups older than this many days |

Always asks for confirmation before deleting. Never auto-deletes.

---

## session-metrics.sh

**Purpose:** Prints a summary of Claude Code session activity from the Claude Code log
files (if present). Useful for understanding token usage patterns across sessions.

```bash
~/.claude/scripts/session-metrics.sh
```

No arguments. Read-only — does not modify any files.

---

## Adding a new script

1. Place it in `scripts/` with a `.sh` extension.
2. Use `#!/usr/bin/env bash` shebang.
3. Test with `shellcheck scripts/your-script.sh` before committing.
4. Add a section to this README describing purpose, arguments, and an example.
5. Update `install.sh` to copy it to `~/.claude/scripts/` and `chmod +x` it.
