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
