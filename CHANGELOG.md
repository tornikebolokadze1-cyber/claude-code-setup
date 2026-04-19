# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.1] - 2026-04-20

Adversarial-audit follow-up to v0.4.0. Five parallel critical-review agents
(flow, install pipeline, scaffolder validation, docs, security) found 19 P0
and 24 P1 issues in the freshly-shipped v0.4.0 — many of which meant
`/setup-AI-Pulse-Georgia` would have failed on first run for most stacks.
This release fixes all P0 findings and the most impactful P1s.

### Fixed — P0 (would have broken first user run)

- **Scaffolder matrix (`commands/setup-phases/phase-2.md` §2.7.3):**
  - Next.js: `--no-git` → `--disable-git`; added `--eslint --turbopack --skip-install --yes` to suppress new 16.x prompts.
  - Vite: added explicit non-empty-dir handling via sibling-directory + rsync; documented Node ≥ 20.19 requirement for Vite 7.
  - FastAPI cookiecutter: `--no-input` alone produced project named "Name of the project"; now passes `project_name/full_name/email` overrides.
  - Cloudflare: `--ts` → `--lang=ts`; added `--accept-defaults --no-deploy`.
  - Express: removed `npm init -y` (was clobbering template's `package.json`).
  - Hybrid: split into 3-step confirmed flow (ask → scaffold-and-checkpoint → copy n8n archetype).
- **`install.sh` now copies `hooks/` and `templates/`** — previously both directories were skipped entirely, meaning the advertised "13 active hooks" and the `templates/CLAUDE.md.example` reference template never reached `~/.claude/`. A fresh install was silently missing half its surface area.
- **`scripts/validate-install.sh` no longer hardcodes `RULE_COUNT == 18`** — repo ships 23 rule files; doctor now uses a plausibility floor (≥ 15) and counts dynamically with `find`.
- **Phantom-path references removed:**
  - `phase-1.md` no longer cites `~/claude-code-bootstrap/` (3 occurrences); inlines guidance or points to `~/.claude/.github-defaults/` with fallback.
  - `phase-2.md` §2.7.5 no longer cites `~/Projects/github-actions-templates/`; generates CI inline per stack.
  - `phase-2.md` §2.7.6 no longer cites `~/.claude/bootstrap/vscode/`; inlines extension recommendations.
- **`README.md`:**
  - Truncated `jq -s '.[0] * { "hooks": ( ... ) }'` snippet replaced with a working `jq -s '.[0] * .[1]'` command (Unix + Windows variants).
  - Empty `## Utility Scripts` section populated with the full script index.
  - Stale "7 automated hooks" count replaced with tiered description (13 baseline + 20 reference).
- **`scripts/verify-local-sync.sh`** COMPARE_PATHS: removed stale `bootstrap-templates` entry (was generating false-positive drift every run), added `templates` and `SECURITY.md`.
- **`commands/setup.md`:** removed stale "will be removed in v0.3" text — v0.3/v0.4 have shipped; alias is now documented as kept indefinitely.
- **`CHANGELOG.md`:** added missing compare links for `[0.3.0]` and `[0.4.0]` (Keep-a-Changelog compliance).

### Added

- **`SECURITY.md`** at repo root — supported versions, vulnerability reporting procedure, threat model for scaffolder delegation (`npx --yes`, `pipx run`), residual-risk disclosure.
- **`.gitleaks.toml`** — custom rules for Telegram bot tokens, Anthropic API keys, OpenAI keys, n8n API keys, Supabase service-role JWTs, Cloudflare API tokens, Firecrawl API keys. Default gitleaks rules did not cover several of the exact secret types this repo's users routinely handle.
- **`templates/settings.local.json.example`** — reference Claude Code project-level permissions overlay with 60+ deny-list entries (rm -rf, git force-push, DROP TABLE, shutdown, curl|bash, SSH key reads, secret-file writes) per rule 06 and security.md §1.2. CLAUDE.md has long cited a "115-entry deny-list" without the repo actually shipping one.
- **`templates/README.md`** — explains what lives in `templates/` and how/when `/setup-AI-Pulse-Georgia` uses each reference file.
- **`uninstall.sh`** — safe, backup-first removal of everything `install.sh` installed. Preserves user's `settings.json`, `settings.local.json`, memory, and projects. Ported from the stale `chore/quality-100` branch.
- **CI smoke test** — `.github/workflows/ci.yml` now runs `./install.sh` against a scratch `HOME` and asserts the expected directory tree + rule count. This would have caught P0-level install bugs before v0.4.0 shipped.
- **`permissions: { contents: read }`** top-level block in `ci.yml` (security.md §1.2 least privilege). GitHub's default token grant is implicit write; this makes the scope explicit.

### Changed

- **Scaffolder invocation protocol** (phase-2.md §2.7.3.c): scaffolders now run in a sibling temp directory, not `.`, to avoid the "target not empty" conflict caused by Phase 1 creating files first. Results are `rsync`-ed back into the project root with `--ignore-existing`.
- **Consent protocol** (§2.7.3.f): the first scaffolder invocation on a machine now explicitly discloses the third-party supply-chain risk. Consent is cached at `~/.claude/.consent-scaffolders.json` so subsequent runs don't re-prompt.
- **Archive template dependency bumps:**
  - `ai-agent/pyproject.toml`: `langchain>=0.3.18 → >=1.1,<2`, `langgraph>=0.3.12 → >=1.0,<2` (LangChain 1.0 unified the agent API; `langgraph.prebuilt` moved to `langchain.agents`).
  - `telegram-bot/pyproject.toml`: `python-telegram-bot>=21.6,<22 → >=22.0,<23` (v21 reached EOL Q1 2026).
  - `telegram-bot/requirements.txt`: bumped PTB 21.10 → 22.7, ruff 0.4.10 → 0.15.11, pytest-asyncio 0.24.0 → 0.26.0, mypy 1.13.0 → 1.20.1, python-dotenv 1.0.1 → 1.2.2.
- **`.gitignore`** expanded per security.md §4.2 mandate: added `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.jks`, `credentials.json`, `serviceAccountKey.json`, `secrets/`, `.envrc`, `.envrc.template.*`, `.claude/settings.local.json`. The repo previously preached patterns it didn't enforce on itself.

### Migration (v0.4.0 → v0.4.1)

Re-run `./install.sh`. It will now populate `~/.claude/hooks/`,
`~/.claude/templates/`, and refresh the updated phase/command/rule files.
No manual migration needed. `/setup-AI-Pulse-Georgia` keeps the same entry
point — only the internal scaffolder matrix changed, and the new version
actually works.

### Research basis

Five parallel critical-review agents (general-purpose model, adversarial
prompting) audited v0.4.0 on 2026-04-20:

- Agent 1 — End-to-end flow: 4 P0 + 10 P1.
- Agent 2 — Install pipeline + CI: 4 P0 + 8 P1 + 8 coverage gaps.
- Agent 3 — Scaffolder delegation vs upstream: 5 of 9 rows broken on first run.
- Agent 4 — Documentation and reference integrity: 6 P0 + 13 P1.
- Agent 5 — Security + supply chain: 0 P0 exploit + 7 P1 hardening gaps.

Total: 19 P0 + 24 P1 findings. This release addresses all 19 P0 and most
of the P1s. The residual P1s (GH Actions SHA pinning, macOS/Windows CI
matrix) are tracked in `docs/decisions/` for future iterations.

---

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

[0.4.1]: https://github.com/tornikebolokadze1-cyber/claude-code-setup/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/tornikebolokadze1-cyber/claude-code-setup/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/tornikebolokadze1-cyber/claude-code-setup/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/tornikebolokadze1-cyber/claude-code-setup/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/tornikebolokadze1-cyber/claude-code-setup/releases/tag/v0.1.0
