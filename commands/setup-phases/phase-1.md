## Phase 1: Infrastructure Setup (Automatic — No Questions About Tech)

This phase creates the UNIVERSAL infrastructure that every project needs.
No technology questions. No "what should the app do?" yet. Just the foundation.

### Preflight Validation (runs before any file writes)

Before starting Phase 1, verify these external dependencies exist:

```bash
# Check template sources (used in Phase 2 as fallbacks when community scaffolder is unavailable)
TEMPLATES_OK=true
for dir in ~/.claude/archive/bootstrap-templates ~/.claude/rules; do
  if [ ! -d "$dir" ]; then
    # Pre-v0.4 layout fallback
    if [ "$dir" = "$HOME/.claude/archive/bootstrap-templates" ] && [ -d "$HOME/.claude/bootstrap-templates" ]; then
      continue  # legacy path still works
    fi
    TEMPLATES_OK=false
  fi
done
```

If any dependency is missing:
- Do NOT stop the setup — these are only needed in Phase 2
- Note the missing paths in a warning variable
- When Phase 2 reaches a step that needs a missing template, use the fallback: research-first protocol (WebSearch + context7)
- Inform the user: "ზოგიერთი შაბლონი ვერ მოიძებნა. ინტერნეტიდან მოვიძიებ საუკეთესო პრაქტიკებს."

For Phase 1 dependencies (rules files that should be copied from ~/.claude/rules/):
- If source rule files don't exist at ~/.claude/rules/10-testing.md etc., create the rules with inline default content instead of copying
- Never fail silently — always inform the user what happened

---

### Safety Rules for Phase 1

**Git staging safety:** Before any `git add` in EXISTING_PROJECT mode, verify `.gitignore` covers `.env`, `*.pem`, `*.key`, `credentials.json`, and `node_modules/`. If these patterns are missing from `.gitignore`, add them FIRST before staging. Prefer `git add` with specific file names from `PHASE1_CHANGES` over `git add -A` when possible.

**Mid-setup failure recovery:** If any step in Phase 1 fails:
1. STOP immediately. Do NOT continue to the next step.
2. Restore tracked files: `git checkout HEAD -- .`
3. Remove files created by this setup run: iterate PHASE1_CHANGES and `rm` each file that was CREATED (not MERGED)
4. Inform the user in Georgian: "Setup-მ შეცდომა მოხდა. შენი პროექტი დაბრუნდა წინა მდგომარეობაში."
5. If restore fails: "აღდგენა ვერ მოხერხდა. გაუშვი: git stash && git checkout HEAD -- . რომ ხელით აღადგინო."

**Malformed JSON handling:** If any JSON file (settings.json, .mcp.json, extensions.json) fails to parse, rename it to `filename.backup-YYYYMMDD-HHMMSS`, create a fresh file with defaults, and inform the user: "ფაილს ფორმატირების პრობლემა ჰქონდა. ძველი ვერსია backup-ად შევინახე."

### Audit Status → Phase 1 Action Mapping

For every item in EXISTING_PROJECT mode, the action depends on the audit status:

| Audit Status | Action | Example |
|---|---|---|
| ✅ OK | SKIP — do not touch | File exists and is correct |
| ⚠️ INCOMPLETE | COMPLETE — add only what's missing, never overwrite existing content | .gitignore missing some categories → MERGE_APPEND the missing ones |
| ❌ MISSING | CREATE — make the file/directory with default content | .claude/rules/security.md doesn't exist → create it |
| 🔧 MISCONFIGURED | FIX — backup the broken version, create correct one, inform user | settings.json is invalid JSON → backup + recreate |

**IMPORTANT:** SKIP_IF_EXISTS files (LICENSE, CONTRIBUTING.md, SECURITY.md, .editorconfig, README.md, .env.example) are only skipped when their audit status is OK. If audit marked them as INCOMPLETE, add what's missing. If MISCONFIGURED, backup and recreate.

**Exception:** For files where INCOMPLETE criteria is not defined in the audit (like .editorconfig, which is either OK or MISSING), SKIP_IF_EXISTS effectively means "skip if it exists at all" — which is correct since there's nothing to complete.

**CONDITIONAL LOGIC:** Phase 0 has already run and set:
- `PROJECT_MODE` = `NEW_PROJECT` or `EXISTING_PROJECT`
- `DETECTED_STACK` = detected tech stack info or `null`
- `AUDIT_RESULTS` = status of each infrastructure item

---

### 1.1 — Get Project Name

**IF NEW_PROJECT:**
If not in $ARGUMENTS, ask in Georgian:
"პროექტის სახელი? (ინგლისურად, lowercase, მაგ: my-cool-app)"

**IF EXISTING_PROJECT:**
Extract project name from (in priority order):
1. `package.json` → `name` field
2. `pyproject.toml` → `[project].name`
3. `Cargo.toml` → `[package].name`
4. `go.mod` → module name (last segment)
5. Current directory name
Confirm with user: "პროექტის სახელი '{detected_name}' არის? [კი/შევცვალო]"

---

### 1.2 — Validate & Initialize

**Strategy: CONDITIONAL_GIT**

**IF NEW_PROJECT:**
- Check current directory is empty (or has only non-essential files like .DS_Store, logs)
- If not empty, ask: "ფოლდერი ცარიელი არ არის. მაინც აქ შევქმნა? [კი/არა]"
- `git init`
- Create `main` and `develop` branches

**IF EXISTING_PROJECT:**
- If already a git repo → skip `git init`
- If NOT a git repo → run `git init` and inform user: "Git არ იყო ინიციალიზებული, ახლა გავაკეთე."
- If `main` branch exists → skip
- If `main` branch missing but `master` exists → skip (respect existing convention)
- If no main/master branch → create `main`
- If `develop` branch missing → create it from current HEAD
- If `develop` branch exists → skip

---

### 1.3 — Create CLAUDE.md

**Strategy: MERGE_SECTIONS**

**IF NEW_PROJECT:**
Create the full CLAUDE.md:

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

**IF EXISTING_PROJECT:**
1. Read existing CLAUDE.md (if it exists)
2. Define required sections:
   - `## Overview`
   - `## How Claude Should Work With the User`
   - `## Data Safety`
   - `## Security Rules`
   - `## Testing`
   - `## Code Quality`
   - `## Memory & Context`
3. For each required section:
   - If section heading exists (case-insensitive match, also check partial matches like "## Security" matching "## Security Rules") → **leave it untouched**
   - If section is missing → **append it at the end** under the heading with suffix ` (added by /setup)`
4. If CLAUDE.md does not exist at all → create the full version (same as NEW_PROJECT)
5. If DETECTED_STACK is available, update the `## Overview` section ONLY if it still contains the placeholder text "Idea and tech stack will be defined by the user" — replace with detected stack info
6. **Never rewrite or reorder existing content**
7. Track changes in PHASE1_CHANGES

---

### 1.4 — Create .claude/ Directory

**Strategy: CREATE_DIR_IF_MISSING** for the directory itself.
**Strategy: DEEP_MERGE** for settings.json.
**Strategy: CREATE_IF_MISSING** for all other files.

**IF NEW_PROJECT:**

Create `.claude/` directory and all contents:

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

**IF EXISTING_PROJECT:**

1. **`.claude/` directory:** If missing → create it. If exists → skip.

2. **`.claude/settings.json`** — DEEP_MERGE:
   - If file missing → create with full default content (same as NEW_PROJECT)
   - If file exists → read and parse existing JSON, then:
     - `permissions.allow` (array): compute the union — add any items from the default list that are NOT already present. Never remove existing items.
     - `permissions.deny` (array): compute the union — add any items from the default list that are NOT already present. Never remove existing items.
     - `env` (object): for each key in default, add it ONLY if the key does not already exist. Never overwrite existing values.
     - Write back with 2-space JSON indentation.

   Example merge logic:
   ```
   existing.allow = ["git status", "git diff", "npm test"]
   default.allow  = ["git status", "git diff", "git log", "git add", ...]
   result.allow   = ["git status", "git diff", "npm test", "git log", "git add", ...]
                     (union — existing items preserved in original order, new items appended)
   ```

3. **`.claude/settings.local.json`** — CREATE_IF_MISSING:
   - If exists → skip entirely
   - If missing → create with `{ "env": {} }`

4. **All `.claude/rules/*` files** — CREATE_IF_MISSING:
   - If exists → skip (user may have customized)
   - If missing → create with default content

5. Track all changes in PHASE1_CHANGES

---

### 1.5 — Create .github/ Directory

**Strategy: CREATE_DIR_IF_MISSING** for directories.
**Strategy: CREATE_IF_MISSING** for all files.

**IF NEW_PROJECT:**

Create all `.github/` contents:

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

**IF EXISTING_PROJECT:**

For each file, apply CREATE_IF_MISSING:

| File | If exists | If missing |
|------|-----------|------------|
| `.github/workflows/ci.yml` | Skip — user has their own CI | Create placeholder |
| `.github/workflows/security.yml` | Skip | Create generic security workflow |
| `.github/dependabot.yml` | Skip | Create with github-actions ecosystem |
| `.github/CODEOWNERS` | Skip | Create with placeholder or detected username |
| `.github/PULL_REQUEST_TEMPLATE.md` | Skip | Create default template |
| `.github/ISSUE_TEMPLATE/bug_report.md` | Skip | Create default template |
| `.github/ISSUE_TEMPLATE/feature_request.md` | Skip | Create default template |

Track all changes in PHASE1_CHANGES.

---

### 1.6 — Create Project Directories

**Strategy: CREATE_DIR_IF_MISSING**

**IF NEW_PROJECT:**

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

**IF EXISTING_PROJECT:**

1. **`src/` directory:**
   - If exists → skip
   - If missing AND project has source files elsewhere (e.g., `app/`, `lib/`, `pages/`) → skip (respect existing structure)
   - If missing AND no source directory detected → create with .gitkeep

2. **`tests/` directory:**
   - If exists (or `test/`, `__tests__/`, `spec/`) → skip
   - If missing → create `tests/` with `unit/`, `integration/`, `e2e/` subdirectories and .gitkeep files

3. **`docs/` directory:** If exists → skip. If missing → create with .gitkeep

4. **`docs/decisions/` directory:** If exists → skip. If missing → create with .gitkeep

5. **`docs/decisions/001-initial-setup.md`** — CREATE_IF_MISSING:
   - If any file in `docs/decisions/` exists → skip (project already has ADRs)
   - If directory is empty → create `001-initial-setup.md` with "Project enhanced with /setup" content

6. **`docs/architecture.md`** — CREATE_IF_MISSING

7. **`docs/how-to-work-with-claude.md`** — CREATE_IF_MISSING

Track all changes in PHASE1_CHANGES.

---

### 1.7 — Create Root Config Files

**Mixed strategies per file type.**

**IF NEW_PROJECT (including near-empty projects):**

**IMPORTANT for near-empty projects:** Even in NEW_PROJECT mode, before creating each root config file, check if it already exists. If it does, use SKIP_IF_EXISTS (do not overwrite). This protects projects that have only a .gitignore or README.md but are otherwise empty.

Create all root config files:

**`.editorconfig`:**
Universal formatting — indent (2 spaces), charset (utf-8), trailing whitespace (trim), final newline (insert).

**`.gitignore`:**
Comprehensive — covers ALL common stacks preemptively:
- Node: node_modules/, .next/, dist/, out/, coverage/
- Python: __pycache__/, .venv/, *.pyc, .pytest_cache/
- Secrets: .env, .env.*, !.env.example, *.pem, *.key, credentials.json
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

**IF EXISTING_PROJECT:**

| File | Strategy | Behavior |
|------|----------|----------|
| `.editorconfig` | SKIP_IF_EXISTS | If exists → skip. If missing → create. |
| `.gitignore` | MERGE_APPEND | See detailed merge logic below. |
| `.env.example` | SKIP_IF_EXISTS | If exists → skip. If missing → create. |
| `SECURITY.md` | SKIP_IF_EXISTS | If exists → skip. If missing → create. |
| `CONTRIBUTING.md` | SKIP_IF_EXISTS | If exists → skip. If missing → create. |
| `LICENSE` | SKIP_IF_EXISTS | If exists → skip. If missing → create MIT. |
| `README.md` | SKIP_IF_EXISTS | If exists → skip. If missing → create. |

#### .gitignore MERGE_APPEND Logic (detailed):

1. Read existing `.gitignore` content
2. Define expected patterns grouped by category:
   ```
   # Node
   node_modules/
   .next/
   dist/
   out/
   coverage/

   # Python
   __pycache__/
   .venv/
   *.pyc
   .pytest_cache/

   # Secrets
   .env
   .env.*
   !.env.example
   *.pem
   *.key
   credentials.json

   # IDE
   .idea/
   .vscode/*.code-workspace

   # OS
   .DS_Store
   Thumbs.db

   # Build
   build/

   # Logs
   *.log
   logs/
   ```
3. For each pattern, check if it already exists in the file (exact line match, ignoring leading/trailing whitespace)
4. Collect all missing patterns
5. If there are missing patterns:
   - Append a blank line
   - Append comment: `# Added by Claude Code /setup`
   - Append each missing pattern (grouped by category, with category comments)
6. If no patterns are missing → do not modify the file

Track all changes in PHASE1_CHANGES.

---

### 1.8 — Create IDE Configuration

**Strategy: DEEP_MERGE** for JSON files.

**IF NEW_PROJECT:**

**`.vscode/extensions.json`:**
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

**IF EXISTING_PROJECT:**

1. **`.vscode/settings.json`** — DEEP_MERGE:
   - If file missing → create with full default content
   - If file exists → add only missing keys, never overwrite existing values

2. **`.vscode/extensions.json`** — DEEP_MERGE:
   - If file missing → create with default recommendations
   - If file exists → add `"anthropic.claude-code"` to recommendations only if not already present

---

### 1.9 — Create .mcp.json

**Strategy: DEEP_MERGE (if valid JSON) / BACKUP_AND_RECREATE (if invalid)**

**IF NEW_PROJECT:**
```json
{ "mcpServers": {} }
```

**IF EXISTING_PROJECT:**
- If `.mcp.json` missing → create with `{ "mcpServers": {} }`
- If `.mcp.json` exists and is valid JSON → DEEP_MERGE: add missing keys from default without overwriting existing mcpServers. In practice, the default is empty so this is usually a no-op. Leave user's servers untouched.
- If `.mcp.json` exists but is invalid JSON → backup as `.mcp.json.backup-YYYYMMDD-HHMMSS`, create fresh with `{ "mcpServers": {} }`, inform user: ".mcp.json ფორმატირების პრობლემა ჰქონდა. backup შევინახე."

---

### 1.10 — Create Handoff Template

**Strategy: CREATE_IF_MISSING**

**IF NEW_PROJECT:**
Create **`.claude/handoff-template.md`:**
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

**IF EXISTING_PROJECT:**
- If `.claude/handoff-template.md` exists → skip
- If missing → create with default content

---

### 1.11 — Commit

**Strategy: CONDITIONAL_GIT**

**IF NEW_PROJECT:**
```bash
git add -A  # Safe because this is a new empty project with no pre-existing files
git commit -m "feat: initial project infrastructure with Claude Code /setup

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

**IF EXISTING_PROJECT:**

1. Check if there are any changes to commit: `git status --porcelain`
2. If no changes → skip commit, inform user: "ყველაფერი უკვე ადგილზე იყო, ცვლილება არ დასჭირდა."
3. If there ARE changes:
   ```bash
   # Stage only files created/modified by /setup (from PHASE1_CHANGES list)
   # NEVER use git add -A on existing projects
   git add [each file from PHASE1_CHANGES]
   git commit -m "feat: enhance project infrastructure with Claude Code /setup

   Added missing infrastructure files and merged configurations.
   Existing files and settings were preserved.

   Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
   ```

---

### 1.12 — Show Summary

**IF NEW_PROJECT:**

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

**IF EXISTING_PROJECT:**

```
✅ პროექტი "{name}" — ინფრასტრუქტურა განახლდა!

📊 შედეგი:
   ✅ შეიქმნა ({created_count}):
      {list each created file}

   🔄 განახლდა ({merged_count}):
      {list each merged file with what was added}

   ⏭️ უკვე ადგილზე იყო ({skipped_count}):
      {list each skipped file}

🛡️ დაცვის სტატუსი:
   ✅ .claude/rules/ — {X of Y} წესი ადგილზეა
   ✅ .github/ — CI/CD + security scanning + PR/issue შაბლონები
   ✅ .gitignore — secrets და build ფაილები დაცულია

📝 შემდეგი ნაბიჯი:
   შენი პროექტი უკვე არსებობს, ამიტომ:
   - უთხარი Claude-ს რა გინდა დაამატო ან შეცვალო
   - ან აღწერე ახალი ფიჩერი რომლის დამატებაც გინდა

🆘 თუ რამე გაფუჭდა:
   - "გააუქმე ბოლო ცვლილება"
   - "რაღაც გაფუჭდა, გაასწორე"
   - "დააბრუნე ბოლო მომუშავე ვერსია"
```

If nothing was created or merged:
```
✅ პროექტი "{name}" — ყველაფერი უკვე ადგილზეა!

შენს პროექტს უკვე აქვს სრული ინფრასტრუქტურა.
ცვლილება არ დასჭირდა.

📝 შემდეგი ნაბიჯი:
   უთხარი Claude-ს რა გინდა ააწყო ან შეცვალო.
```

---
