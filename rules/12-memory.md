# Memory & Context Management Rules

Claude MUST follow these rules to maintain perfect context across sessions.

---

## 1. SESSION START PROTOCOL

At the beginning of EVERY session:

1. Read CLAUDE.md (automatic)
2. Read docs/decisions/ if it exists — understand past architectural choices
3. Check git log --oneline -10 — see what was done recently
4. If handoff note exists (.claude/handoff-*.md) — read it and resume
5. Briefly tell user: "I see we last worked on [X]. Want to continue or start something new?"

DO NOT recite the entire CLAUDE.md. Just acknowledge context silently.

---

## 2. SESSION END PROTOCOL

Before the session ends (user says goodbye, or context is getting full):

1. Create a handoff note:
   ```
   .claude/handoff-YYYY-MM-DD.md
   ```
   Contents:
   - What was accomplished this session
   - Current state of the project
   - What's left to do (next steps)
   - Any important discoveries or decisions made
   - Unresolved issues or bugs

2. If architectural decisions were made — save to docs/decisions/
3. If user preferences were learned — note them for future reference
4. Suggest: "Want me to save a checkpoint before we stop?"

---

## 3. WHAT TO REMEMBER (and WHERE)

| Information | Where to Store | Why There |
|---|---|---|
| Architecture decisions | docs/decisions/NNN-title.md | Permanent, shareable, reviewable |
| Build/test commands that work | CLAUDE.md | Always available |
| Debugging solutions found | Auto memory (automatic) | Claude learns |
| User's design preferences | Auto memory | Personal, evolving |
| What was built and why | git commit messages | Source of truth |
| Session context for next time | .claude/handoff-*.md | Bridge between sessions |
| Important errors and fixes | Auto memory | Future reference |

---

## 4. ARCHITECTURAL DECISION RECORDS (ADR)

When a significant technical decision is made, create:

```
docs/decisions/
├── 001-chose-nextjs-over-vue.md
├── 002-supabase-for-database.md
└── 003-code-plus-n8n-hybrid.md
```

Each file:
```markdown
# NNN: Decision Title

## Date
YYYY-MM-DD

## Status
accepted / superseded / deprecated

## Context
What problem were we solving?

## Decision
What did we decide?

## Reasoning
Why this choice over alternatives?

## Consequences
What are the trade-offs?
```

Create an ADR when:
- Choosing a database, framework, or major library
- Deciding between code vs n8n approach
- Changing project architecture
- Making a security-related decision
- Choosing a deployment strategy

---

## 5. CONTEXT WINDOW MANAGEMENT

### Monitor Usage
- If conversation is getting long (20+ exchanges): suggest /compact
- If working on many different things: suggest /clear between topics
- Never let context get so full that quality drops

### Compact Strategy
- Compact BEFORE reaching 60% context usage, not after
- When compacting, preserve:
  - Current task state
  - Recent decisions
  - Active bugs/issues
  - CLAUDE.md (auto-reloaded)
- When compacting, discard:
  - Early brainstorming that led nowhere
  - Failed attempts that were reverted
  - Verbose tool outputs already processed

### Tell the user (in plain language):
"Our conversation is getting long. I'll save a summary so we don't lose context. You won't notice any difference."

---

## 6. HANDOFF NOTE FORMAT

```markdown
# Session Handoff - YYYY-MM-DD

## Accomplished
- [List of things completed this session]

## Current State
- App status: [working / has issues / in progress]
- Branch: [current git branch]
- Last commit: [summary]

## Next Steps
1. [Most important next task]
2. [Second priority]
3. [Third priority]

## Important Context
- [Any non-obvious information the next session needs]
- [Decisions made and why]
- [Known issues]

## Open Questions
- [Things that need user input]
```

---

## 7. WHAT CLAUDE SHOULD NEVER FORGET

Even across sessions, always remember:
- The project's purpose (from CLAUDE.md overview)
- The tech stack (from CLAUDE.md)
- The user doesn't write code (interaction rules)
- Security rules (never put secrets in code)
- Testing is mandatory (not optional)
- Ask before big changes (scope control)

These are in CLAUDE.md and rules/ — they reload every session automatically.

---

## 8. CLEANING OLD CONTEXT

### Handoff notes
- Keep the latest 3 handoff notes
- Delete older ones (their content is in git history)
- Never auto-delete — ask user first

### Decisions directory
- Never delete ADRs — they are historical record
- Mark outdated ones as "superseded" in status field

### Auto memory
- Let Claude manage this automatically
- If it gets bloated (>200 lines) — Claude will trim old entries
