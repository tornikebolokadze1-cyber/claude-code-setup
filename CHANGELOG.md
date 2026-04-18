# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - v0.3.0

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

### Changed
- .gitignore: narrowed .env.* to .env.local + .env.*.local so .env.example is tracked correctly
- install.sh: now copies .env.example and per-template CLAUDE.md; copies verify-local-sync.sh
- README.md: CI/License/Version badges; Bootstrap Templates notes CLAUDE.md + .env.example;
  added Maintenance/sync-verification section; rule count 18 -> 20 + index

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
