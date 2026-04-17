# Design Document

*Single-page reference for contributors and curious consumers. Target length: 80-150 lines.*

---

## 1. Who Is This For?

This repo targets **developers who want a production-ready Claude Code baseline** —
people who are comfortable running a bash installer, reading markdown, and editing
JSON. Installation requires `git`, `bash`, and a working Claude Code subscription.

**Non-technical end users are not the target audience for this repo.** The installer
has no GUI, no undo button, and no error-recovery wizard. A non-technical user who
wants an opinionated Claude Code setup needs a different product — a packaged GUI
installer or a managed onboarding flow. That is a valid future direction but is
explicitly out of scope here.

---

## 2. Product Archetype

**Published template / opinionated baseline.**

This is not a framework (it imposes no runtime abstractions), not a SaaS (there is
no server), and not a plugin (it does not extend Claude Code's binary). It is a
curated set of text files that Claude Code reads at session start, plus an installer
that puts them in the right place.

---

## 3. Assurance Tier: `published-template`

| Property         | Value                                                         |
|------------------|---------------------------------------------------------------|
| Validation       | CI — install smoke, JSON lint, rule line-count limits         |
| SLA              | None — community-maintained                                   |
| Breaking changes | Tracked in `CHANGELOG.md`; semver tags planned                |
| Adoption risk    | Users adopt at their own risk; pin to a release tag           |

CI gives *syntactic correctness* and *basic install smoke*, not behavioural
guarantees. The quality of outcomes depends on how well the rules map to the
user's actual project context.

---

## 4. What Is IN Scope

- `rules/` — 18 markdown files that Claude Code loads as context at session start
- `hooks/settings-hooks.json` — 11 pre/post-tool hooks for audit, governance, and dev-server management
- `commands/setup.md` + `commands/setup-phases/` — the `/setup` slash command and its phase bodies
- `bootstrap-templates/` — 7 project-type scaffolds that `/setup` can copy into a new project
- `scripts/` — operator utilities (backup cleanup, session metrics)
- `install.sh` — idempotent bash installer that places the above into `~/.claude/`
- CI that validates syntactic correctness, rule count, line-count limits, and basic install smoke
- Contributor documentation (`README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, `DESIGN.md`)

---

## 5. What Is OUT of Scope

- **Running Claude Code itself** — that is Anthropic's product
- **Writing your application code** — that is what you and Claude produce together after running `/setup`
- **Monitoring or telemetry** — no runtime observation of Claude sessions
- **Paid support or enterprise compliance certifications** — community only
- **Windows-native (PowerShell) installer** — Git Bash or WSL is the supported path for Windows users; `hooks/settings-hooks.windows.json` provides PowerShell hook equivalents but the installer itself is bash-only

---

## 6. Design Principles

1. **Opinionated defaults, not a framework.** Every behaviour is a file you can read
   and delete. Disable anything by removing the file.
2. **Everything is text.** No binary artifacts, no compiled code, no database. Git is
   the only required infrastructure.
3. **Idempotent installer.** Running `install.sh` twice is safe. The second run backs
   up the first install and re-applies the latest files.
4. **Explicit over implicit.** No hidden auto-magic. Every Claude behaviour enabled by
   this repo traces to a file in `rules/`, `hooks/`, or `commands/`.
5. **Cross-platform where cheap.** Bash + POSIX paths cover Linux, macOS, and Git
   Bash / WSL on Windows. Platform-specific behaviour (PowerShell hooks) is
   isolated into dedicated files.
6. **Context-efficient.** Rule files stay under 400 lines. No guidance is duplicated
   across files. Smaller files = less wasted context per Claude session.

---

## 7. Known Design Tensions

Honest tradeoffs that were deliberately accepted:

- **Context cost.** Loading 18 rule files costs approximately 2,400 lines of context
  per session. We accept this for organisation and discoverability over density.
  Consolidation into fewer, larger files is deferred until real usage data suggests
  which rules are actually loaded and consulted.

- **Hook coverage gap.** Hooks fire on Claude tool calls, not on all git changes.
  Git pre-commit hooks (e.g., gitleaks) are separately recommended but not shipped
  by this repo's installer. Users who want full coverage need both.

- **Template drift.** Bootstrap templates reference framework versions that will
  become stale. Without active community maintenance, a `nextjs-webapp` template
  may lag behind the actual Next.js release cadence. Templates carry their own
  lifecycle and will drift without contributors who keep them current.

---

## 8. Roadmap Hints

No dates. In rough priority order:

- **Community templates** — accept contributed bootstrap templates for additional stacks (Astro, SvelteKit, Django, Go, Rust)
- **Plugin-style distribution** — allow users to opt into only the rule subsets they want rather than installing everything
- **Opt-in telemetry** — aggregate (never individual) signal on which rules users keep vs. delete, to inform pruning decisions
- **Semver-pinned releases** — GitHub releases with version tags so consumers can pin to a known-good snapshot and upgrade deliberately
- **Unified rule bundle** — an optional single-file `rules-bundle.md` that concatenates all 18 rules for contexts where a single large file is preferred over 18 small ones
