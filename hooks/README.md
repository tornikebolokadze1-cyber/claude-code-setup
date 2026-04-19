# Hooks

Claude Code hooks are shell commands that run automatically on specific lifecycle events.
This directory contains:

1. **`settings-hooks.json`** — the "wired" baseline (13 hooks, ready to merge into `~/.claude/settings.json`)
2. **`settings-hooks.windows.json`** — same hooks rewritten for PowerShell / Git Bash on Windows
3. **`reference/`** — a gallery of 20 additional hook definitions; opt-in, not auto-activated

---

## Quick Start

Merge the baseline hooks into your settings:

```bash
# Requires jq
jq -s '.[0] as $e | .[1] as $n | $e * { "hooks": (($e.hooks // {}) as $eh | ($n.hooks // {}) as $nh | {"PreToolUse": (($eh.PreToolUse // []) + ($nh.PreToolUse // [])), "PostToolUse": (($eh.PostToolUse // []) + ($nh.PostToolUse // [])), "Stop": (($eh.Stop // []) + ($nh.Stop // []))})}' ~/.claude/settings.json hooks/settings-hooks.json > /tmp/merged.json && mv /tmp/merged.json ~/.claude/settings.json
```

**Windows (Git Bash / WSL):** Use `hooks/settings-hooks.windows.json` instead.

---

## Baseline hooks

13 hooks wired and ready for immediate use:

| # | Event | Matcher | Purpose | Platform |
|---|-------|---------|---------|---------|
| 1 | `PreToolUse` | `Bash|Write|Edit` | **Audit logger** | POSIX |
| 2 | `PreToolUse` | `Bash` | **Auto-tmux dev server** | POSIX + tmux |
| 3 | `PreToolUse` | `Bash` | **Destructive command blocker** | POSIX |
| 4 | `PostToolUse` | `Edit|Write` | **Auto-format** (Prettier/Black/gofmt) | POSIX |
| 5 | `PostToolUse` | `Edit|Write` | **Auto-lint** (ESLint/Pylint) | POSIX |
| 6 | `PostToolUse` | `Edit|Write` | **Secret detection** | POSIX |
| 7 | `PostToolUse` | `Edit|Write` | **Sensitive file guard** | POSIX |
| 8 | `PostToolUse` | `Edit|Write` | **Auto-backup** | POSIX |
| 9 | `PostToolUse` | `Edit|Write` | **console.log detector** | POSIX |
| 10 | `PostToolUse` | `Edit|Write` | **TypeScript checker** | POSIX; needs tsc |
| 11 | `Stop` | _(any)_ | **Session metrics** | POSIX |

---

## Reference gallery (`reference/`)

20 additional hook definitions. **None are auto-activated at install time.**

To activate: copy the `hooks` block from any `reference/*.json` file into your `~/.claude/settings.json`.

### Full index

| Hook file | Event | Matcher | Purpose | Notes |
|-----------|-------|---------|---------|-------|
| `backup-before-edit.json` | PreToolUse | Edit | Timestamped .backup copy before every edit | No deps |
| `change-tracker.json` | PostToolUse | Edit|MultiEdit|Write | Appends to ~/.claude/changes.log | No deps |
| `console-log-cleaner.json` | PreToolUse | Edit | Warns about console.* on production branches | bash [[  |
| `conventional-commits.json` | PreToolUse | Bash | Validates commit message format | Needs conventional-commits.py |
| `dangerous-command-blocker.json` | PreToolUse | Bash | Blocks catastrophic + critical path commands | Needs dangerous-command-blocker.py |
| `desktop-notification-on-stop.json` | Stop | any | Native desktop notification on finish | Auto-detects OS |
| `file-protection.json` | PreToolUse | Edit|MultiEdit|Write | Blocks /etc/, /usr/, *.production.*, node_modules/ | No deps |
| `format-python-files.json` | PostToolUse | Edit | Runs black on .py files | Needs black |
| `lint-on-save.json` | PostToolUse | Edit|MultiEdit | ESLint/Pylint/RuboCop auto-fix | Needs linters |
| `plan-gate.json` | PreToolUse | Edit|MultiEdit|Write | Warns when no .spec.md found (non-blocking) | Needs plan-gate.sh |
| `scope-guard.json` | Stop | any | Warns about out-of-scope file modifications | Needs scope-guard.sh |
| `secret-scanner.json` | PreToolUse | Bash | Scans for 30+ provider API keys before commits | Needs secret-scanner.py |
| `security-scanner.json` | PostToolUse | Edit|Write | semgrep + bandit + gitleaks + regex check | All tools optional |
| `simple-notifications.json` | PostToolUse | * | Desktop notification after every tool | Auto-detects OS |
| `smart-commit.json` | PostToolUse | Edit|Write | Auto-commits each edit with generated message | Commits every edit |
| `smart-formatting.json` | PostToolUse | Edit|MultiEdit | Prettier/Black/gofmt/rustfmt by extension | Needs formatters |
| `tdd-gate.json` | PreToolUse | Edit|MultiEdit|Write | Blocks edit if no test file exists | Needs tdd-gate.sh |
| `telegram-detailed-notifications.json` | SessionStart/Stop | any | Telegram session start/end with duration | Needs BOT_TOKEN + CHAT_ID |
| `telegram-notifications.json` | Stop/SubagentStop | any | Simple Telegram finish notification | Needs BOT_TOKEN + CHAT_ID |
| `test-runner.json` | PostToolUse | Edit | npm test / pytest / rspec after each edit | Only runs when config detected |

### Hooks requiring supporting files

| Hook | Supporting file |
|------|----------------|
| conventional-commits.json | .claude/hooks/conventional-commits.py |
| dangerous-command-blocker.json | .claude/hooks/dangerous-command-blocker.py |
| plan-gate.json | .claude/hooks/plan-gate.sh |
| scope-guard.json | .claude/hooks/scope-guard.sh |
| secret-scanner.json | .claude/hooks/secret-scanner.py |
| tdd-gate.json | .claude/hooks/tdd-gate.sh |

---

## Platform Compatibility

| Construct | Linux/macOS | Git Bash | WSL | PowerShell |
|-----------|-------------|----------|-----|-----------|
| bash `[[ ]]` | Yes | Yes | Yes | No |
| `grep -E` | Yes | Yes | Yes | No |
| `md5sum` | Yes | Yes | Yes | No |
| `tmux` | Yes (if installed) | No | Yes | No |
| Prettier/Black/ESLint | Yes | Yes | Yes | Yes |

Use Git Bash or WSL on Windows. See `settings-hooks.windows.json` for PowerShell equivalents.

---

## Troubleshooting

**`tmux: command not found`** — Hook falls through silently; install tmux or use WSL.

**Formatter/linter not running** — Install: `npm install -g prettier eslint` or `pip install black pylint`. All commands end with `|| true` so missing tools never block Claude.

**Hook not firing** — Verify matcher is case-sensitive (`Edit`, not `edit`).
