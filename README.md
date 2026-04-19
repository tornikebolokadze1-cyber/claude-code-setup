# Claude Code Production Setup

[![CI](https://github.com/tornikebolokadze1-cyber/claude-code-setup/actions/workflows/ci.yml/badge.svg)](https://github.com/tornikebolokadze1-cyber/claude-code-setup/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.2.x-blue.svg)](CHANGELOG.md)

A complete, production-grade configuration system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — Anthropic's official AI coding assistant.

**This is not a CLI tool.** It's a configuration layer that installs into your `~/.claude/` directory and gives Claude Code production-level rules, safety guardrails, automated hooks, and a `/setup-AI-Pulse-Georgia` slash command that bootstraps any new project in under a minute.

## The Problem

Every time you start a new project with Claude Code, you start from zero:
- No security rules — Claude can write hardcoded secrets, skip input validation
- No safety net — Claude can `rm -rf`, force push, or change 50 files at once
- No coding standards — inconsistent code across projects
- No testing — changes ship without verification
- No structure — every project is organized differently

## The Solution

Install this once. Every project gets production infrastructure from day one.

```
~/.claude/
├── commands/
│   ├── setup-AI-Pulse-Georgia.md  ← The /setup-AI-Pulse-Georgia slash command
│   ├── setup.md                  ← Deprecated alias (removed in v0.3)
│   └── setup-phases/             ← Phase 0, 1, 2 sub-files
├── rules/                ← 20 rules + index Claude follows automatically
│   ├── 01-auto-checkpoint.md
│   ├── 02-scope-control.md
│   ├── ...
│   └── security.md
├── bootstrap-templates/  ← 9 project starter templates
│   ├── nextjs-webapp/
│   ├── fastapi-backend/
│   ├── express-backend/
│   ├── ai-agent/
│   ├── telegram-bot/
│   ├── n8n-workflow/
│   ├── vite-spa/
│   ├── cloudflare-worker/
│   └── hybrid-code-n8n/
├── scripts/              ← 8 utility scripts (sync, validate, migrate, patch...)
├── hooks/
│   ├── settings-hooks.json         ← 13 baseline hooks (merge into settings.json)
│   ├── settings-hooks.windows.json ← Windows/PowerShell variants
│   └── reference/                  ← 20 opt-in hook definitions (gallery)
└── settings.json         ← Hooks configuration (merge manually)
```

---

## How It Works

### Step 1: Install (one time)

```bash
git clone https://github.com/tornikebolokadze1-cyber/claude-code-setup.git
cd claude-code-setup
./install.sh
```

This copies rules, commands, templates, and scripts into `~/.claude/`. Your existing config is backed up automatically.

### Step 2: Use `/setup-AI-Pulse-Georgia` in any new project

Open Claude Code in an empty directory and type:

```
/setup-AI-Pulse-Georgia my-project-name
```

### Step 3: Claude builds everything

The `/setup-AI-Pulse-Georgia` command runs in **two phases**:

---

## What `/setup-AI-Pulse-Georgia` Creates

### Phase 1 — Universal Infrastructure (automatic, no questions asked)

Every project gets this foundation regardless of tech stack:

```
my-project/
├── .claude/
│   ├── settings.json          ← Permissions (allow/deny commands)
│   ├── settings.local.json    ← Local environment overrides
│   ├── rules/
│   │   ├── interaction.md     ← How Claude communicates with you
│   │   ├── security.md        ← OWASP Top 10, secrets, headers, rate limiting
│   │   ├── quality.md         ← Linting, formatting, commit conventions
│   │   ├── testing.md         ← Automated testing triggers and protocols
│   │   ├── ui-verification.md ← Playwright visual testing at 3 viewports
│   │   └── memory.md          ← Session handoff and decision tracking
│   └── handoff-template.md    ← Template for session-to-session context
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml             ← CI pipeline (lint → test → build)
│   │   └── security.yml       ← Dependency review + secret scanning
│   ├── dependabot.yml         ← Auto-update dependencies
│   ├── CODEOWNERS             ← Who reviews what
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       └── feature_request.md
│
├── .vscode/
│   ├── extensions.json        ← Recommended extensions
│   └── settings.json          ← Editor formatting rules
│
├── src/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── docs/
│   ├── decisions/
│   │   └── 001-initial-setup.md  ← First Architecture Decision Record
│   ├── architecture.md
│   └── how-to-work-with-claude.md
│
├── CLAUDE.md                  ← Project brain — Claude reads this every session
├── .editorconfig              ← Universal formatting
├── .gitignore                 ← Comprehensive (Node, Python, secrets, IDE, OS)
├── .env.example               ← Environment variable template
├── .mcp.json                  ← MCP server config placeholder
├── SECURITY.md                ← Vulnerability disclosure policy
├── CONTRIBUTING.md            ← Contribution guidelines
├── LICENSE                    ← MIT
└── README.md                  ← Project readme
```

### Phase 2 — Tech Stack Selection (conversational)

After infrastructure is ready, Claude asks what you want to build. Based on your description, it:

1. **Detects signals** — web app? bot? automation? AI agent?
2. **Auto-selects the best stack** (or lets you choose manually):

| You Describe | Claude Picks |
|-------------|-------------|
| Website with users and data | Next.js + Supabase + Vercel |
| Static website, no login | Next.js + Vercel |
| E-commerce | Next.js + Supabase + Stripe + Vercel |
| Telegram bot | Python + python-telegram-bot + Railway |
| "When X happens, do Y" | n8n workflow |
| AI chatbot with memory | Python + LangChain + Supabase pgvector |
| AI agent with tools | Python + LangChain/LangGraph |
| REST API | FastAPI + Supabase + Railway |
| Content/data pipeline | n8n + Firecrawl |

3. **Explains every choice** — why this language, why this framework, why this database
4. **Asks for confirmation** before building
5. **Generates working starter code** with at least one passing test
6. **Takes a screenshot** of the running app and shows you

---

## What the Rules Do

20 rules + index that Claude loads and follows automatically in every session:

### Safety & Governance

| Rule | What It Does |
|------|-------------|
| **Auto-Checkpoint** | Creates git save points before risky changes. If something breaks, you say "undo" and it restores. |
| **Scope Control** | 1-3 files: proceed freely. 4-6: tell you first. 7-10: ask permission. 11+: refuse without confirmation. |
| **Error Recovery** | When something breaks: assess severity → communicate in plain language → fix or restore → checkpoint. Two failed fix attempts = auto-restore. |
| **Destructive Actions** | Blocks `rm -rf`, `git push --force`, `DROP TABLE`, and similar. Never deletes files without asking. |
| **Backup Strategy** | Auto-backup before config changes, database changes, or any session with 3+ file modifications. |

### Communication

| Rule | What It Does |
|------|-------------|
| **Communication** | No jargon. "Repository" → "your project folder." "Deploy" → "put it live." One idea per sentence. |
| **Vague Prompt Handling** | "Make it look nicer" → improves spacing, fonts, alignment. "Fix the thing" → checks most recent changes first. Does something useful instead of asking 5 questions. |

### Quality & Testing

| Rule | What It Does |
|------|-------------|
| **Testing** | Auto-runs tests after every change. New function = test required. Bug fix = regression test first. Never commits with failing tests. |
| **UI Verification** | After any visual change: screenshots at desktop (1440px), tablet (768px), mobile (375px). Checks accessibility, console errors, broken links. |
| **Development Workflow** | Research before coding. TDD (Red → Green → Improve). Conventional commits. Branch strategy. |

### Coding Standards

| Rule | What It Does |
|------|-------------|
| **Production Standards** | Immutability first. Functions < 50 lines. Files < 800 lines. Max 4 nesting levels. No hardcoded values. |
| **TypeScript Standards** | No `any`. Zod validation. Named interfaces. Server Components by default. 80%+ coverage. |
| **Python Standards** | Type annotations everywhere. Pydantic at boundaries. `@dataclass(frozen=True)`. pytest + 80% coverage. |
| **Go Standards** | Accept interfaces, return structs. Table-driven tests. `context.Context` for cancellation. `-race` flag always. |
| **Security** | OWASP Top 10 prevention. Parameterized queries only. bcrypt/argon2 for passwords. HTTPS mandatory. Security headers on every response. Rate limiting on all endpoints. |

| **Observability** | Structured JSON logging schema. RED+USE metrics. Distributed tracing via OpenTelemetry. P0/P1/P2/P3 alert tiers. |
| **API Versioning** | SemVer scheme. URL path versioning for public APIs. 90-day deprecation notice. Sunset + Deprecation headers. 410 Gone on removal. |
### Session Management

| Rule | What It Does |
|------|-------------|
| **Session Management** | Start: acknowledge context, check handoff notes. End: checkpoint + summary + next steps. Suggest `/compact` at 60% context usage. |
| **Memory** | Saves architectural decisions to `docs/decisions/`. Creates handoff notes between sessions. Tracks what was built and why. |

---

## What the Hooks Do

7 automated hooks that run on every Claude Code action (configured in `settings.json`):

### Pre-Action Hooks (run BEFORE Claude executes)

| Hook | Trigger | Action |
|------|---------|--------|
| **Audit Logger** | Any Bash, Write, or Edit | Logs tool name + timestamp to `~/.claude/audit-logs/` |
| **Auto-tmux** | `npm run dev` or similar | Starts dev server in a tmux session instead of blocking the terminal |
| **Destructive Command Blocker** | `git push --force`, `rm -rf`, `DROP TABLE` | Blocks the command and logs it |

### Post-Action Hooks (run AFTER Claude writes/edits a file)

| Hook | Trigger | Action |
|------|---------|--------|
| **Auto-Format** | Any JS/TS/JSON/CSS/HTML/Python/Go file | Runs Prettier, Black, or gofmt automatically |
| **Auto-Lint** | Any JS/TS/Python file | Runs ESLint or Pylint with auto-fix |
| **Secret Detection** | Any file write | Scans for hardcoded passwords, API keys, tokens. Blocks if found. |
| **Sensitive File Guard** | .env, .pem, .key, SSH files | Blocks writing to sensitive file types |
| **Auto-Backup** | Any file edit | Copies the file to `~/.claude/file-backups/` before overwriting |
| **Console.log Detector** | JS/TS production files | Warns if `console.log` found in non-test files |
| **TypeScript Checker** | .ts/.tsx files | Runs `tsc --noEmit` to catch type errors immediately |

### Session End Hook

| Hook | Trigger | Action |
|------|---------|--------|
| **Session Metrics** | Claude stops | Logs session timestamp and working directory |

---

## Bootstrap Templates

9 pre-configured project starters that `/setup-AI-Pulse-Georgia` uses based on your chosen stack.
Every template ships with **CLAUDE.md** (project-specific Claude instructions) and **.env.example** (environment variable reference).
See [bootstrap-templates/README.md](bootstrap-templates/README.md) for a decision tree and feature matrix:

### Next.js Web App
```
src/app/          ← App Router with route groups
src/components/   ← UI components (layouts, providers, ui)
src/hooks/        ← Custom React hooks
src/lib/          ← Supabase client, utilities
src/types/        ← TypeScript type definitions
middleware.ts     ← Auth + security middleware
```
Stack: Next.js 14 + Supabase + Tailwind CSS + Vitest

### FastAPI Backend
```
src/app/
  ├── models/      ← SQLAlchemy/Pydantic models
  ├── routers/     ← API routes (health, auth, items)
  ├── schemas/     ← Request/response schemas
  ├── config.py    ← Settings with env validation
  └── main.py      ← App entry with middleware
```
Stack: FastAPI + Pydantic + SQLAlchemy + pytest

### Express Backend
```
src/
  ├── routes/      ← API routes
  ├── middleware/   ← Error handling, rate limiting, validation
  ├── types/       ← TypeScript interfaces
  └── utils/       ← Logger, helpers
```
Stack: Express + TypeScript + Jest + ESLint

### AI Agent
```
src/agent/
  ├── nodes/       ← Planner, executor, reviewer
  ├── tools/       ← Search, calculator, custom tools
  ├── memory/      ← Conversation memory store
  ├── prompts/     ← System prompts and templates
  ├── graph.py     ← LangGraph workflow
  └── state.py     ← Agent state management
```
Stack: LangChain + LangGraph + Python

### Telegram Bot
```
src/bot/
  ├── handlers/    ← Command handlers (start, help, echo)
  ├── utils/       ← Logger, helpers
  ├── config.py    ← Bot configuration
  └── main.py      ← Bot entry point
```
Stack: python-telegram-bot + async

### n8n Workflow
```
workflows/         ← Exportable workflow JSON files
scripts/           ← Deploy and backup scripts
docs/              ← Credentials setup guide
```

### Hybrid (Code + n8n)
```
src/               ← Application code
  ├── routes/      ← API + webhook endpoints
  └── services/    ← n8n client integration
workflows/         ← n8n workflow files
docs/              ← Architecture showing code ↔ n8n connection
```
### Vite SPA
```
src/
  ├── routes/      <- Page components (Home, About, NotFound)
  ├── components/  <- Reusable UI primitives (Button with tests)
  ├── hooks/       <- Data-fetching hooks (use-fetch)
  ├── lib/         <- Typed API client + env validation
  └── types/       <- Shared TypeScript types
```
Stack: React 19 + Vite 6 + TypeScript + React Router 7 + Vitest 3 + Testing Library

### Cloudflare Worker
```
src/
  ├── routes/      <- Endpoint handlers (health, webhook)
  ├── lib/         <- Router + JSON response helpers
  └── middleware/  <- CORS + request logging
wrangler.toml      <- Wrangler 4 config (compat date, KV/D1 stubs)
```
Stack: TypeScript + Wrangler 4 + Vitest (workers pool) + HMAC webhook stub

See [bootstrap-templates/README.md](./bootstrap-templates/README.md) for the full decision tree and feature matrix.


---

## Maintenance

### Sync verification

After editing any rule, template, or script in your local `~/.claude/` directory, run:

```bash
./scripts/verify-local-sync.sh
```

This performs a byte-level diff (CRLF-normalised) between your local `~/.claude/` and the
repo, then reports three categories:

| Category | Meaning |
|---|---|
| `MISSING_IN_REPO` | File exists locally but not in the repo — needs to be committed |
| `MISSING_IN_LOCAL` | File exists in the repo but not locally — run `./install.sh` to fix |
| `CONTENT_DIFFER` | File exists in both but content differs — decide which side is the source of truth |

Exits **0** when clean, **1** when any drift is detected. Use `--fix=push` for a dry-run
list of copy commands that would push local changes back to the repo:

```bash
./scripts/verify-local-sync.sh . ~/.claude --fix=push
```


---

## Installation Options

### Full Install (recommended)

```bash
git clone https://github.com/tornikebolokadze1-cyber/claude-code-setup.git
cd claude-code-setup
./install.sh
```

Copies everything to `~/.claude/`. Existing config is backed up automatically.

### Manual / Partial Install

```bash
# Rules only
cp rules/*.md ~/.claude/rules/

# /setup-AI-Pulse-Georgia command only
cp commands/setup-AI-Pulse-Georgia.md ~/.claude/commands/
cp -r commands/setup-phases/ ~/.claude/commands/

# Specific template only
cp -r bootstrap-templates/fastapi-backend ~/.claude/bootstrap-templates/
```

### Hooks (manual merge required)

Hooks must be merged into your `~/.claude/settings.json`. See [`hooks/README.md`](hooks/README.md) for full documentation.

**Baseline (13 hooks, production-ready):**
```bash
# Merge with jq
jq -s '.[0] * { "hooks": ( ... ) }' ~/.claude/settings.json hooks/settings-hooks.json > /tmp/merged.json   && mv /tmp/merged.json ~/.claude/settings.json
# Windows: use hooks/settings-hooks.windows.json instead
```

**Hooks gallery (`hooks/reference/` — 20 definitions, opt-in):**

A curated library of additional hooks covering:
- Backup-before-edit, change tracker, console.log cleaner
- Conventional commits enforcement, dangerous command blocker
- Desktop & Telegram notifications
- TDD gate, plan gate, scope guard (Spec-Driven Development)
- Secret scanner, security scanner (semgrep/bandit/gitleaks)
- Smart formatting (Prettier/Black/gofmt/rustfmt), smart commits
- Auto test runner (npm test / pytest / rspec)

Pick any hook from `hooks/reference/`, copy its `hooks` block into `~/.claude/settings.json`, and it activates immediately. See [`hooks/README.md`](hooks/README.md) for the full index and activation instructions.

---

## Utility Scripts

---

## Customization

### Add your own rules
Create any `.md` file in `~/.claude/rules/`. Claude loads all markdown files from that directory automatically.

### Add your own templates
Create a new directory in `~/.claude/bootstrap-templates/` with your project structure. The `/setup-AI-Pulse-Georgia` command will use it when the matching stack is selected.

### Modify hooks
Edit the hooks in `~/.claude/settings.json`. Each hook is a shell command that runs on specific triggers.

---

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- Git
- For hooks: Node.js (Prettier, ESLint), Python (Black, Pylint), or Go (gofmt) depending on which languages you use

---

## License

MIT — see [LICENSE](LICENSE) for details.


---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for the full history of changes.

---

Built with Claude Code.
