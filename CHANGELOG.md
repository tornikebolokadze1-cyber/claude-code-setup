# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-04-20

### Changed — breaking

- **`bootstrap-templates/` moved to `archive/bootstrap-templates/`.** The 9 template directories are now explicitly archived. They are frozen at their v0.3.0 state and will not receive dependency updates or feature additions.
- **`/setup-AI-Pulse-Georgia` delegates to community scaffolders** instead of copying monolithic templates. `phase-2.md` §2.7.3 now routes Next.js to `npx create-next-app@latest`, Vite to `npm create vite@latest`, FastAPI to `cookiecutter gh:arthurhenrique/cookiecutter-fastapi`, Cloudflare Worker to `npm create cloudflare@latest`, and falls back to archived templates for stacks without mature community scaffolders (AI agent, Telegram bot, n8n workflow, hybrid code+n8n).
- **`install.sh` now copies the archive to `~/.claude/archive/bootstrap-templates/`** (with a deprecation notice) instead of `~/.claude/bootstrap-templates/`. Backward-compat: if the legacy `bootstrap-templates/` path is still present at install time, it is still copied to preserve existing muscle memory.
- **Dependabot no longer watches `archive/**`.** Open Dependabot PRs against `bootstrap-templates/*` at the time of release are expected to auto-close once the templates move paths; any that remain can be closed manually.
- **CI hardening:** `install.sh` rewritten to satisfy `shellcheck` without `-e` failures (eliminates SC2015 and SC2012 patterns that caused every push to `main` to show a red CI since v0.3.0 shipped).

### Added

- `archive/README.md` — migration guide explaining why templates were archived and the community-scaffolder alternatives per stack.
- `templates/CLAUDE.md.example` — reference template (under 80 lines) showing the Anthropic April 2026 CLAUDE.md convention. `/setup-AI-Pulse-Georgia` can point users at this instead of generating ad-hoc CLAUDE.md files.
- Updated `phase-2.md` §2.7.3 with a **delegation matrix** — one row per stack showing the canonical scaffolder command, execution rules, and the fallback to archived templates if upstream breaks.

### Fixed

- `install.sh` — SC2015 (`cmd && cmd || true` ambiguity, 3 occurrences) replaced with explicit `if` blocks.
- `install.sh` — SC2012 (`ls | wc -l`, 7 occurrences) replaced with glob-array-length helper `count_glob()`.
- `README.md` — version badge now reads `0.4.0` (was stuck at `0.2.x` after v0.3 shipped).
- `README.md` — `~/.claude/` tree diagram now reflects the archive layout.

### Migration (for users of v0.3.x)

If you installed v0.3.x via `./install.sh`:

1. Re-run `./install.sh` — archived templates land at `~/.claude/archive/bootstrap-templates/`; the old `~/.claude/bootstrap-templates/` path is left untouched (delete it yourself if you want; nothing reads from it anymore).
2. Your `/setup-AI-Pulse-Georgia` command now invokes community scaffolders. First run on a Next.js project will trigger `npx --yes create-next-app@latest`; you'll see Claude asking once before it runs.
3. No config file you wrote is affected. Rules, hooks, scripts, and phase files are unchanged in behavior — only the scaffolding step in Phase 2 changed.
4. If you have active Dependabot PRs on `bootstrap-templates/*` in your fork, expect them to close automatically; if any linger, close them manually.

### Rationale

Templates are archetypes, not live code. Dependabot accumulated 20+ open PRs on `bootstrap-templates/*` between v0.3.0 (2026-04-19) and the v0.4 planning window (2026-04-20) because the weekly cadence couldn't be reconciled with the reality that template consumers copy once and then evolve independently. At the same time, Anthropic's April 2026 guidance and the top 5 community Claude Code repos all converged on the same pattern: **delegate scaffolding to upstream, layer Claude Code conventions on top**. v0.4 adopts that pattern; v0.5 is expected to add skills/agents/MCP defaults that Phase B of the roadmap requires (separate release).

---

## [0.3.0] - 2026-04-19

### Added
- 5 per-template CLAUDE.md files restored in repo: ai-agent, express-backend, fastapi-backend,
  nextjs-webapp, telegram-bot (were present locally but missing from the repo)
- .env.example in all 7 templates: ai-agent, express-backend, fastapi-backend, hybrid-code-n8n,
  n8n-workflow, nextjs-webapp, telegram-bot (previously blocked by incorrect .gitignore pattern)
- .github/ scaffolding (CI, Dependabot, PR/issue templates, CODEOWNERS):
  - ci.yml: shellcheck, markdownlint-cli2, gitleaks secret scan, large-file check
  - dependabot.yml: weekly updates for github-actions + npm (2 templates) + pip (3 templates)
  - PULL_REQUEST_TEMPLATE.md, bug_report.md, feature_request.md, config.yml, CODEOWNERS
- scripts/verify-local-sync.sh: byte-level drift detector (CRLF-normalised);
  reports MISSING_IN_REPO, MISSING_IN_LOCAL, CONTENT_DIFFER; supports --fix=push dry-run
- scripts/README.md: documents all scripts in scripts/
- `rules/README.md`: rule index by category with layering explanation (why 01/07, 04/11, 10/11 redundancy is intentional)
- `rules/18-observability.md`: three pillars baseline (metrics/logs/traces), structured logging schema, RED+USE methods, alert tiers, April 2026 tooling (OTel, Prometheus, Sentry, Axiom)
- `rules/19-api-versioning.md`: SemVer scheme, URL vs header strategies, deprecation policy, Sunset headers, GraphQL field-level deprecation, webhook pinning, SDK alignment
- `bootstrap-templates/vite-spa/` — React 19 + Vite 6 + TS 5.7 SPA with Vitest 3 + Testing Library + ESLint 9 flat config, production-ready
- `bootstrap-templates/cloudflare-worker/` — TS Worker + Wrangler 4 (compat date 2026-04-01), typed routing, CORS + logging middleware, HMAC webhook stub, Vitest + workers pool
- `bootstrap-templates/README.md` — decision tree, feature matrix, stability labels, Phase-2 roadmap
- `rules/20-rust-standards.md`: Rust 1.85, tokio 1.40, clippy/cargo-audit/cargo-deny, typestate, thiserror+anyhow, AFIT
- `rules/21-swift-standards.md`: Swift 6.1 strict concurrency, SwiftUI @Observable, Swift Testing framework, MVVM, SPM
- `hooks/reference/` (20 hook JSON definitions): a gallery of ready-to-wire hooks — backup-before-edit, change-tracker, console-log-cleaner, conventional-commits, dangerous-command-blocker, desktop-notification-on-stop, file-protection, format-python-files, lint-on-save, plan-gate, scope-guard, secret-scanner, security-scanner, simple-notifications, smart-commit, smart-formatting, tdd-gate, telegram-detailed-notifications, telegram-notifications, test-runner (see `hooks/README.md` for full index)
- `hooks/README.md`: comprehensive hook documentation with per-hook table (event, matcher, purpose, platform, requirements) and activation instructions
- `hooks/settings-hooks.windows.json`: Windows-path variants of the baseline hooks using PowerShell (`pwsh -NoLogo -NoProfile -Command`)
- `scripts/install-lib.sh`: shared helper functions (`collect_files`, `write_manifest`) sourced by `install.sh`
- `scripts/migrate-credentials.sh`: PII-safety utility — scans for plain-text credentials and migrates them to `~/.config/claude-secrets/`; dry-run by default
- `scripts/patch-settings-2026.mjs`: `settings.json` schema migration tool — adds `enabledMcpServers` lazy-loading and 2026 hook events (`ConfigChange`, `PostCompact`, `SessionEnd`); dry-run by default
- `scripts/validate-install.sh`: post-install sanity checker with 7 checks (manifest, rules count, setup.md, phases, hooks, cache size, security); `--json` and `--verbose` flags
- `scripts/cleanup-plugin-cache.sh`: removes stale `temp_git_*` directories from `~/.claude/plugins/cache/`; dry-run by default
- `scripts/README.md`: full scripts index with safety labels, per-script documentation, and contributor guide

### Changed
- .gitignore: narrowed .env.* to .env.local + .env.*.local so .env.example is tracked correctly
- install.sh: now copies .env.example and per-template CLAUDE.md; copies verify-local-sync.sh
- README.md: CI/License/Version badges; Bootstrap Templates notes CLAUDE.md + .env.example;
  added Maintenance/sync-verification section; rule count 18 -> 20 + index; templates 7 -> 9

### Bumped
- express-backend: added engines.node >=20
- nextjs-webapp: added engines.node >=20
- telegram-bot: python-telegram-bot bumped from >=20.7,<22 to >=21.6,<22

---

## [0.2.0] - 2026-04-18

### Added
- `commands/setup-phases/phase-0.md`, `phase-1.md`, `phase-2.md` — extracted from the 1875-line monolith
- `LICENSE` file (MIT) — matches README's long-standing claim
- `CHANGELOG.md` — this file

### Changed
- `/setup` → renamed to `/setup-AI-Pulse-Georgia` — personalizes the command, avoids collision with future community `/setup` commands
- `commands/setup.md` → now a 3-phase router (34 lines) that reads `setup-phases/phase-N.md`
- `install.sh` — copies the new command + phase files; updated usage examples
- `README.md` — references updated to `/setup-AI-Pulse-Georgia`

### Deprecated
- `/setup` command (original name) — kept as a thin alias pointing at `/setup-AI-Pulse-Georgia`; scheduled for removal in v0.3.0

### Migration
If you've already run `./install.sh` from v0.1.x:
1. Re-run `./install.sh` to pick up the new command and phase files.
2. Update your muscle memory: `/setup my-project` → `/setup-AI-Pulse-Georgia my-project`.
3. The old `/setup` still works until v0.3 — you have time.

## [0.1.0] - 2026-03-22

### Added
- Initial release: 18 rules, 7 bootstrap templates, dual-mode `/setup` command, 7 hooks, install script.

[0.2.0]: https://github.com/tornikebolokadze1-cyber/claude-code-setup/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/tornikebolokadze1-cyber/claude-code-setup/releases/tag/v0.1.0
