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
- `install.sh` hardened: `set -euo pipefail`, new flags `--dry-run` / `--check` / `--version` / `--force` / `--help`, writes `.installed-from.json` manifest, UTC-timestamped versioned backup dirs, explicit 0755/0644 file modes, now also copies `commands/setup-phases/`
- `.github/dependabot.yml` adds `groups:` to batch updates per ecosystem, `commit-message.prefix: "deps"`, and consistent labels (reduces PR noise ~80%)

### Added (round 2)
- `VERSION` file at repo root (0.2.0)
- `DESIGN.md` — product archetype, scope, design principles, tension log
- `CLAUDE.md` at repo root — contributor context for when this repo is opened in Claude Code
- `uninstall.sh` — manifest-driven reversal with `--dry-run`/`--list`/`--purge` flags; moves files to timestamped dir (never deletes outright)
- `scripts/validate-install.sh` — "doctor" health check with 7 checks, `--json` and `--verbose` modes
- `scripts/install-lib.sh` — shared helpers sourced by `install.sh`
- `.github/workflows/smoke-test.yml` — Docker-based end-to-end install + idempotency + hook-merge + template safety + rule-limit + phase-split CI
- `docs/GOVERNANCE.md` — maintainer model, semver cadence, branch policy, signed commits, deprecation process
- `docs/RELEASE.md` — step-by-step release checklist with VERSION/CHANGELOG sync sanity check
- `docs/branch-protection.md` + `docs/branch-protection.json` — UI + API setup for main-branch protection
- `.gitignore` files for all 7 bootstrap templates (previously 3 were missing: `express-backend`, `hybrid-code-n8n`, `n8n-workflow`, `telegram-bot`)

### Fixed
- README hook count (was `7 automated hooks`, now `11`)
- `install.sh` previously skipped `commands/setup-phases/` — now copies recursively

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
