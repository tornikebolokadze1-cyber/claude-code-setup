# Hooks Reference

This directory contains Claude Code hook configurations that run automatically on every Claude Code action.

## Hook Index

| Event | Matcher | Purpose | Platform |
|-------|---------|---------|----------|
| `PreToolUse` | `Bash\|Write\|Edit` | Audit logger — appends tool name + timestamp to `~/.claude/audit-logs/audit-YYYY-MM-DD.log` | POSIX / bash-only |
| `PreToolUse` | `Bash` | Auto-tmux dev server — when Claude runs `npm run dev` (or pnpm/yarn/bun equivalent), starts the server in a detached tmux session instead of blocking the terminal | bash-only + **requires tmux** |
| `PreToolUse` | `Bash` | Destructive command blocker — scans the command for dangerous patterns (`git push --force`, `git reset --hard`, `DROP TABLE`, `rm -rf /`, etc.) and blocks with exit code 2; logs to `~/.claude/audit-logs/governance-YYYY-MM-DD.log` | POSIX / bash-only |
| `PostToolUse` | `Edit\|Write` | Auto-format — runs Prettier (JS/TS/JSON/CSS/HTML), Black (Python), or gofmt (Go) on the saved file | bash-only; **requires** Prettier / Black / gofmt on PATH |
| `PostToolUse` | `Edit\|Write` | Auto-lint — runs ESLint (JS/TS) or Pylint (Python) on the saved file | bash-only; **requires** ESLint / Pylint on PATH |
| `PostToolUse` | `Edit\|Write` | Secret detection — scans the file for hardcoded secrets (passwords, API keys, tokens); blocks with exit 1 if found | POSIX / bash-only; uses `grep -E` |
| `PostToolUse` | `Edit\|Write` | Sensitive file guard — blocks writes to `.env`, `.pem`, `.key`, `.p12`, `.pfx`, `.jks`, SSH identity files | POSIX / bash-only |
| `PostToolUse` | `Edit\|Write` | Auto-backup — copies the file to `~/.claude/file-backups/YYYY-MM-DD/` before it is overwritten | POSIX / bash-only |
| `PostToolUse` | `Edit\|Write` | Console.log detector — warns if `console.log`/`console.warn`/`console.error` appears in non-test JS/TS files | bash-only (`[[` syntax) |
| `PostToolUse` | `Edit\|Write` | TypeScript checker — walks up the directory tree to find `tsconfig.json`, then runs `tsc --noEmit` and surfaces errors for the edited file | bash-only (`[[` syntax); **requires** TypeScript on PATH |
| `Stop` | _(any)_ | Session metrics — appends a JSON line with timestamp, session ID (md5sum-based), and cwd to `~/.claude/metrics/sessions-YYYY-MM.jsonl` | bash-only; **requires** `md5sum` |

---

## Platform Compatibility

| Tool / construct | Used by | Linux/macOS (bash) | Git Bash (Windows) | WSL (Windows) | PowerShell / cmd |
|---|---|---|---|---|---|
| `grep -E` | Audit, secret detection, sensitive guard, console detector | Yes | Yes | Yes | No — use `Select-String` |
| `[[ ... ]]` | Auto-format, auto-lint, console detector, TS checker | Yes | Yes | Yes | No — use `if (...)` |
| `md5sum` | Auto-tmux (session name sanitize), session metrics | Yes | Yes | Yes | No — use `Get-FileHash` |
| `tmux` | Auto-tmux dev server | Yes (if installed) | No | Yes (if installed) | No |
| `date '+%Y-%m-%d %H:%M:%S'` | Audit, backup | Yes | Yes | Yes | No — use `Get-Date -Format` |
| `$HOME` | Audit, backup, metrics | Yes | Yes | Yes | Use `$env:USERPROFILE` |
| `seq 1 15` | TS checker (loop) | Yes | Yes | Yes | No — use `for` loop |
| Prettier (`npx prettier`) | Auto-format | Yes | Yes | Yes | Yes (cross-platform) |
| Black (`black`) | Auto-format | Yes | Yes | Yes | Yes (cross-platform) |
| gofmt | Auto-format | Yes | Yes | Yes | Yes (cross-platform) |
| ESLint (`npx eslint`) | Auto-lint | Yes | Yes | Yes | Yes (cross-platform) |
| Pylint (`pylint`) | Auto-lint | Yes | Yes | Yes | Yes (cross-platform) |
| `npx tsc` | TS checker | Yes | Yes | Yes | Yes (cross-platform) |

**Summary:** Every hook uses bash-specific constructs. None of them work in a native PowerShell or cmd session. The formatters/linters (Prettier, Black, ESLint, etc.) are cross-platform — only the shell wrapper around them is bash-only.

---

## Installation

### Unix / macOS / Linux

The hooks must be merged into `~/.claude/settings.json`. Two methods:

#### Method 1 — jq (recommended)

```bash
# Merge hooks from this repo into your existing ~/.claude/settings.json
jq -s '
  .[0] as $existing |
  .[1] as $new |
  $existing * { "hooks": (
    ($existing.hooks // {}) as $eh |
    ($new.hooks // {}) as $nh |
    {
      "PreToolUse":  (($eh.PreToolUse  // []) + ($nh.PreToolUse  // [])),
      "PostToolUse": (($eh.PostToolUse // []) + ($nh.PostToolUse // [])),
      "Stop":        (($eh.Stop        // []) + ($nh.Stop        // []))
    }
  )}
' ~/.claude/settings.json hooks/settings-hooks.json > /tmp/merged-settings.json \
  && mv /tmp/merged-settings.json ~/.claude/settings.json
```

If `~/.claude/settings.json` does not exist yet:

```bash
cp hooks/settings-hooks.json ~/.claude/settings.json
```

#### Method 2 — Node.js script (no jq required)

Save this as `merge-hooks.js` and run `node merge-hooks.js` from the repo root:

```js
const fs = require('fs');
const path = require('path');

const settingsPath = path.join(process.env.HOME, '.claude', 'settings.json');
const hooksPath = path.join(__dirname, 'hooks', 'settings-hooks.json');

let existing = {};
if (fs.existsSync(settingsPath)) {
  existing = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
}
const newHooks = JSON.parse(fs.readFileSync(hooksPath, 'utf8'));

existing.hooks = existing.hooks || {};
newHooks.hooks = newHooks.hooks || {};

for (const event of ['PreToolUse', 'PostToolUse', 'Stop']) {
  existing.hooks[event] = [
    ...(existing.hooks[event] || []),
    ...(newHooks.hooks[event] || []),
  ];
}

fs.mkdirSync(path.dirname(settingsPath), { recursive: true });
fs.writeFileSync(settingsPath, JSON.stringify(existing, null, 2));
console.log('Hooks merged into', settingsPath);
```

---

### Windows

#### Option 1 — Recommended: Run Claude Code under Git Bash or WSL

All hooks work unchanged under Git Bash or WSL because they use bash.

**Git Bash:** Open "Git Bash" (installed with Git for Windows) and run Claude Code from there:

```bash
claude
```

Merge hooks the same way as Unix (Method 1 or Method 2 above).

**WSL:** Open your WSL terminal and run Claude Code from there:

```bash
claude
```

#### Option 2 — PowerShell-adapted hooks

Use `hooks/settings-hooks.windows.json` instead of `hooks/settings-hooks.json`. This variant replaces every bash-specific construct with a PowerShell equivalent. Each hook command is wrapped in `pwsh -NoLogo -NoProfile -Command "..."`.

Merge the Windows hooks into `~/.claude/settings.json` (or `$env:USERPROFILE\.claude\settings.json`) using the Node.js script above, substituting the path:

```powershell
# In PowerShell — adapt the Node.js merge script paths
$settingsPath = "$env:USERPROFILE\.claude\settings.json"
$hooksPath = "hooks\settings-hooks.windows.json"
node merge-hooks.js  # (after editing the paths inside the script)
```

Or copy directly if you have no existing hooks:

```powershell
Copy-Item hooks\settings-hooks.windows.json "$env:USERPROFILE\.claude\settings.json"
```

---

## Troubleshooting

### `tmux: command not found`

The auto-tmux hook silently falls through (`exit 0`) when tmux is not found — the dev server command runs normally and blocks the terminal.

**Fix on Linux/macOS:** Install tmux:
```bash
# macOS
brew install tmux

# Debian/Ubuntu
sudo apt install tmux
```

**Fix on Windows:** Either use WSL (tmux works there) or use the Windows hooks variant, which replaces tmux with `Start-Process`:

```powershell
# Windows equivalent used in settings-hooks.windows.json:
Start-Process -NoNewWindow powershell -ArgumentList '-Command', 'npm run dev'
```

---

### `md5sum: command not found` (macOS or Windows native)

Used by the session metrics hook to generate a short session ID.

**macOS fix:** Use `md5` instead (already handled in the hook with a fallback to `echo unknown`).

**Windows fix:** The Windows hooks variant replaces `md5sum` with `Get-FileHash`:
```powershell
(Get-FileHash -Algorithm MD5 -InputStream ([IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($env:RANDOM)))).Hash.Substring(0,8)
```

---

### `grep -E` not found / not working

`grep -E` is a POSIX utility not available in PowerShell or cmd.

**Windows native PowerShell equivalent:**
```powershell
# Instead of: grep -qE 'pattern' file && ...
if (Select-String -Pattern 'pattern' -Path 'file' -Quiet) { ... }

# Instead of: grep -niE 'pattern' file
Select-String -Pattern 'pattern' -Path 'file' | Select-Object -First 5
```

---

### `bash [[` syntax error

`[[ ... ]]` is a bash extension not available in sh, dash, PowerShell, or cmd.

**PowerShell equivalent:**
```powershell
# Instead of: if [[ "$FILE" == *.ts ]]; then ...
if ($env:CLAUDE_TOOL_FILE_PATH -like '*.ts') { ... }
```

---

### Prettier / ESLint / Black not running

These tools are cross-platform but must be on your PATH. Common causes:

- Not installed: run `npm install -g prettier eslint` or `pip install black pylint`
- Installed locally (in `node_modules/.bin`) but not globally: use `npx prettier` (already in the hook) or `npx eslint`
- Python virtualenv not activated: activate your venv before starting Claude Code

All hook commands end with `2>/dev/null || true` so a missing formatter will not block Claude — it silently skips.
