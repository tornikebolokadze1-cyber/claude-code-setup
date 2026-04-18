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
