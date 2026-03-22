---
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent, TodoWrite, WebFetch, WebSearch
description: Bootstrap a complete Claude Code project with professional infrastructure — security, CI/CD, GitHub templates, rules, testing, and all configurations. Works on BOTH new empty projects and existing projects.
argument-hint: [optional: project-name]
---

# Bootstrap Complete Claude Code Project (New & Existing)

Create a production-grade project infrastructure with everything configured from day one.
Works in TWO modes:
- **NEW_PROJECT**: Empty directory → full setup from scratch
- **EXISTING_PROJECT**: Existing codebase → audit, fix what's missing, merge what's incomplete

Target user: someone who writes PROMPTS to Claude Code, NOT code themselves.

**Project name hint:** $ARGUMENTS

---

## Phase 0: Project Analysis (Runs FIRST — Before Everything Else)

This phase determines whether we are setting up a NEW empty project or augmenting an EXISTING project.
It runs automatically before Phase 1 and controls what happens next.

---

### 0.1 — Detect Project Mode

Check the current directory to determine the mode:

```bash
# Count real files (exclude .DS_Store, .git/, logs/, .gitkeep)
REAL_FILES=$(find . -maxdepth 2 -not -path './.git/*' -not -name '.DS_Store' -not -name '.gitkeep' -not -path './logs/*' -not -name '.' -type f | wc -l)
```

**Decision logic:**

| Condition | Mode | Action |
|-----------|------|--------|
| REAL_FILES = 0 | `NEW_PROJECT` | Skip to Phase 0.5 (set variables) → then Phase 1 |
| REAL_FILES = 1-2 AND only config files (.gitignore, LICENSE, README.md) | `NEW_PROJECT` | Treat as near-empty — skip to Phase 0.5 → Phase 1. Note: existing config files will be preserved via SKIP_IF_EXISTS in Phase 1. |
| REAL_FILES > 0 (with source code or meaningful content) | `EXISTING_PROJECT` | Run comprehensive audit (0.2 → 0.3 → 0.4 → 0.5) |

If `NEW_PROJECT`: print "ახალი პროექტის რეჟიმი — ინფრასტრუქტურა ნულიდან შეიქმნება." Set `PROJECT_MODE = "NEW_PROJECT"`, `DETECTED_STACK = all null`, `AUDIT_RESULTS = all "MISSING"`, `PHASE1_CHANGES = []`. Proceed to Phase 1.

If `EXISTING_PROJECT`: print "არსებული პროექტი ნაპოვნია — ვაანალიზებ რა არსებობს და რა აკლია..." and continue below.

---

### 0.2 — Comprehensive Audit (EXISTING_PROJECT only)

Check EVERY item that `/setup` would create. For each item, assign one of four statuses:

| Status | Meaning | Symbol |
|--------|---------|--------|
| OK | Exists and correct | ✅ |
| INCOMPLETE | Exists but missing important parts | ⚠️ |
| MISSING | Should exist but does not | ❌ |
| MISCONFIGURED | Exists but has problems | 🔧 |

Run all audit categories below. Store results internally for the report.

---

#### Category A: Git Status

| Check | How to evaluate |
|-------|----------------|
| Git initialized | `.git/` directory exists |
| Has commits | `git log --oneline -1` succeeds |
| `main`/`master` branch | `git branch --list main` OR `git branch --list master` returns output. Accept either convention — mark as OK if either exists. |
| `develop` branch | `git branch --list develop` returns output |

---

#### Category B: Claude Config (.claude/)

| Check | Path | OK criteria |
|-------|------|-------------|
| .claude/ directory | `.claude/` | Directory exists |
| settings.json | `.claude/settings.json` | File exists AND contains `permissions` object with both `allow` (array) and `deny` (array) keys |
| settings.local.json | `.claude/settings.local.json` | File exists |
| rules/ directory | `.claude/rules/` | Directory exists |
| interaction.md | `.claude/rules/interaction.md` | File exists and is not empty |
| security.md | `.claude/rules/security.md` | File exists and is not empty |
| quality.md | `.claude/rules/quality.md` | File exists and is not empty |
| testing.md | `.claude/rules/testing.md` | File exists and is not empty |
| ui-verification.md | `.claude/rules/ui-verification.md` | File exists and is not empty |
| memory.md | `.claude/rules/memory.md` | File exists and is not empty |
| handoff-template.md | `.claude/handoff-template.md` | File exists and is not empty |

**INCOMPLETE criteria for settings.json:**
- File exists but `permissions.allow` is missing or empty → ⚠️ INCOMPLETE
- File exists but `permissions.deny` is missing or empty → ⚠️ INCOMPLETE
- File exists but `permissions` key is entirely absent → 🔧 MISCONFIGURED
- File exists but is NOT valid JSON (parse error) → 🔧 MISCONFIGURED. Recovery: backup as `settings.json.backup-YYYYMMDD-HHMMSS`, create fresh file with defaults, inform user: "settings.json-ს ფორმატირების პრობლემა ჰქონდა. ძველი ვერსია შევინახე backup-ად და ახალი შევქმენი."

---

#### Category C: GitHub (.github/)

| Check | Path | OK criteria |
|-------|------|-------------|
| .github/ directory | `.github/` | Directory exists |
| CI workflow | `.github/workflows/ci.yml` | File exists and contains `on:` trigger |
| Security workflow | `.github/workflows/security.yml` | File exists |
| Dependabot | `.github/dependabot.yml` | File exists and contains `updates:` key |
| CODEOWNERS | `.github/CODEOWNERS` | File exists and is not empty |
| PR template | `.github/PULL_REQUEST_TEMPLATE.md` | File exists and is not empty |
| Bug report template | `.github/ISSUE_TEMPLATE/bug_report.md` | File exists and is not empty |
| Feature request template | `.github/ISSUE_TEMPLATE/feature_request.md` | File exists and is not empty |

---

#### Category D: Root Config Files

| Check | Path | OK criteria | INCOMPLETE criteria |
|-------|------|-------------|---------------------|
| CLAUDE.md | `CLAUDE.md` | File exists and has >10 lines of content | Exists but <10 lines or missing key sections (Overview, Security, Testing) |
| .gitignore | `.gitignore` | File exists AND covers: Node (`node_modules`), Python (`__pycache__`), secrets (`.env`), IDE (`.idea`), OS (`.DS_Store`) — 3+ of 5 categories present | Exists but missing 2+ categories |
| .editorconfig | `.editorconfig` | File exists | — |
| .env.example | `.env.example` | File exists | — |
| SECURITY.md | `SECURITY.md` | File exists and is not empty | — |
| CONTRIBUTING.md | `CONTRIBUTING.md` | File exists and is not empty | — |
| LICENSE | `LICENSE` | File exists and is not empty | — |
| README.md | `README.md` | File exists and has >5 lines | Exists but <5 lines |
| .mcp.json | `.mcp.json` | File exists and is valid JSON | Exists but invalid JSON → 🔧 |

**.gitignore completeness check:**

Check for these 5 categories. If 3+ are present → OK. If 1-2 present → INCOMPLETE. If 0 → MISSING.

```bash
NODE=$(grep -c 'node_modules' .gitignore 2>/dev/null)
PYTHON=$(grep -c '__pycache__\|\.pyc\|\.venv' .gitignore 2>/dev/null)
SECRETS=$(grep -c '\.env' .gitignore 2>/dev/null)
IDE=$(grep -c '\.idea\|\.vscode' .gitignore 2>/dev/null)
OS=$(grep -c '\.DS_Store\|Thumbs' .gitignore 2>/dev/null)
TOTAL=$((($NODE > 0) + ($PYTHON > 0) + ($SECRETS > 0) + ($IDE > 0) + ($OS > 0)))
```

---

#### Category E: Project Structure

| Check | Path | OK criteria |
|-------|------|-------------|
| Source directory | `src/` (or language equivalent — see 0.2G) | Directory exists with at least 1 source file |
| Tests directory | `tests/` OR `test/` OR `__tests__/` OR `spec/` | Any of these directories exists → OK |
| Tests: unit | `tests/unit/` OR `test/unit/` OR `__tests__/unit/` OR `spec/unit/` | Any of these subdirectories exists → OK |
| Tests: integration | `tests/integration/` OR `test/integration/` OR `__tests__/integration/` OR `spec/integration/` | Any of these subdirectories exists → OK |
| Tests: e2e | `tests/e2e/` OR `test/e2e/` OR `__tests__/e2e/` OR `spec/e2e/` | Any of these subdirectories exists → OK |
| Docs directory | `docs/` | Directory exists |
| Decisions directory | `docs/decisions/` | Directory exists |
| Architecture doc | `docs/architecture.md` | File exists and is not empty |
| Claude guide | `docs/how-to-work-with-claude.md` | File exists and is not empty |

**Language-equivalent source directories:**
- If `package.json` exists → accept `src/`, `app/`, `pages/`, `components/` as source dir
- If `pyproject.toml` or `setup.py` exists → accept `src/`, project-named dir
- If `go.mod` exists → accept `cmd/`, `internal/`, `pkg/`
- If `Cargo.toml` exists → accept `src/`

If the project uses a non-standard structure but clearly has organized source code, mark as ✅ OK.

---

#### Category F: IDE Config

| Check | Path | OK criteria |
|-------|------|-------------|
| VS Code extensions | `.vscode/extensions.json` | File exists and is valid JSON |
| VS Code settings | `.vscode/settings.json` | File exists and is valid JSON |

---

#### Category G: Tech Stack Detection

Detect what already exists. Do NOT ask the user — detect from files.

```
Detection rules (check in order, stop at first match per category):

LANGUAGE:
  package.json                         → Node.js / JavaScript
  tsconfig.json                        → TypeScript (refines Node.js)
  pyproject.toml / setup.py / requirements.txt → Python
  go.mod                               → Go
  Cargo.toml                           → Rust
  composer.json                        → PHP
  Gemfile                              → Ruby

FRAMEWORK (check inside package.json dependencies/devDependencies):
  "next"                               → Next.js
  "react" (without next)               → React (CRA or Vite)
  "vue"                                → Vue.js
  "nuxt"                               → Nuxt.js
  "svelte" / "sveltekit"               → SvelteKit
  "express"                            → Express.js
  "fastify"                            → Fastify
  "hono"                               → Hono
  "astro"                              → Astro

FRAMEWORK (check inside pyproject.toml / requirements.txt):
  "fastapi"                            → FastAPI
  "django"                             → Django
  "flask"                              → Flask

DATABASE:
  prisma/schema.prisma                 → Prisma ORM (check provider for DB type)
  drizzle.config.*                     → Drizzle ORM
  "supabase" in dependencies           → Supabase (PostgreSQL)
  "mongoose" / "mongodb" in deps       → MongoDB
  "pg" / "postgres" in deps            → PostgreSQL
  "mysql2" / "mysql" in deps           → MySQL
  "better-sqlite3" / "sqlite3" in deps → SQLite

PACKAGE MANAGER:
  pnpm-lock.yaml                       → pnpm
  yarn.lock                            → yarn
  bun.lockb                            → bun
  package-lock.json                    → npm
  Pipfile.lock                         → pipenv
  poetry.lock                          → poetry
  uv.lock                              → uv

PROJECT APPROACH:
  workflows/ directory with .json      → N8N (or HYBRID if code also exists)
  n8n config references                → N8N
  Code + workflows                     → HYBRID
  Code only                            → CODE
```

Save detected stack as:
```
DETECTED_STACK = {
  language: "TypeScript" | "Python" | "Go" | "Rust" | "PHP" | "Ruby" | null,
  framework: "Next.js" | "FastAPI" | "Django" | ... | null,
  database: "PostgreSQL" | "MongoDB" | "SQLite" | ... | null,
  packageManager: "npm" | "pnpm" | "yarn" | "pip" | "poetry" | ... | null,
  projectApproach: "CODE" | "N8N" | "HYBRID" | null
}
```

This is used in Phase 2 to skip technology selection if a stack already exists.

---

### 0.3 — Generate Audit Report

After all checks complete, count totals and present in Georgian.

**Template:**

```
🔍 პროექტის ანალიზი:

📊 შედეგი:
   ✅ OK: {ok_count} — უკვე სწორად არსებობს
   ⚠️ არასრული: {incomplete_count} — არსებობს, მაგრამ რაღაც აკლია
   ❌ აკლია: {missing_count} — არ არსებობს, შესაქმნელია
   🔧 გასასწორებელი: {misconfigured_count} — არსებობს, მაგრამ პრობლემა აქვს

🔧 აღმოჩენილი ტექნოლოგიები:
   ენა: {language or "ვერ დადგინდა"}
   ფრეიმვორკი: {framework or "ვერ დადგინდა"}
   მონაცემთა ბაზა: {database or "არ არის"}
   პაკეტ მენეჯერი: {packageManager or "ვერ დადგინდა"}

📋 დეტალები:

🔹 Git:
   {✅|⚠️|❌|🔧} Git ინიციალიზებულია
   {✅|⚠️|❌|🔧} კომიტების ისტორია
   {✅|⚠️|❌|🔧} main branch
   {✅|⚠️|❌|🔧} develop branch

🔹 Claude კონფიგურაცია (.claude/):
   {✅|⚠️|❌|🔧} .claude/ საქაღალდე
   {✅|⚠️|❌|🔧} settings.json
   {✅|⚠️|❌|🔧} settings.local.json
   {✅|⚠️|❌|🔧} rules/ საქაღალდე
   {✅|⚠️|❌|🔧} rules/interaction.md
   {✅|⚠️|❌|🔧} rules/security.md
   {✅|⚠️|❌|🔧} rules/quality.md
   {✅|⚠️|❌|🔧} rules/testing.md
   {✅|⚠️|❌|🔧} rules/ui-verification.md
   {✅|⚠️|❌|🔧} rules/memory.md
   {✅|⚠️|❌|🔧} handoff-template.md

🔹 GitHub (.github/):
   {✅|⚠️|❌|🔧} .github/ საქაღალდე
   {✅|⚠️|❌|🔧} workflows/ci.yml
   {✅|⚠️|❌|🔧} workflows/security.yml
   {✅|⚠️|❌|🔧} dependabot.yml
   {✅|⚠️|❌|🔧} CODEOWNERS
   {✅|⚠️|❌|🔧} PULL_REQUEST_TEMPLATE.md
   {✅|⚠️|❌|🔧} ISSUE_TEMPLATE/bug_report.md
   {✅|⚠️|❌|🔧} ISSUE_TEMPLATE/feature_request.md

🔹 Root კონფიგურაცია:
   {✅|⚠️|❌|🔧} CLAUDE.md
   {✅|⚠️|❌|🔧} .gitignore (სისრულე: {categories_found}/5)
   {✅|⚠️|❌|🔧} .editorconfig
   {✅|⚠️|❌|🔧} .env.example
   {✅|⚠️|❌|🔧} SECURITY.md
   {✅|⚠️|❌|🔧} CONTRIBUTING.md
   {✅|⚠️|❌|🔧} LICENSE
   {✅|⚠️|❌|🔧} README.md
   {✅|⚠️|❌|🔧} .mcp.json

🔹 პროექტის სტრუქტურა:
   {✅|⚠️|❌|🔧} წყაროს კოდის საქაღალდე ({detected_src_dir})
   {✅|⚠️|❌|🔧} tests/
   {✅|⚠️|❌|🔧} tests/unit/
   {✅|⚠️|❌|🔧} tests/integration/
   {✅|⚠️|❌|🔧} tests/e2e/
   {✅|⚠️|❌|🔧} docs/
   {✅|⚠️|❌|🔧} docs/decisions/
   {✅|⚠️|❌|🔧} docs/architecture.md
   {✅|⚠️|❌|🔧} docs/how-to-work-with-claude.md

🔹 IDE კონფიგურაცია:
   {✅|⚠️|❌|🔧} .vscode/extensions.json
   {✅|⚠️|❌|🔧} .vscode/settings.json

🛠️ რას გავაკეთებ:
   - {list each MISSING item: "შევქმნი X"}
   - {list each INCOMPLETE item: "დავამატებ Y-ს რაც აკლია"}
   - {list each MISCONFIGURED item: "გავასწორებ Z-ს"}
   - ⚠️ არსებული ფაილები არ გადაიწერება
   - ⚠️ მხოლოდ რაც აკლია, ის დაემატება
   - ⚠️ შენი კოდი უცვლელი დარჩება
```

**If everything is OK (all items ✅):**

```
🔍 პროექტის ანალიზი:

✅ ყველაფერი წესრიგშია! პროექტს სრული ინფრასტრუქტურა აქვს.

არაფერი საკეთებელია. თუ რამე კონკრეტული გინდა შეცვალო, მითხარი.
```

Skip Phases 1-2 entirely in this case.

---

### 0.4 — User Confirmation

After showing the report, ask:

```
გავაგრძელო?
   → [კი] — აკლია რაც აკლია, ის შეიქმნება
   → [არა] — არაფერი შეიცვლება
   → [მეტი დეტალი მინდა] — ყველა ფაილის გეგმას გაჩვენებ
```

**If user says "კი" or equivalent:**
Proceed to Phase 1 in EXISTING mode.

**If user says "არა" or equivalent:**
Stop completely. Print: "კარგი, არაფერი შეიცვლება. თუ მოგვიანებით გინდა, თავიდან გაუშვი /setup."

**If user says "მეტი დეტალი" or equivalent:**
Show the file-by-file plan. For each non-OK item, show:

```
📄 {file path}
   სტატუსი: {❌ აკლია | ⚠️ არასრული | 🔧 გასასწორებელი}
   რას გავაკეთებ: {specific action}
   შიგთავსი: {1-2 sentence summary of what the file will contain}
```

After showing details, ask again: "გავაგრძელო? [კი / არა]"

---

### 0.5 — Set Mode Variables (Internal — Not Shown to User)

After user confirms, Claude mentally tracks these variables for all subsequent phases:

```
PROJECT_MODE = "NEW_PROJECT" | "EXISTING_PROJECT"

DETECTED_STACK = {
  language: string | null,
  framework: string | null,
  database: string | null,
  packageManager: string | null,
  projectApproach: "CODE" | "N8N" | "HYBRID" | null
}

AUDIT_RESULTS = {
  // For each audited item: "OK" | "INCOMPLETE" | "MISSING" | "MISCONFIGURED"
  "git.initialized", "git.hasCommits", "git.mainBranch", "git.developBranch",
  "claude.directory", "claude.settings", "claude.settingsLocal", "claude.rules",
  "claude.rules.interaction", "claude.rules.security", "claude.rules.quality",
  "claude.rules.testing", "claude.rules.uiVerification", "claude.rules.memory",
  "claude.handoffTemplate",
  "github.directory", "github.ci", "github.security", "github.dependabot",
  "github.codeowners", "github.prTemplate", "github.bugReport", "github.featureRequest",
  "root.claudeMd", "root.gitignore", "root.editorconfig", "root.envExample",
  "root.securityMd", "root.contributingMd", "root.license", "root.readmeMd", "root.mcpJson",
  "structure.src", "structure.tests", "structure.testsUnit",
  "structure.testsIntegration", "structure.testsE2e",
  "structure.docs", "structure.decisions", "structure.architectureMd", "structure.claudeGuideMd",
  "ide.extensions", "ide.settings"
}

PHASE1_CHANGES = [] // List of changes made in Phase 1, for Phase 2 summary
```

**How these variables affect Phase 1:**

In EXISTING_PROJECT mode, Phase 1 MUST:
1. **SKIP** every step where AUDIT_RESULTS shows "OK" — do not touch those files
2. **COMPLETE** every item marked "INCOMPLETE" — add missing parts without overwriting existing content
3. **CREATE** every item marked "MISSING" — use the same templates as NEW_PROJECT mode
4. **FIX** every item marked "MISCONFIGURED" — correct the problem while preserving user's existing content
5. **NEVER overwrite** an existing file that the user created — merge/append only
6. **NEVER delete** anything from the existing project
7. **Track** every change in PHASE1_CHANGES for the summary

**Special case — git handling in EXISTING mode:**

- If `git.initialized` is "MISSING": run `git init` as normal
- If `git.initialized` is "OK" AND `git.hasCommits` is "MISSING": skip checkpoint creation (nothing to checkpoint), proceed normally
- If `git.initialized` is "OK" AND `git.hasCommits` is "OK": create a CHECKPOINT before making any changes
  ```bash
  git add -u && git commit -m "CHECKPOINT: Before /setup — saving current state

  What was done: Automatic save before running /setup on existing project
  Files changed: all current files
  Status: WORKING

  Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
  ```
- If `git.developBranch` is "MISSING" and `git.mainBranch` is "OK": create develop from main
  ```bash
  git branch develop
  ```

---

## Phase 1: Infrastructure Setup (Automatic — No Questions About Tech)

This phase creates the UNIVERSAL infrastructure that every project needs.
No technology questions. No "what should the app do?" yet. Just the foundation.

### Preflight Validation (runs before any file writes)

Before starting Phase 1, verify these external dependencies exist:

```bash
# Check template sources (used in Phase 2)
TEMPLATES_OK=true
for dir in ~/.claude/bootstrap-templates ~/.claude/rules; do
  if [ ! -d "$dir" ]; then
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

## Phase 2: Idea Definition & Technology Selection

This phase starts when the user describes what they want to build.
It happens AFTER infrastructure is ready, in a natural conversation flow.

**Phase 0/1 provide these variables:**
- `PROJECT_MODE`: `NEW_PROJECT` | `EXISTING_PROJECT`
- `DETECTED_STACK`: object with `language`, `framework`, `database`, `packageManager`, `projectApproach`
- `PHASE1_CHANGES`: list of what Phase 1 added/fixed

---

### 2.1 — Wait for User's Idea

**IF NEW_PROJECT:**
Do NOT ask proactively. Wait for the user to describe their idea.
When they do, proceed to 2.2 Signal Detection.

**IF EXISTING_PROJECT with DETECTED_STACK (at least `language` is not null):**
Skip 2.1–2.5 entirely. Jump directly to **2.6-E (Existing Project Confirmation)**.

**IF EXISTING_PROJECT without clear DETECTED_STACK (language is null):**
Ask in Georgian:
"პროექტი ვიპოვე, მაგრამ ტექნოლოგიები ვერ ამოვიცანი. რა ენა/ფრეიმვორკი იყენებ?"
Then proceed to 2.6-E with user-provided info.

---

### 2.2 — Signal Detection (internal — do not show to user)

> **EXISTING_PROJECT: skip this step entirely.**

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

---

### 2.3 — Follow-up Questions (Georgian)

> **EXISTING_PROJECT: skip this step entirely.**

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

---

### 2.4 — Tech Selection Mode

> **EXISTING_PROJECT: skip this step entirely. Tech stack is already detected or user-provided.**

"Claude-მ თავად აირჩიოს საუკეთესო ტექნოლოგიები, თუ შენ გინდა არჩევა?"
→ [Claude აირჩიოს] ← default, recommended for non-coders
→ [მე ავირჩევ] → show tech stack menu

**IF user picks "მე ავირჩევ":**

Show this menu in Georgian:

```
აირჩიე ტექნოლოგიები:

📋 პროგრამული ენა:
  1. JavaScript / TypeScript
  2. Python
  3. Go
  4. სხვა (ჩაწერე)

🧱 ფრეიმვორკი:
  [Based on language choice:]
  JS/TS: 1. Next.js  2. React  3. Express  4. Hono  5. Astro  6. არცერთი
  Python: 1. FastAPI  2. Django  3. Flask  4. არცერთი
  Go: 1. Standard library  2. Gin  3. Echo  4. არცერთი

🗄️ მონაცემთა ბაზა:
  1. Supabase (PostgreSQL)
  2. MongoDB
  3. SQLite
  4. MySQL/PostgreSQL (self-hosted)
  5. არ მჭირდება

🚀 დეპლოიმენტი:
  1. Vercel
  2. Railway
  3. Cloudflare
  4. Docker (self-hosted)
  5. ჯერ არ ვიცი

⚙️ მიდგომა:
  1. მხოლოდ კოდი
  2. მხოლოდ n8n
  3. შერეული (კოდი + n8n)
```

Store selections in DETECTED_STACK with the same field names used by auto-detection.
Proceed to 2.6-N confirmation with user's choices.

---

### 2.5 — Auto-Selection Matrix (when user picks "Claude აირჩიოს")

> **EXISTING_PROJECT: skip this step entirely.**

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

---

### 2.6 — Confirmation (MANDATORY — never skip)

There are TWO variants of this step.

---

#### 2.6-N — Confirmation for NEW_PROJECT

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

---

#### 2.6-E — Confirmation for EXISTING_PROJECT

Present what was detected and what Phase 1 already did. Speak in Georgian.

**Template:**

```
შენს პროექტში ვიპოვე:

💻 პროგრამული ენა: [DETECTED_STACK.language or "ვერ ვიპოვე"]
🧱 ფრეიმვორკი: [DETECTED_STACK.framework or "ვერ ვიპოვე"]
🗄️ მონაცემთა ბაზა: [DETECTED_STACK.database or "ვერ ვიპოვე"]
📦 პაკეტ-მენეჯერი: [DETECTED_STACK.packageManager or "ვერ ვიპოვე"]
⚙️ მიდგომა: [DETECTED_STACK.projectApproach — კოდი / n8n / შერეული]

ინფრასტრუქტურის გაუმჯობესება (Phase 1):
  - ✅ [what was added in PHASE1_CHANGES]

გინდა რამე დავამატო ან შევცვალო?
  → [კი, ყველაფერი სწორია]
  → [რამე შევცვალო]
  → [მეტი ახსნა მინდა]
```

**IF user says "რამე შევცვალო":**
Let them correct any detected values. Update DETECTED_STACK accordingly, then re-present 2.6-E.

---

### 2.7 — Build (after user confirms)

Use TodoWrite to track all tasks. Mark each done as completed.

**Consent Rule for Phase 2.7:** No dependencies may be installed and no system-level tools (husky, pre-commit) may be configured without explicit user consent, regardless of NEW_PROJECT or EXISTING_PROJECT mode. Always ask first, then act.

**IMPORTANT:** Every sub-step has TWO paths. The EXISTING_PROJECT path is NON-DESTRUCTIVE: it merges, adds missing pieces, and never overwrites.

---

#### 2.7.1 — Update CLAUDE.md

**IF NEW_PROJECT:**
Add the chosen tech stack, architecture details, and project-specific rules.

**IF EXISTING_PROJECT:**
MERGE with existing CLAUDE.md — never overwrite.
1. Read the existing CLAUDE.md fully.
2. ADD only missing sections (Tech Stack, Build/Run Commands, Testing Commands).
3. UPDATE sections only if they contain placeholder text ("TODO", "TBD", empty sections).
4. NEVER modify sections that contain real user-written content.

---

#### 2.7.2 — Update .claude/settings.json

**IF NEW_PROJECT:**
Add stack-specific allowed commands:
```json
"{package-manager} test",
"{package-manager} run lint",
"{package-manager} run build",
"{package-manager} run dev"
```

**IF EXISTING_PROJECT:**
DEEP_MERGE — add stack-specific commands ONLY if not already present. NEVER remove existing entries.

**IMPORTANT:** Phase 1 may have already modified this file. Read the CURRENT file from disk (post-Phase-1 version), not the original. This builds on top of what Phase 1 wrote.

---

#### 2.7.3 — Stack-Specific Config Files

**IF NEW_PROJECT:**
**IF a pre-built template exists** (in ~/.claude/bootstrap-templates/):
Copy and adapt the template.

Available templates: nextjs-webapp, ai-agent, fastapi-backend, express-backend, telegram-bot, n8n-workflow, hybrid-code-n8n

**IF NO pre-built template exists:**
Follow MANDATORY research-first protocol:
1. Use WebSearch for "[framework/type] project structure best practices 2025 2026"
2. Use `context7` MCP for up-to-date documentation
3. Read at least 2-3 authoritative sources
4. Create structure based on research
5. Write working starter code (entry point + health check)
6. Verify it works (install → build → run → check)

**IMPORTANT:** Never generate source code from memory alone for unfamiliar project types.

**Note:** If this step requires installing dependencies, defer to step 2.7.8 for permission. Do NOT install anything in this step — only create config files.

**IF EXISTING_PROJECT:**

| Config file | Action if EXISTS | Action if MISSING |
|---|---|---|
| `tsconfig.json` / `jsconfig.json` | SKIP | Create with stack defaults |
| `.eslintrc.*` / `eslint.config.*` | SKIP | Create with stack defaults |
| `.prettierrc.*` | SKIP | Create with stack defaults |
| `pytest.ini` / `pyproject.toml` [tool.pytest] | SKIP | Add pytest config |
| `Dockerfile` | SKIP | Do NOT create (ask first) |
| `docker-compose.yml` | SKIP | Do NOT create (ask first) |
| `.env.example` | DEEP_MERGE — add missing vars | Create with stack placeholders |

---

#### 2.7.4 — Security Libraries

**IF NEW_PROJECT:**
Present the security packages that will be added and ask for confirmation before installing, even in NEW_PROJECT mode:
- **Node.js (Express):** helmet, express-rate-limit, cors
- **Node.js (Next.js):** configure built-in security headers in next.config.js
- **Python:** python-dotenv, pydantic

**IF EXISTING_PROJECT:**
1. Read dependency manifest
2. Compare against recommended security packages
3. If missing packages, ASK before installing:
```
ეს უსაფრთხოების ბიბლიოთეკები აკლია შენს პროექტს:
  - [package1]: [plain-language what it does]
  - [package2]: [plain-language what it does]

დავაყენო? [კი / არა / მეტი ახსნა მინდა]
```
Only install if the user confirms.

---

#### 2.7.5 — CI/CD

**IF NEW_PROJECT:**
Replace placeholder ci.yml with stack-specific pipeline from ~/Projects/github-actions-templates/

**IF EXISTING_PROJECT:**
- If workflows exist and cover CI + security → SKIP
- If specific workflows missing → ASK to add them
- If no workflows exist → create stack-specific pipelines

---

#### 2.7.6 — .vscode/

**IF NEW_PROJECT:**
Add stack-specific extensions and settings from ~/.claude/bootstrap/vscode/

**IF EXISTING_PROJECT:**
DEEP_MERGE — add missing stack-specific settings and extensions without overwriting existing preferences.

---

#### 2.7.7 — Source Code

**IF NEW_PROJECT:**
- Working entry point (not empty placeholders)
- /health endpoint or equivalent
- Basic middleware/setup placeholders
- At least 1 passing test

**IF EXISTING_PROJECT:**
- NEVER create src/ structure if code already exists
- NEVER add starter/boilerplate code
- NEVER move or reorganize existing files
- The ONLY allowed addition: offer a `/health` endpoint if it's an API project without one

---

#### 2.7.8 — Dependencies

**IF NEW_PROJECT:**
Ask: "დამოკიდებულებები დავაყენო?"
Only install if confirmed. After install: run audit.

**IF EXISTING_PROJECT:**
1. Check what's already installed
2. Suggest only MISSING dev dependencies (test framework, linter, formatter)
3. Present grouped with descriptions
4. Only install what the user selects

---

#### 2.7.9 — Pre-commit Hooks

**IF NEW_PROJECT:**
Ask before setting up hooks: 'Pre-commit hooks დავაყენო? ეს ავტომატურად ამოწმებს კოდს commit-ის წინ. [კი / არა]'
If confirmed:
Node.js: `npx husky init` + lint-staged
Python: `pre-commit install`

**IF EXISTING_PROJECT:**
- If hooks already configured (.husky/, .pre-commit-config.yaml, lefthook.yml) → SKIP
- If NOT configured → ASK to set up

---

#### 2.7.10 — Documentation

**IF NEW_PROJECT:**
- Update architecture.md with actual architecture
- Update README.md with badges, commands, structure
- Create ADR: 002-tech-stack-choice.md

**IF EXISTING_PROJECT:**
- NEVER overwrite existing docs
- Add `docs/decisions/002-tech-stack-confirmed.md` only if no tech stack ADR exists
- Do NOT create architecture.md or README.md for existing projects

---

#### 2.7.11 — Commit

**IF NEW_PROJECT:**
```bash
git add -A  # Safe because this is a new empty project with no pre-existing files
git commit -m "feat: add {tech-stack} application structure

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

**IF EXISTING_PROJECT:**
```bash
# Stage only files created/modified by /setup (from PHASE1_CHANGES + Phase 2 changes)
# NEVER use git add -A on existing projects
git add [each file from PHASE1_CHANGES and Phase 2 changes]
git commit -m "CHECKPOINT: enhance {tech-stack} project configuration

What was done: Claude Code setup added infrastructure improvements and missing tooling
Files changed: [list only new/modified files]
Status: WORKING

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

---

### 2.8 — Post-Build Summary

#### 2.8-N — Post-Build Summary for NEW_PROJECT (Georgian)

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

#### 2.8-E — Post-Build Summary for EXISTING_PROJECT (Georgian)

```
✅ პროექტი "{name}" გაძლიერებულია!

📋 რა დაემატა:
   [list of new files/configs created]

🔄 რა განახლდა:
   [list of files that were merged/enhanced]

⏭️ რა არ შეცვლილა:
   [list of user's existing files that were preserved]

🛡️ დაცვა:
   ✅ [security items added]

🚀 როგორ გააგრძელო მუშაობა:
   ყველაფერი ისევე მუშაობს, როგორც ადრე.
   Claude-ს ახლა უკეთ ესმის შენი პროექტის სტრუქტურა.
   უბრალოდ უთხარი რა გინდა გააკეთო.

🆘 თუ რამე გაფუჭდა:
   - "გააუქმე ბოლო ცვლილება"
   - "რაღაც გაფუჭდა, გაასწორე"
   - "დააბრუნე ბოლო მომუშავე ვერსია"
```

---

### Post-Build Verification

**IF NEW_PROJECT:**
1. Start the dev server
2. Take a screenshot of the running app
3. Show the user: "აი ასე გამოიყურება შენი ახალი პროექტი:"
4. Ask: "ყველაფერი კარგად გამოიყურება?"

**IF EXISTING_PROJECT:**
1. IF project has a dev server → start it, take screenshot, verify nothing broke
2. IF project has tests → run them, report results
3. IF nothing to verify → "პროექტი მზადაა. ცვლილებები მხოლოდ კონფიგურაციას ეხება."

---

### User Feedback

After showing the summary, ask:
"რამე შეიცვალოს? 1-10 შეაფასე რამდენად მოგეწონა სტრუქტურა."
Save the rating to auto-memory for future improvements.

---

## For N8N-ONLY Projects

### NEW_PROJECT — N8N Only

If the auto-selection determined pure n8n:

Skip source code generation. Instead:
1. Create a `workflows/` directory with template JSON
2. Create documentation on how to import to n8n
3. Reference the user's n8n instance
4. Create webhook endpoint documentation
5. Infrastructure from Phase 1 is already in place

Summary:
```
✅ n8n პროექტი "{name}" მზადაა!

📁 Workflow-ის შაბლონები: workflows/
🔗 n8n ინსტანცია: aipulsegeorgia2025.app.n8n.cloud

🚀 შემდეგი ნაბიჯი:
   "გადაიტანე ეს workflow ჩემს n8n-ში"

🆘 თუ რამე გაფუჭდა:
   - "გააუქმე ბოლო ცვლილება"
   - "რაღაც გაფუჭდა, გაასწორე"
   - "დააბრუნე ბოლო მომუშავე ვერსია"
```

### EXISTING_PROJECT — N8N Only

1. Check if `workflows/` directory exists — do NOT recreate existing templates
2. Check for n8n documentation — add only if missing
3. Verify n8n instance reference in CLAUDE.md

Summary:
```
✅ n8n პროექტი "{name}" გაძლიერებულია!

📋 რა დაემატა: [list]
⏭️ რა არ შეცვლილა: შენი არსებული workflow-ები ხელუხლებელია
🔗 n8n ინსტანცია: [confirmed URL]

🆘 თუ რამე გაფუჭდა:
   - "გააუქმე ბოლო ცვლილება"
   - "რაღაც გაფუჭდა, გაასწორე"
   - "დააბრუნე ბოლო მომუშავე ვერსია"
```

---

## For HYBRID Projects

### NEW_PROJECT — HYBRID

Create both:
1. Code structure (src/) for the application part
2. Workflows reference (workflows/) for the n8n part
3. Integration documentation (how code calls n8n webhooks and vice versa)

Summary:
```
✅ შერეული პროექტი "{name}" მზადაა!

📁 კოდის ნაწილი: src/ — აპლიკაციის სტრუქტურა
📁 n8n ნაწილი: workflows/ — ავტომატიზაციის შაბლონები
📁 ინტეგრაცია: docs/ — როგორ ურთიერთობს კოდი და n8n

🚀 შემდეგი ნაბიჯი:
   უთხარი Claude-ს რა გინდა ააწყო — კოდის ნაწილი თუ n8n workflow.

🆘 თუ რამე გაფუჭდა:
   - "გააუქმე ბოლო ცვლილება"
   - "რაღაც გაფუჭდა, გაასწორე"
   - "დააბრუნე ბოლო მომუშავე ვერსია"
```

### EXISTING_PROJECT — HYBRID

Detect which parts exist:

**Case A: Code exists, n8n part missing**
- Treat code part as EXISTING_PROJECT (merge, don't overwrite)
- ASK: "n8n workflow-ების ნაწილი დავამატო? [კი / არა]"

**Case B: N8N exists, code part missing**
- Treat n8n part as existing (don't touch workflows)
- ASK: "კოდის ნაწილი დავამატო? [კი / არა]"

**Case C: Both exist**
- Treat BOTH as existing — merge/enhance only
- Check for integration documentation, add if missing

Summary:
```
✅ შერეული პროექტი "{name}" გაძლიერებულია!

📋 კოდის ნაწილი: [what was added/merged]
📋 n8n ნაწილი: [what was added/merged]
📋 ინტეგრაცია: [integration docs status]
⏭️ რა არ შეცვლილა: [preserved items]

🆘 თუ რამე გაფუჭდა:
   - "გააუქმე ბოლო ცვლილება"
   - "რაღაც გაფუჭდა, გაასწორე"
   - "დააბრუნე ბოლო მომუშავე ვერსია"
```

---

## Decision Flow Summary

```
/setup invoked
    │
    ├── Phase 0: Detect Mode
    │   ├── Empty directory → NEW_PROJECT
    │   └── Has files → EXISTING_PROJECT → Audit → Report → Confirm
    │
    ├── Phase 1: Infrastructure (conditional per item)
    │   ├── NEW: create everything from scratch
    │   └── EXISTING: skip OK, merge INCOMPLETE, create MISSING, fix MISCONFIGURED
    │
    └── Phase 2: Tech Stack & Build
        ├── NEW: ask idea → detect signals → select tech → confirm → build
        └── EXISTING: detect stack → confirm → enhance (non-destructive)
```
