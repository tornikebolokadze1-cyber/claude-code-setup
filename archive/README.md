# Archive — `bootstrap-templates/`

Moved here in **v0.4.0** (2026-04-20).

## Why these were archived

The 9 template directories under `archive/bootstrap-templates/` were useful
for v0.1–v0.3 but created three sustained problems:

1. **Dependabot treated archetypes as live code.** Every week Dependabot
   opened PRs bumping `next`, `typescript`, `vitest`, `eslint`, `zod`,
   `python-telegram-bot`, etc. — even though these are *starter* snapshots
   that consumers copy once and modify. 20+ open PRs accumulated with no
   human reviewer, hiding the 0 real PRs underneath.

2. **Templates drifted from upstream faster than we could maintain them.**
   Next.js 15 → 16, TypeScript 5 → 6, Zod 3 → 4, Jest 29 → 30, pytest 8 → 9
   all landed across a ~3-week window. Keeping 9 templates current with all
   upstream deps is a full-time job; as a one-person-plus-Claude project it
   was never going to work.

3. **Templates duplicated what community scaffolders already do well.**
   `npx create-next-app@latest` produces a better Next.js starter than any
   template we can ship. `cookiecutter gh:arthurhenrique/cookiecutter-fastapi`
   produces a better FastAPI starter. Maintaining parallel copies of what
   already exists upstream is wasted work.

## What replaced them

As of v0.4, **`/setup-AI-Pulse-Georgia` delegates to community scaffolders**
and layers Claude Code conventions on top:

| Stack | Scaffolder | Our value-add |
|---|---|---|
| Next.js webapp | `npx create-next-app@latest` | `CLAUDE.md`, `.claude/rules/`, hooks, CI |
| Vite SPA | `npm create vite@latest` | same |
| FastAPI backend | `cookiecutter gh:arthurhenrique/cookiecutter-fastapi` | same |
| Express backend | `npm init` + minimal config | same |
| Cloudflare Worker | `npm create cloudflare@latest` | same |
| AI agent | our template (no strong community scaffolder) | full archetype |
| Telegram bot | our template (niche scaffolders exist) | full archetype |
| n8n workflow | our template (n8n has no scaffolder) | full archetype |
| Hybrid (code + n8n) | sequence the above | full archetype |

See `commands/setup-phases/phase-2.md` for the full delegation matrix.

## Can I still use these templates?

**Yes**, but they are frozen at their v0.3.0 state and will not receive
dependency updates or feature additions. Two ways to access them:

- After `./install.sh`, they are copied to `~/.claude/archive/bootstrap-templates/`.
- Browse this directory directly on GitHub.

If you're starting a Next.js / Vite / FastAPI / Express / Cloudflare Worker
project, prefer the community scaffolder — it will always be more current
than anything we can preserve here.

## Unarchiving

If a template's ecosystem *does not* evolve a mature scaffolder over time
(e.g., n8n-workflow is likely to stay manual), that template may be promoted
back to an actively maintained location in a future release. File an issue
with the `template-request` label to nominate one.
