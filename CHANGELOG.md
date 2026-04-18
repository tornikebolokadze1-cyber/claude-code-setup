# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `bootstrap-templates/vite-spa/` — React 19 + Vite 6 + TS 5.7 SPA with Vitest 3 + Testing Library + ESLint 9 flat config, production-ready
- `bootstrap-templates/cloudflare-worker/` — TS Worker + Wrangler 4 (compat date 2026-04-01), typed routing, CORS + logging middleware, HMAC webhook stub, Vitest + workers pool
- `bootstrap-templates/README.md` — decision tree, feature matrix, stability labels, Phase-2 roadmap

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
