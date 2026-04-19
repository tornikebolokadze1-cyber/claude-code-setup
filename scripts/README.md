# scripts/

Utility scripts for the claude-code-setup repo. All scripts target POSIX `sh` / `bash` and
must run in both Git Bash on Windows and on Linux/macOS CI.

---

## Scripts Index

| Script | Purpose | Safe to run unattended |
|--------|---------|----------------------|
| `verify-local-sync.sh` | Byte-level drift detector between repo and `~/.claude/` | Yes |
| `install-lib.sh` | Shared helper functions sourced by `install.sh` | N/A (sourced, not executed directly) |
| `migrate-credentials.sh` | PII-safety tool — move plain-text credentials to secret store | No — interactive |
| `patch-settings-2026.mjs` | Migrate `settings.json` to April 2026 schema | No — backs up, then modifies |
| `validate-install.sh` | Post-install sanity checks (files exist, hooks present, security check) | Yes |
| `cleanup-plugin-cache.sh` | Trim stale `~/.claude/plugins/cache/temp_git_*` directories | Yes (dry-run default) |
| `cleanup-backups.sh` | Remove old `~/.claude/backup-YYYYMMDD-HHMMSS/` beyond retention | Yes (asks confirmation) |
| `session-metrics.sh` | Roll up `~/.claude/metrics/sessions-*.jsonl` into monthly summary | Yes |

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

**Exit codes:** `0` — clean | `1` — drift detected

**Output categories:**
- `MISSING_IN_REPO` — file exists locally but not in the repo
- `MISSING_IN_LOCAL` — file exists in the repo but not locally
- `CONTENT_DIFFER` — file exists in both but hashes differ (CRLF-normalised)

**Example:**
```bash
./scripts/verify-local-sync.sh                     # default paths
./scripts/verify-local-sync.sh . ~/.claude --fix=push  # dry-run fix
```

---

## install-lib.sh

**Purpose:** Shared helper functions sourced by `install.sh`. Not meant to be executed directly.

**Functions:** `collect_files` (populates `SRC_FILES[]` + `DST_FILES[]` arrays), `write_manifest` (writes `.installed-from.json`).

**Environment variables required when sourced:**
| Variable | Purpose |
|----------|---------|
| `SCRIPT_DIR` | Absolute path to the repo root |
| `CLAUDE_DIR` | Absolute path to the install target (`$HOME/.claude`) |
| `VERSION` | Semver string written into the manifest |
| `GIT_HASH` | Git commit hash written into the manifest |
| `MANIFEST_FILE` | Full path for the manifest JSON |

---

## migrate-credentials.sh

**Purpose:** PII-safety utility. Scans `~/.claude/` and the current project tree for plain-text
credential files and migrates them to `~/.config/claude-secrets/` with 0600 permissions.
Generates an `.envrc.template` showing key names (never values).

**Dry-run by default** — pass `--execute` to actually move files.

```bash
./scripts/migrate-credentials.sh              # dry-run
./scripts/migrate-credentials.sh --execute    # moves files
```

**Environment variables:**
| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CONFIG_DIR` | `~/.claude` | Path to Claude Code config dir |
| `PROJECTS_ROOT` | `$HOME` | Roots to scan (space-separated) |

Never transmits data anywhere. Never prints credential values.

---

## patch-settings-2026.mjs

**Purpose:** Migrates `~/.claude/settings.json` to the April 2026 schema. Adds:
1. `enabledMcpServers` for MCP lazy-loading (~95% context reduction)
2. New hook events: `ConfigChange`, `PostCompact`, `SessionEnd`

Always creates a timestamped backup first.

```bash
node scripts/patch-settings-2026.mjs              # dry-run
node scripts/patch-settings-2026.mjs --execute    # apply
```

**Environment variables:**
| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CONFIG_DIR` | `~/.claude` | Override config directory |

Idempotent — safe to re-run.

---

## validate-install.sh

**Purpose:** Post-install sanity checker. Verifies required files, rule counts, settings.json hooks key, and security (no stray `.credentials.json`).

```bash
./scripts/validate-install.sh              # human-readable
./scripts/validate-install.sh --json       # machine-readable JSON array
./scripts/validate-install.sh --verbose    # per-check detail
```

**Checks:** manifest, rules_count (18), setup_md_size (<=100 lines), setup_phases, hooks_merged, cache_size (<5GB), no_credentials_json

**Exit codes:** `0` — all required checks passed | `1` — any FAIL

---

## cleanup-plugin-cache.sh

**Purpose:** Removes stale `temp_git_<digits>_<alnum>` directories from `~/.claude/plugins/cache/`.
Safe: only touches directories matching the exact pattern.

```bash
./scripts/cleanup-plugin-cache.sh              # dry-run
./scripts/cleanup-plugin-cache.sh --execute    # delete
```

**Environment variables:**
| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CONFIG_DIR` | `~/.claude` | Override config directory |

---

## cleanup-backups.sh

**Purpose:** Removes timestamped backup directories that `install.sh` creates under
`~/.claude/backup-YYYYMMDD-HHMMSS/`.

```bash
~/.claude/scripts/cleanup-backups.sh [--older-than DAYS]
```

Always asks for confirmation before deleting.

---

## session-metrics.sh

**Purpose:** Prints a summary of Claude Code session activity from `~/.claude/metrics/sessions-*.jsonl`.
Read-only — does not modify any files.

```bash
~/.claude/scripts/session-metrics.sh
```

---

## Adding a new script

1. Place it in `scripts/` with a `.sh` or `.mjs` extension.
2. Use `#!/usr/bin/env bash` or `#!/usr/bin/env node` shebang.
3. Test syntax: `bash -n scripts/your-script.sh`
4. Add a section to this README: purpose, arguments, env vars, side effects, idempotency.
5. Add a row to the Scripts Index table.
6. Update `install.sh` to copy it and `chmod +x` it.
