# Contributing

Thank you for helping improve this Claude Code setup template!

## Getting Started

```bash
# 1. Fork and clone
git clone https://github.com/tornikebolokadze1-cyber/claude-code-setup.git
cd claude-code-setup

# 2. Create a feature branch
git checkout -b feat/your-feature-name

# 3. Test locally against a throwaway config dir
CLAUDE_CONFIG_DIR=~/.claude.test ./install.sh
```

> The `CLAUDE_CONFIG_DIR` override keeps your real `~/.claude/` untouched during testing.  
> Inspect `~/.claude.test/` to verify rules, hooks, and templates were installed correctly.

## Adding a New Rule File

1. Place it in `rules/` with a numbered, kebab-case filename: `NN-kebab-case.md`  
   (e.g., `17-api-design.md`). Numbers keep files in a logical reading order.
2. Start the file with a single top-level heading: `# Title`
3. Keep it **under 400 lines** — split into multiple files if needed.
4. Include a brief rationale at the top explaining *why* this rule exists and what downstream harm it prevents.
5. Update the rule count in `README.md`.

## Adding a Hook

1. Edit `hooks/settings-hooks.json`.
2. Ensure the hook command works on **all supported platforms** (Linux, macOS, Windows/Git Bash) or document explicitly which platforms it targets.
3. Avoid commands that require elevated privileges or modify files outside the project directory.
4. Add a row to the hooks table in `README.md` describing what the hook does.
5. Validate JSON: `jq -e . hooks/settings-hooks.json` (or `node -e "JSON.parse(require('fs').readFileSync('hooks/settings-hooks.json'))"`)

## Adding a Bootstrap Template

1. Create a new subdirectory under `bootstrap-templates/your-template-name/`.
2. Each template must be **self-contained**:
   - `CLAUDE.md` — project-specific Claude instructions
   - `.gitignore` — appropriate for the stack
   - `README.md` — 3-step quickstart (clone → install deps → run)
   - `.env.example` — all required env vars with placeholder values
3. Update the template count and table in the root `README.md`.
4. Smoke-test: scaffold a fresh project from the template and confirm it starts without errors.

## Commit Convention

This repo uses [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>: <short description>

[optional body]
```

| Type       | When to use                                  |
| ---------- | -------------------------------------------- |
| `feat`     | New rule, hook, template, or command         |
| `fix`      | Correcting a broken rule/hook/template       |
| `docs`     | README, CONTRIBUTING, CHANGELOG updates      |
| `chore`    | CI, repo config, non-functional changes      |
| `refactor` | Restructuring without behaviour change       |
| `test`     | Adding or updating tests / smoke scripts     |
| `ci`       | GitHub Actions workflow changes              |

Examples:
- `feat: add 18-security-headers rule`
- `fix: correct hook count in README`
- `docs: add CONTRIBUTING.md`

## Pull Request Checklist

Before opening a PR, confirm:

- [ ] README counts are updated if rules / hooks / templates were added or removed
- [ ] `hooks/settings-hooks.json` is valid JSON (`jq -e .` or `node -e "JSON.parse(...)"`)
- [ ] New rule files are under 400 lines
- [ ] New hooks are tested on at least one OS (note which in the PR description)
- [ ] New bootstrap templates include `CLAUDE.md`, `.gitignore`, `README.md`, `.env.example`
- [ ] Templates smoke-tested (fresh scaffold runs without errors)
- [ ] No secrets committed (API keys, tokens, passwords)
- [ ] `install.sh` remains idempotent (run twice, no errors or duplicate entries)
- [ ] Markdown renders correctly (check GitHub preview)

## Code of Conduct

Be respectful and constructive. All contributors are expected to follow basic open-source norms — critique ideas, not people.
