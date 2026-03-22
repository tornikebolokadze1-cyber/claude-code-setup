# Claude Code Production Setup

A complete, production-grade configuration system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that transforms it from a basic AI coding assistant into a fully governed development environment.

One command — `/setup` — bootstraps any new project with security, testing, CI/CD, coding standards, and safety guardrails built in from day one.

## What's Inside

### `/setup` Command
A single slash command that creates a complete project infrastructure:
- Git initialization with branch strategy
- CLAUDE.md project brain
- Security rules (OWASP Top 10)
- Automated testing configuration
- CI/CD pipelines (GitHub Actions)
- PR/Issue templates
- VS Code configuration
- Tech stack auto-selection based on your description

### 17 Rule Files
Production rules that Claude follows automatically:

| Rule | What It Does |
|------|-------------|
| `01-auto-checkpoint.md` | Auto-saves before risky changes |
| `02-scope-control.md` | Prevents changing too many files at once |
| `03-error-recovery.md` | Auto-diagnosis and rollback when things break |
| `04-visual-verification.md` | Screenshot-based testing guidance |
| `05-session-management.md` | Context preservation across sessions |
| `06-destructive-actions.md` | Blocks dangerous commands (rm -rf, force push) |
| `07-backup-strategy.md` | Automatic backup before critical changes |
| `08-communication.md` | Plain-language communication (no jargon) |
| `09-vague-prompt-handling.md` | Smart interpretation of unclear requests |
| `10-testing.md` | Automated testing after every change |
| `11-ui-verification.md` | Playwright visual verification protocol |
| `12-memory.md` | Session handoff and decision tracking |
| `13-typescript-standards.md` | TypeScript/JavaScript production standards |
| `14-python-standards.md` | Python production standards |
| `15-go-standards.md` | Go production standards |
| `16-production-standards.md` | Universal cross-language standards |
| `17-development-workflow.md` | TDD, commit conventions, branch strategy |
| `security.md` | Comprehensive security rules (OWASP, secrets, headers) |

### 7 Hooks
Automated actions that run on every tool call:

- **Auto-format** — Prettier (JS/TS), Black (Python), gofmt (Go)
- **Auto-lint** — ESLint (JS/TS), Pylint (Python)
- **Secret detection** — Blocks commits with hardcoded passwords/keys
- **Sensitive file protection** — Blocks editing .env, .pem, .key files
- **Auto-backup** — Copies files before every edit
- **Destructive command blocker** — Prevents force push, rm -rf, DROP TABLE
- **Audit logging** — Logs every tool call for governance

### 7 Bootstrap Templates
Pre-configured project starters:

- **Next.js Web App** — React + SSR + Tailwind
- **FastAPI Backend** — Python API with Pydantic
- **Express Backend** — TypeScript + Jest + ESLint
- **AI Agent** — LangChain/LangGraph + memory + tools
- **Telegram Bot** — python-telegram-bot + async
- **n8n Workflow** — Automation workflow templates
- **Hybrid (Code + n8n)** — App + automation combined

### Utility Scripts
- `cleanup-backups.sh` — Manage backup file rotation
- `session-metrics.sh` — Track session activity

## Quick Install

```bash
git clone https://github.com/tornikebolokadze1-cyber/claude-code-setup.git
cd claude-code-setup
./install.sh
```

This copies everything to your `~/.claude/` directory. Your existing config is backed up automatically.

## Manual Install

If you prefer to pick and choose:

```bash
# Copy just the rules
cp rules/*.md ~/.claude/rules/

# Copy just the /setup command
cp commands/setup.md ~/.claude/commands/

# Copy specific templates
cp -r bootstrap-templates/fastapi-backend ~/.claude/bootstrap-templates/
```

For hooks, merge `hooks/settings-hooks.json` into your `~/.claude/settings.json`.

## Usage

After installing, open Claude Code in any empty directory and type:

```
/setup my-project-name
```

Claude will:
1. Create the full project infrastructure (git, rules, CI/CD, templates)
2. Ask what you want to build
3. Auto-select the best tech stack (or let you choose)
4. Generate working starter code with tests
5. Show you the result with screenshots

## Who Is This For

- **Developers** who want production-ready Claude Code from the start
- **Teams** standardizing AI-assisted development workflows
- **Non-technical users** who need safety guardrails (checkpoints, plain-language errors, visual verification)
- **Anyone** tired of configuring Claude Code from scratch on every project

## Key Features

### Safety for Non-Technical Users
- Auto-checkpoints before multi-file changes
- Plain-language error messages (no stack traces)
- Visual verification with Playwright screenshots
- Emergency prompts: "undo last change", "something broke, fix it"
- Scope control — Claude asks before big changes

### Security by Default
- OWASP Top 10 prevention rules
- Secret detection on every file write
- Destructive command blocking
- Security headers configuration
- Input validation requirements

### Multi-Language Support
Production coding standards for:
- TypeScript / JavaScript
- Python
- Go
- (Rules are extensible — add your own)

## Customization

### Adding Your Own Rules
Create a new `.md` file in `rules/` with your standards. Claude loads all `.md` files from `~/.claude/rules/` automatically.

### Adding Templates
Create a new directory in `bootstrap-templates/` with your project structure. The `/setup` command will detect and offer it.

### Modifying Hooks
Edit `hooks/settings-hooks.json` and merge changes into `~/.claude/settings.json`.

## License

MIT — use it, modify it, share it.

---

Built with Claude Code.
