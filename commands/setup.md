---
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent, TodoWrite, WebFetch
description: Bootstrap a complete Claude Code project with professional infrastructure — security, CI/CD, GitHub templates, rules, testing, and all configurations. Then help the user define their idea and build it.
argument-hint: [optional: project-name]
---

# Bootstrap Complete Claude Code Project

Create a production-grade project infrastructure with everything configured from day one.
Target user: someone who writes PROMPTS to Claude Code, NOT code themselves.

**Project name hint:** $ARGUMENTS

---

## Phase 1: Infrastructure Setup (Automatic — No Questions About Tech)

This phase creates the UNIVERSAL infrastructure that every project needs.
No technology questions. No "what should the app do?" yet. Just the foundation.

### 1.1 — Get Project Name

If not in $ARGUMENTS, ask in Georgian:
"პროექტის სახელი? (ინგლისურად, lowercase, მაგ: my-cool-app)"

### 1.2 — Validate & Initialize

- Check current directory is empty (or has only non-essential files like .DS_Store, logs)
- If not empty, ask: "ფოლდერი ცარიელი არ არის. მაინც აქ შევქმნა? [კი/არა]"
- `git init`
- Create `main` and `develop` branches

### 1.3 — Create CLAUDE.md

Generic project brain — will be updated in Phase 2 when technology is chosen.

```markdown
# Project: {name}

## Overview
Project created with /setup. Idea and tech stack will be defined by the user.

## How Claude Should Work With the User
- User writes prompts, not code — explain everything in plain language
- Before making changes: say what you'll change and why
- After changes: explain how to verify (which URL, what to click)
- If prompt is vague: ask clarifying questions BEFORE writing code
- Change ONLY what was asked — never refactor or "improve" uninstructed code
- If changing 4+ files: list them and get confirmation first
- Never show raw error messages without plain-language explanation
- Speak in Georgian unless user switches to English

## Data Safety
- Auto-checkpoint before any multi-file change
- Never delete files without asking
- If user says "undo" — use git to restore

## Security Rules
- Never put secrets in code — use environment variables
- Validate all user inputs
- Use parameterized queries
(detailed rules in .claude/rules/security.md)

## Testing (mandatory — automatic)
- After every function: run tests
- After every UI change: Playwright screenshot + show user
- Before commit: tests MUST pass
- New endpoint/page: minimum 1 test
(detailed rules in .claude/rules/testing.md, ui-verification.md)

## Code Quality
- Linter must pass (will be configured when tech stack is chosen)
- Formatter for consistency
- Conventional commits: feat:, fix:, docs:, test:, refactor:, chore:

## Memory & Context
- End of session: save important decisions
- Start of session: read previous context
- Architectural decisions: save to docs/decisions/
(detailed rules in .claude/rules/memory.md)
```

### 1.4 — Create .claude/ Directory

**`.claude/settings.json`:**
```json
{
  "permissions": {
    "allow": [
      "git status", "git diff", "git log", "git add",
      "git commit", "git checkout -b", "git branch",
      "git stash", "git stash pop",
      "ls", "find", "cat", "head", "tail", "wc"
    ],
    "deny": [
      "rm -rf /", "rm -rf ~", "rm -rf .", "rm -rf *",
      "git push --force", "git push -f",
      "git reset --hard", "git clean -f", "git clean -fd",
      "git checkout -- .", "git branch -D main", "git branch -D develop",
      "sudo", "su -",
      "chmod 777", "chmod -R 777",
      "DROP TABLE", "DROP DATABASE", "TRUNCATE",
      "ssh ", "scp ",
      "curl | bash", "curl | sh", "wget | bash", "wget | sh",
      "npm install -g", "pip install --break-system-packages",
      "python -m http.server", "ngrok", "localtunnel",
      "osascript", "defaults write",
      "shutdown", "reboot",
      "kill -9", "killall",
      "eval ", "exec "
    ]
  },
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

NOTE: `allow` list will be extended in Phase 2 when package manager is known (npm test, pip install, etc.)

**`.claude/settings.local.json`:**
```json
{ "env": {} }
```

**`.claude/rules/interaction.md`:**
Rules for how Claude should behave with non-technical users:
- Always explain in plain language (Georgian by default)
- Ask before big changes (4+ files)
- Auto-checkpoint before multi-file changes
- Show verification steps after every change
- Never show raw stack traces
- Handle vague prompts by interpreting charitably, then confirming
- Scope control: only change what was asked
- Recovery: if user says "undo", "broke", "fix" → auto-recover
- Emergency prompts: "გააუქმე ბოლო ცვლილება", "რაღაც გაფუჭდა, გაასწორე", "დააბრუნე ბოლო მომუშავე ვერსია"

**`.claude/rules/security.md`:**
- OWASP Top 10 awareness (simplified for Claude's auto-enforcement)
- Secrets management: never in code, always .env
- Input validation: all user inputs must be validated
- Security headers: CSP, HSTS, X-Frame-Options, X-Content-Type-Options
- Rate limiting on all endpoints
- Dependency security: audit after every install
- Network security: no public exposure without consent
- File upload: validate type by magic bytes, not extension
- Error handling: never expose stack traces, SQL, or internal paths to users

**`.claude/rules/quality.md`:**
- Linting rules: auto-run, zero errors in CI
- Formatting rules: auto-format on save
- Git workflow: main/develop/feature branches
- Conventional commit format: feat:, fix:, docs:, test:, refactor:, chore:
- Pre-commit hooks: lint + format + secret scan
- Code review: self-review before commit

**`.claude/rules/testing.md`:**
Copy from ~/.claude/rules/10-testing.md — comprehensive automated testing:
- When to test (8 automatic triggers)
- UI/UX testing with Playwright MCP (screenshots at 3 viewports)
- Code testing (happy path + error case per function)
- Integration testing (API, auth, DB, webhooks)
- Automated verification flow (checkpoint → test → screenshot → ask user)
- Pre-commit: tests MUST pass, never skip with --no-verify
- Non-coder communication (show screenshots, not test output)

**`.claude/rules/ui-verification.md`:**
Copy from ~/.claude/rules/11-ui-verification.md — visual verification:
- File-type triggers (.tsx, .vue, .html, .css → auto-verify)
- 7-step verification sequence with Playwright/Browser Use
- Responsive checks (mobile 375px, tablet 768px, desktop 1440px)
- Accessibility checks (alt text, headings, contrast, keyboard nav)
- Performance checks (LCP < 2.5s, CLS < 0.1, no console errors)
- Before/after screenshot comparison
- Interactive element testing (buttons, forms, links)
- Error state verification (empty, loading, error, 404)

**`.claude/rules/memory.md`:**
Copy from ~/.claude/rules/12-memory.md — session persistence:
- Session start: read previous context, check handoff notes
- Session end: create handoff note with accomplishments + next steps
- Decisions: save to docs/decisions/ as ADRs
- Context management: suggest /compact at 60% usage
- Handoff notes: keep latest 3, delete older

### 1.5 — Create .github/ Directory

**`.github/workflows/ci.yml`:**
Placeholder CI — will be configured for specific stack in Phase 2:
```yaml
name: CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
permissions:
  contents: read
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Project check
        run: echo "CI pipeline will be configured when tech stack is chosen"
```

**`.github/workflows/security.yml`:**
Generic security workflow (works without stack-specific config):
- Dependency review on PRs
- Secret scanning
- Weekly schedule
- Minimal permissions

**`.github/dependabot.yml`:**
GitHub Actions updates only (package ecosystem added in Phase 2):
```yaml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
```

**`.github/CODEOWNERS`:**
```
* @{{GITHUB_USERNAME}}
```
Ask for GitHub username or use placeholder.

**`.github/PULL_REQUEST_TEMPLATE.md`:**
Change type checkboxes + checklist (from ~/claude-code-bootstrap/.github/).

**`.github/ISSUE_TEMPLATE/bug_report.md`:**
Structured bug report with environment info.

**`.github/ISSUE_TEMPLATE/feature_request.md`:**
Problem + proposed solution + alternatives.

### 1.6 — Create Project Directories

```
src/
└── .gitkeep

tests/
├── unit/
│   └── .gitkeep
├── integration/
│   └── .gitkeep
└── e2e/
    └── .gitkeep

docs/
├── decisions/
│   └── 001-initial-setup.md    ← ADR: "Project initialized with /setup"
├── architecture.md             ← Placeholder, updated in Phase 2
└── how-to-work-with-claude.md  ← Georgian prompt guide (from ~/docs/)
```

### 1.7 — Create Root Config Files

**`.editorconfig`:**
Universal formatting — indent (2 spaces), charset (utf-8), trailing whitespace (trim), final newline (insert).

**`.gitignore`:**
Comprehensive — covers ALL common stacks preemptively:
- Node: node_modules/, .next/, dist/, out/, coverage/
- Python: __pycache__/, .venv/, *.pyc, .pytest_cache/
- Secrets: .env, .env.*, *.pem, *.key, credentials.json
- IDE: .idea/, .vscode/*.code-workspace
- OS: .DS_Store, Thumbs.db
- Build: build/, dist/, out/
- Logs: *.log, logs/

**`.env.example`:**
```
# Environment variables for this project
# Copy this file to .env and fill in real values
# NEVER commit .env to git

# Example:
# DATABASE_URL=postgresql://user:password@localhost:5432/dbname
# API_KEY=your-api-key-here
```

**`SECURITY.md`:**
Vulnerability disclosure policy with response timeline (from ~/claude-code-bootstrap/).

**`CONTRIBUTING.md`:**
Fork → branch → code → test → PR workflow (from ~/claude-code-bootstrap/).

**`LICENSE`:**
MIT with current year and user's name.

**`README.md`:**
Basic readme with project name and "Created with Claude Code /setup":
```markdown
# {project-name}

> Project infrastructure created with Claude Code `/setup`

## Getting Started

This project's tech stack and features will be configured based on your requirements.
Tell Claude what you want to build!

## Project Structure

See [docs/architecture.md](docs/architecture.md) for details.

## Working with Claude

See [docs/how-to-work-with-claude.md](docs/how-to-work-with-claude.md) for prompt examples and tips.
```

### 1.8 — Create IDE Configuration

**`.vscode/extensions.json`:**
Universal extensions (not stack-specific):
```json
{
  "recommendations": [
    "anthropic.claude-code"
  ]
}
```
Stack-specific extensions will be added in Phase 2.

**`.vscode/settings.json`:**
```json
{
  "editor.formatOnSave": true,
  "editor.tabSize": 2,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true
}
```

### 1.9 — Create .mcp.json

Empty by default. User's global MCP servers will work.
```json
{ "mcpServers": {} }
```

### 1.10 — Create Handoff Template

**`.claude/handoff-template.md`:**
```markdown
# Session Handoff - YYYY-MM-DD

## Accomplished
- [List of things completed]

## Current State
- App status: [working / has issues / in progress]
- Branch: [current git branch]

## Next Steps
1. [Most important next task]
2. [Second priority]

## Important Context
- [Non-obvious information for next session]
```

### 1.11 — Initial Commit

```bash
git add -A
git commit -m "feat: initial project infrastructure with Claude Code /setup"
```

### 1.12 — Show Summary (Georgian)

```
✅ პროექტი "{name}" — ინფრასტრუქტურა მზადაა!

📁 შექმნილი სტრუქტურა:
   {actual tree output}

🛡️ დაცვის 3 ხაზი:
   ✅ .claude/rules/ — Claude-ს ქცევის წესები (უსაფრთხოება, ტესტირება, კომუნიკაცია)
   ✅ .github/ — CI/CD + security scanning + PR/issue შაბლონები
   ✅ .gitignore — secrets და build ფაილები დაცულია

📝 შემდეგი ნაბიჯი:
   ახლა აღწერე რა აპლიკაცია/ინსტრუმენტი გინდა ააწყო.
   მაგალითად:
   - "მინდა ვებსაიტი სადაც ადამიანები ჯავშანს გააკეთებენ"
   - "მინდა ბოტი რომელიც ტელეგრამზე კითხვებს უპასუხებს"
   - "მინდა AI აგენტი რომელიც დოკუმენტებს გააანალიზებს"
   - "მინდა ავტომატურად დაიპოსტოს კონტენტი სოციალურ ქსელებში"

🆘 თუ რამე გაფუჭდა:
   - "გააუქმე ბოლო ცვლილება"
   - "რაღაც გაფუჭდა, გაასწორე"
   - "დააბრუნე ბოლო მომუშავე ვერსია"

📖 დეტალური ინსტრუქცია: docs/how-to-work-with-claude.md
```

---

## Phase 2: Idea Definition & Technology Selection

This phase starts when the user describes what they want to build.
It happens AFTER infrastructure is ready, in a natural conversation flow.

### 2.1 — Wait for User's Idea

Do NOT ask proactively. Wait for the user to describe their idea.
When they do, proceed to Signal Detection.

### 2.2 — Signal Detection (internal — do not show to user)

From the user's description, detect:

| Signal | Keywords |
|--------|----------|
| Type: Web | "ვებსაიტი", "გვერდი", "აპლიკაცია", "დაშბორდი", "მაღაზია" |
| Type: Bot | "ბოტი", "ტელეგრამი", "დისქორდი" |
| Type: Automation | "ავტომატურად", "ყოველდღე", "როცა მოხდეს" |
| Type: AI Agent | "AI", "აგენტი", "გააანალიზებს", "შეაჯამებს" |
| Users needed | "მომხმარებლები", "რეგისტრაცია", "ანგარიში", "კლიენტები" |
| Database needed | "შეინახოს", "პროდუქტები", "შეკვეთები", "სია", "მონაცემები" |
| Real-time | "ჩატი", "ლაივ", "ნოტიფიკაცია", "რეალურ დროში" |
| Public | "საჯარო", "ყველასთვის", "ინტერნეტში" |

### 2.3 — Follow-up Questions (Georgian)

Ask ONE question at a time. Wait for each answer. Maximum 3 follow-ups.
Skip any that were already answered in the user's description.

Follow-up A (if Users unclear):
"მომხმარებლებს დარეგისტრირება და შესვლა დასჭირდებათ?"
→ [კი] / [არა] / [ჯერ არ ვიცი]

Follow-up B (if Data unclear):
"ინფორმაციის შენახვა გჭირდება? (პროდუქტები, შეკვეთები, პოსტები...)"
→ [კი] / [არა]

Follow-up C (if Audience unclear):
"ვინ გამოიყენებს?"
→ [მხოლოდ მე] / [ჩემი გუნდი] / [საჯარო — ნებისმიერი]

### 2.4 — Tech Selection Mode

"Claude-მ თავად აირჩიოს საუკეთესო ტექნოლოგიები, თუ შენ გინდა არჩევა?"
→ [Claude აირჩიოს] ← default, recommended for non-coders
→ [მე ავირჩევ] → show tech stack menu

### 2.5 — Auto-Selection Matrix (when user picks "Claude აირჩიოს")

| Description signals | Stack |
|---|---|
| Web + users + data | Next.js + Supabase + Vercel |
| Web + no users + no data | Next.js + Vercel (static) |
| Web + e-commerce | Next.js + Supabase + Stripe + Vercel |
| Telegram bot | Python + python-telegram-bot + Railway |
| Telegram bot + data | Python + python-telegram-bot + Supabase + Railway |
| Simple automation ("when X do Y") | n8n workflow |
| Complex automation (many steps) | n8n + Code nodes |
| AI chatbot (simple) | n8n + AI nodes |
| AI chatbot (RAG/memory) | Python + LangChain + Supabase pgvector |
| AI agent (tool-using) | Python + LangChain/LangGraph |
| API/backend only | FastAPI + Supabase + Railway |
| Data pipeline/scraping | n8n + Firecrawl |
| Content pipeline | n8n (use existing AI Pulse pattern) |

### n8n vs Code vs Hybrid Decision (internal logic)

```
1. IF needs visible UI (website, dashboard)           → CODE
2. IF connecting services ("when X, do Y")            → N8N
3. IF simple AI + standard APIs                       → N8N with AI nodes
4. IF complex AI (RAG, memory, custom tools)          → CODE (Python)
5. IF website + background automations                → HYBRID
6. IF bot + side automations                          → HYBRID
7. DEFAULT                                            → HYBRID
```

SCALABILITY CHECK:
- IF expected users > 10,000 → prefer CODE over N8N
- IF data volume > 100GB → prefer CODE with proper DB
- IF real-time processing needed → CODE (N8N has latency)
- IF budget is $0 and simple → N8N (free tier covers it)

When recommending n8n:
- Check if user has an n8n instance configured in CLAUDE.md global rules
- Default instance: aipulsegeorgia2025.app.n8n.cloud
- Ask: "შენს n8n ინსტანციაზე გავაკეთოთ? (aipulsegeorgia2025.app.n8n.cloud)" — let user confirm or provide different URL

### 2.6 — Confirmation (MANDATORY — never skip)

Present the plan in plain language WITH DETAILED EXPLANATIONS for every choice.
The user must understand WHY each technology was chosen. Speak in Georgian.

**Template:**

```
აი რას ავაშენებ:

📋 პროექტი: [one-line summary]

🏗️ რას შევქმნი:
  - [Component 1]: [plain language what it does]
  - [Component 2]: [plain language what it does]

💻 პროგრამული ენა: [Language]
  რატომ: [explanation]

🧱 ფრეიმვორკი: [Framework]
  რატომ: [explanation]

🗄️ მონაცემთა ბაზა: [Database]
  რატომ: [explanation]

🚀 სერვერი/ჰოსტინგი: [Deploy target]
  რატომ: [explanation]

⚙️ მიდგომა: [კოდი / n8n / შერეული]
  რატომ: [explanation]

💰 ღირებულება: [cost breakdown]

🔄 ალტერნატივები (თუ გინდა შეცვლა):
  - [alternatives with when they're better]

ეთანხმები?
  → [კი, ავაშენოთ]
  → [რამე შევცვალო]
  → [მეტი ახსნა მინდა]
```

### 2.7 — Build (after user confirms)

Use TodoWrite to track all tasks. Mark each done as completed.

#### 2.7.1 — Update CLAUDE.md
Add the chosen tech stack, architecture details, and project-specific rules.

#### 2.7.2 — Update .claude/settings.json
Add stack-specific allowed commands:
```json
"{package-manager} test",
"{package-manager} run lint",
"{package-manager} run build",
"{package-manager} run dev"
```

#### 2.7.3 — Add Stack-Specific Config Files
**IF a pre-built template exists** (in ~/.claude/bootstrap-templates/):
Copy and adapt the template. These are tested and production-ready.

Available templates: nextjs-webapp, ai-agent, fastapi-backend, express-backend, telegram-bot, n8n-workflow, hybrid-code-n8n

**IF NO pre-built template exists:**
Follow MANDATORY research-first protocol:
1. Use WebSearch for "[framework/type] project structure best practices 2025 2026"
2. Use `context7` MCP (`mcp__plugin_context7_context7__resolve-library-id` then `query-docs`) for up-to-date documentation
3. Read at least 2-3 authoritative sources
4. Create structure based on research
5. Write working starter code (entry point + health check)
6. Verify it works (install → build → run → check)

**IMPORTANT:** Never generate source code from memory alone for unfamiliar project types.

#### 2.7.4 — Include Security Libraries
Automatically add security packages:

**Node.js (Express):** helmet, express-rate-limit, cors
**Node.js (Next.js):** configure built-in security headers in next.config.js
**Python:** python-dotenv, pydantic

#### 2.7.5 — Update CI/CD
Replace placeholder ci.yml with stack-specific pipeline from ~/Projects/github-actions-templates/
- Node.js: ci.yml, security.yml, deploy.yml, dependabot.yml
- Python: ci.yml, security.yml, deploy.yml, dependabot.yml

#### 2.7.6 — Update .vscode/
Add stack-specific extensions and settings from ~/.claude/bootstrap/vscode/

#### 2.7.7 — Create Source Code
- Working entry point (not empty placeholders)
- /health endpoint or equivalent
- Basic middleware/setup placeholders
- At least 1 passing test

#### 2.7.8 — Install Dependencies
Ask: "დამოკიდებულებები დავაყენო?"
Only install if confirmed.
After install: run audit and warn about vulnerabilities.

#### 2.7.9 — Set Up Pre-commit Hooks
Node.js: `npx husky init` + lint-staged
Python: `pre-commit install`

#### 2.7.10 — Update docs/
- Update architecture.md with actual architecture
- Update README.md with badges, commands, structure
- Create ADR: 002-tech-stack-choice.md

#### 2.7.11 — Commit
```bash
git add -A
git commit -m "feat: add {tech-stack} application structure"
```

### 2.8 — Post-Build Summary (Georgian)

```
✅ პროექტი "{name}" მზადაა!

📁 სტრუქტურა:
   {actual tree output}

🛡️ დაცვის 3 ხაზი:
   ✅ Pre-commit hooks — ავტომატური lint + secret scan
   ✅ GitHub Actions — CI/CD + CodeQL security
   ✅ .claude/rules/ — Claude-ს ქცევის წესები

🚀 როგორ დაიწყო მუშაობა:
   უბრალოდ უთხარი Claude-ს რა გინდა, მაგალითად:
   - "შექმენი მთავარი გვერდი ლოგოთი და მენიუთი"
   - "დაამატე რეგისტრაციის ფორმა"
   - "გააკეთე API endpoint პროდუქტების სიისთვის"

🆘 თუ რამე გაფუჭდა:
   - "გააუქმე ბოლო ცვლილება"
   - "რაღაც გაფუჭდა, გაასწორე"
   - "დააბრუნე ბოლო მომუშავე ვერსია"
```

### Post-Build Verification

After building everything, automatically:
1. Start the dev server
2. Take a screenshot of the running app
3. Show the user: "აი ასე გამოიყურება შენი ახალი პროექტი:"
4. Ask: "ყველაფერი კარგად გამოიყურება?"

### User Feedback

After showing the summary, ask:
"რამე შეიცვალოს? 1-10 შეაფასე რამდენად მოგეწონა სტრუქტურა."
Save the rating to auto-memory for future improvements.

---

## For N8N-ONLY Projects

If the auto-selection determined pure n8n:

Skip source code generation. Instead:
1. Create a `workflows/` directory with template JSON
2. Create documentation on how to import to n8n
3. Reference the user's n8n instance
4. Create webhook endpoint documentation
5. Infrastructure from Phase 1 is already in place

Summary should say:
```
✅ n8n პროექტი "{name}" მზადაა!

📁 Workflow-ის შაბლონები: workflows/
🔗 n8n ინსტანცია: aipulsegeorgia2025.app.n8n.cloud

🚀 შემდეგი ნაბიჯი:
   "გადაიტანე ეს workflow ჩემს n8n-ში"
```

## For HYBRID Projects

Create both:
1. Code structure (src/) for the application part
2. Workflows reference (workflows/) for the n8n part
3. Integration documentation (how code calls n8n webhooks and vice versa)

Summary should explain both parts clearly.
