# CLAUDE.md — Contributor Context

*Loaded when a contributor opens this repo in Claude Code. Not a consumer config —
consumer configs live in `bootstrap-templates/`.*

---

## What This Repo Is

A **Claude Code baseline template**. It ships rules, hooks, commands, and bootstrap
project scaffolds that Claude Code reads during a session. There is no runtime, no
server, and no application to run. The deliverable is a set of text files plus an
installer (`install.sh`) that places them into `~/.claude/`.

**This is not an app. Do not treat it like one.**

---

## Quick Orientation

| Path | Contents | Count |
|------|----------|-------|
| `rules/` | Markdown rule files loaded as Claude context | 18 files |
| `hooks/settings-hooks.json` | Pre/post-tool hooks (Linux/macOS) | 11 hooks |
| `hooks/settings-hooks.windows.json` | PowerShell equivalents for Windows | mirrors above |
| `commands/setup.md` | Thin `/setup` command entrypoint | <100 lines |
| `commands/setup-phases/` | Phase bodies: `phase-0.md`, `phase-1.md`, `phase-2.md` | ~1800 lines total |
| `bootstrap-templates/` | Project scaffolds: ai-agent, express-backend, fastapi-backend, hybrid-code-n8n, n8n-workflow, nextjs-webapp, telegram-bot | 7 templates |
| `scripts/` | Operator utilities: `cleanup-backups.sh`, `session-metrics.sh`, others | 5 scripts |
| `install.sh` | Idempotent bash installer → copies everything to `~/.claude/` | root |

---

## Build and Syntax Checks (run locally before pushing)

```bash
# Syntax-check the installer and all shell scripts
bash -n install.sh && bash -n scripts/*.sh

# Lint hooks JSON
node -e 'JSON.parse(require("fs").readFileSync("hooks/settings-hooks.json"))'

# Verify rule count
ls rules | wc -l
# Expected: 18

# Verify setup.md entrypoint stays thin
wc -l commands/setup.md
# Expected: < 100

# Simulate CI locally (requires `act`)
act pull_request
```

CI runs automatically on push. Check `.github/workflows/` for the full suite.

---

## Adding a New Rule

1. Create `rules/NN-kebab-case.md` (numbered prefix keeps logical reading order).
2. Start with a single top-level heading: `# Title`.
3. Add a brief rationale at the top — *why this rule exists and what harm it prevents*.
4. Keep it **under 400 lines** — split into multiple files if needed.
5. Update the rule count in `README.md` and `CLAUDE.md` (the count in the table above).
6. CI enforces the 400-line limit; `ls rules | wc -l` must still equal 18 (adjust if adding).

---

## Adding a New Hook

1. Edit `hooks/settings-hooks.json` (Linux/macOS) and mirror in `hooks/settings-hooks.windows.json` (PowerShell).
2. Document in `hooks/README.md`; update hook count in `README.md` and `CHANGELOG.md`.
3. Validate JSON: `node -e 'JSON.parse(require("fs").readFileSync("hooks/settings-hooks.json"))'`

---

## Adding a New Bootstrap Template

1. Create `bootstrap-templates/your-template-name/` with: `CLAUDE.md`, `.gitignore` (CI enforces this), `README.md` (3-step quickstart), `.env.example` (placeholders only).
2. Update the template list in `README.md` and `CHANGELOG.md`.

---

## Editing the `/setup` Command

- `commands/setup.md` is the **entrypoint only** — keep it under 100 lines.
- All detailed phase logic lives in `commands/setup-phases/phase-{0,1,2}.md`.
- The three phase files must total ≥ 1500 lines (CI enforces this).
- Do not collapse phases back into `setup.md`; the split keeps context lean.

---

## Commit Convention

Conventional Commits — `type: description`:

| Type | When |
|------|------|
| `feat` | New rule, hook, template, or command |
| `fix` | Broken rule, hook, or template corrected |
| `docs` | README, CONTRIBUTING, CHANGELOG, DESIGN updates |
| `chore` | CI, repo config, non-functional housekeeping |
| `refactor` | Restructuring without behaviour change |
| `test` | Smoke scripts, CI workflow additions |
| `ci` | GitHub Actions workflow changes |

---

## Hard Limits

- **No secrets** — `.env` files are in `.gitignore`; only `.env.example` (with placeholders) is tracked.
- **No binary artifacts** — everything is plain text.
- **No force-pushes to `main`.**
- **No direct commits to `main`** — use a branch + PR.
- `--no-verify` is forbidden; fix the hook failure instead.

---

## When in Doubt

Push to a PR branch and let CI tell you. The smoke-test workflow catches the most common problems: wrong rule count, oversized rule files, missing `.gitignore` in templates, and broken `install.sh`.
