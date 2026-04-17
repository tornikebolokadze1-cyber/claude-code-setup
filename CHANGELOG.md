# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `LICENSE` (MIT)
- `SECURITY.md` — vulnerability reporting policy and threat model
- `CONTRIBUTING.md` — local testing guide, conventions, and PR checklist
- `CHANGELOG.md` — this file
- `.env.example` — placeholder env vars for consuming projects
- `.github/CODEOWNERS` — review ownership for all major directories
- `.github/dependabot.yml` — automated dependency updates for GitHub Actions and npm/pip templates
- `.github/PULL_REQUEST_TEMPLATE.md` — structured PR checklist
- `.github/ISSUE_TEMPLATE/config.yml` — disables blank issues, links to SECURITY.md
- `.github/ISSUE_TEMPLATE/bug_report.yml` — structured bug report form
- `.github/ISSUE_TEMPLATE/feature_request.yml` — structured feature request form
- `.github/workflows/validate.yml` — JSON validation and install smoke-test CI
- `.github/workflows/gitleaks.yml` — secret scanning on every push and PR
- `.github/workflows/claude-review.yml` — automated Claude Code review on PRs
- `.markdownlint.jsonc` — markdown lint rules for CI
- `.gitleaks.toml` — allowlist for placeholders and example env files
- `hooks/README.md` — hook reference with cross-platform compatibility notes
- `hooks/settings-hooks.windows.json` — PowerShell variant of the hook config
- `commands/setup-phases/phase-0.md`, `phase-1.md`, `phase-2.md` — split of the monolithic `/setup` command
- `scripts/cleanup-plugin-cache.sh` — remove stale `temp_git_*` clones from `~/.claude/plugins/cache/`
- `scripts/patch-settings-2026.mjs` — apply MCP lazy-loading and 2026 hook events (`ConfigChange`, `PostCompact`, `SessionEnd`) to `~/.claude/settings.json`
- `scripts/migrate-credentials.sh` — move plain-text credentials into a user-only vault with a direnv template

### Changed
- `commands/setup.md` reduced from ~1875 lines to a 34-line entrypoint that delegates to `commands/setup-phases/phase-*.md`
- `.gitignore` now unignores `.env.example` so the new template file is tracked
- README adds a "Windows Support" section documenting Git Bash/WSL vs PowerShell hook variants

### Fixed
- README hook count (was `7 automated hooks`, now `11`)

## [0.1.0] - 2026-03-22

### Added
- Initial release of the claude-code-setup template
- 18 rule markdown files covering security, TypeScript, Python, Go, testing, and workflow standards
- 11 hooks in `hooks/settings-hooks.json` (auto-format, auto-lint, secret detection, and more)
- `/setup` slash command (`commands/setup.md`) for one-shot project scaffolding
- 7 bootstrap templates: `ai-agent`, `express-backend`, `fastapi-backend`, `hybrid-code-n8n`, `n8n-workflow`, `nextjs-webapp`, `telegram-bot`
- `install.sh` for idempotent installation into `~/.claude/`
- `scripts/` with cleanup and metrics utilities
- `README.md` with full feature overview and quick-start guide

[Unreleased]: https://github.com/tornikebolokadze1-cyber/claude-code-setup/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/tornikebolokadze1-cyber/claude-code-setup/releases/tag/v0.1.0
