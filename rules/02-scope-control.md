# Scope Control Rules

## File Change Limits

| Files to change | Action required |
|----------------|----------------|
| 1-3 files | Proceed freely, explain what you did after |
| 4-6 files | Tell user what you plan to change BEFORE doing it |
| 7-10 files | Require explicit "yes" or "go ahead" from user |
| 11+ files | REFUSE unless user specifically asked for a large change. Suggest breaking it into steps. |

## What Counts as a "Big Change" (Always Needs Confirmation)

Claude MUST ask before:
- Changing how the app's navigation or routing works
- Modifying authentication or login systems
- Altering the database structure (adding/removing tables or columns)
- Changing the build system or deployment config
- Removing any feature, component, or page
- Upgrading major dependency versions (e.g., React 18 to 19)
- Changing the project's folder structure
- Modifying payment or billing logic
- Altering email/notification systems
- Changing API endpoints that other services depend on

How to ask:
```
I need to make a bigger change to do what you asked. Here is what I plan to do:

- [Change 1 in plain language]
- [Change 2 in plain language]
- [Change 3 in plain language]

This will affect: [list areas of the app]
Risk level: [LOW / MEDIUM / HIGH]

Should I go ahead? (Say "yes" to continue or "no" to stop)
```

## NEVER Touch Without Permission

These files/directories are PROTECTED. Claude must ask before modifying:

### Critical Config Files
- `.env`, `.env.*` (environment secrets)
- `package.json` (only dependency changes without asking)
- `docker-compose.yml`, `Dockerfile`
- CI/CD files (`.github/workflows/`, `Jenkinsfile`, etc.)
- `next.config.*`, `vite.config.*`, `webpack.config.*`
- `tsconfig.json`, `jsconfig.json`
- Database config files, ORM config (prisma/schema.prisma, drizzle.config.ts)

### Critical Directories
- `/migrations/`, `/prisma/migrations/`
- `/.github/`
- `/scripts/` (deployment scripts)
- `/public/` (only for asset deletion, adding is fine)

### Critical Patterns
- Any file with "auth", "payment", "billing", "admin" in the name
- Any middleware files
- Any file that handles user sessions or tokens

## Anti-Scope-Creep Rules

1. **Only change what the user asked for.** If you see a bug in unrelated code, MENTION it but do NOT fix it unless asked.
2. **No surprise refactoring.** Never reorganize imports, rename variables, reformat code, or "clean up" files the user did not mention.
3. **No architecture changes.** If the user asks to add a button, add a button. Do not restructure the component hierarchy to "do it properly."
4. **No dependency additions without stating it.** Before running `npm install <anything>`, tell the user: "I need to install [package] because [reason]. OK?"
5. **Stay in the user's feature.** If asked to change the homepage, do NOT also "improve" the footer, header, or other pages.
6. **Preserve existing patterns.** Match the existing code style. If the project uses class components, do not convert to hooks. If it uses CSS modules, do not switch to Tailwind.

## The 30-Second Rule

Before making any change, Claude should be able to explain it in one sentence a non-coder would understand. If the explanation requires technical terms, the change might be too broad.

Good: "I am adding a blue button that says 'Submit' to the contact form."
Bad: "I am refactoring the form component to use a controlled state pattern with proper validation middleware integration."
