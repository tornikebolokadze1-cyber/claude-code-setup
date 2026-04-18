# Global Rules — Index & Layering

These rules load automatically for every Claude Code session via `~/.claude/CLAUDE.md`.
They form a layered defense-in-depth system — not a flat checklist.

---

## The Six Layers

### Layer 1 — Safety (protects the user from AI mistakes)

These rules exist because Claude Code is powerful enough to cause real damage if unconstrained.
They are the most important rules in the set. They load first and have the highest authority.

| File | Scope |
|------|-------|
| `01-auto-checkpoint.md` | Git save points before every risky change; restore procedure |
| `02-scope-control.md` | File-count thresholds (1-3 free / 4-6 announce / 7-10 ask / 11+ refuse) |
| `03-error-recovery.md` | Severity matrix, two-strike rule, cascading-failure prevention |
| `05-session-management.md` | Session start/end protocol, context hygiene |
| `06-destructive-actions.md` | Hard blocks: `rm -rf`, force push, DROP TABLE, .env overwrites |
| `07-backup-strategy.md` | File-level timestamped backups; when to trigger; cleanup policy |

### Layer 2 — Quality (catches mistakes before they compound)

These rules ensure that changes are tested, visible, and reversible before they become the
new baseline.

| File | Scope |
|------|-------|
| `10-testing.md` | Auto-test triggers, unit/integration/E2E requirements, coverage floors |
| `11-ui-verification.md` | Playwright screenshot sequence (desktop/tablet/mobile), accessibility tree, console errors |
| `04-visual-verification.md` | Lightweight quick-check subset of rule 11 — used for fast single-page confirmations |
| `17-development-workflow.md` | TDD loop (Red → Green → Improve), conventional commits, branch strategy |

### Layer 3 — Communication (non-technical user translation)

These rules exist because the primary user of this system writes prompts, not code. Claude must
translate every technical concept into plain language before acting.

| File | Scope |
|------|-------|
| `08-communication.md` | Jargon translation table, response structure, tone |
| `09-vague-prompt-handling.md` | Interpretation Ladder, "Just Do Something" rule, common request translations |

### Layer 4 — Language and Stack Standards

Per-language coding standards. Apply the one matching the project's primary language.
All four are loaded simultaneously so Claude can switch within a polyglot repo.

| File | Scope |
|------|-------|
| `13-typescript-standards.md` | Types, React patterns, immutability, Zod validation, Vitest |
| `14-python-standards.md` | Pydantic, dataclasses, pytest, async patterns, ruff/black |
| `15-go-standards.md` | Interfaces, error wrapping, table-driven tests, `-race`, errgroup |

> Rust, Swift, and Kotlin standards are planned for Phase 2. Until then, apply
> `16-production-standards.md` as the language-agnostic fallback.

### Layer 5 — Production Hygiene

Cross-cutting rules that apply regardless of language or stack. These are the production
baseline that every shipped artifact must meet.

| File | Scope |
|------|-------|
| `16-production-standards.md` | Immutability, file size, nesting depth, naming, logging, config |
| `18-observability.md` | Structured logging schema, RED+USE metrics, distributed tracing, alert tiers |
| `19-api-versioning.md` | SemVer scheme, URL vs header strategies, deprecation policy, Sunset headers |
| `security.md` | OWASP Top 10, secrets management, network security, resource limits |

### Layer 6 — Session and Memory

Rules that govern how Claude remembers context across sessions and manages the context window.

| File | Scope |
|------|-------|
| `05-session-management.md` | Also in Layer 1 — listed here because it governs session lifecycle |
| `12-memory.md` | Handoff notes, ADR format, context compaction strategy |

---

## Why the Intentional Redundancy

### Rules 01 and 07 — checkpoint vs backup

`01-auto-checkpoint.md` manages **git commits** as save points. It fires when 3+ files are
about to change, handles the restore procedure, and tracks working vs broken states in the
commit message. The granularity is at the session or feature level.

`07-backup-strategy.md` manages **file-level copies** — timestamped `.backup-YYYYMMDD-HHMMSS`
files for single critical files like `.env`, database configs, or migration files. It fires
before any individual file that cannot easily be reconstructed from git. The granularity is
at the file level.

They overlap on the question "save before modifying" but answer it at different scopes. Both
running is correct. Merging them would create a single oversized rule that is harder to scan
and harder to update independently.

### Rules 04 and 11 — visual check vs full verification

`11-ui-verification.md` is the complete UI testing protocol: Playwright screenshots at three
viewports, accessibility tree snapshot, console error check, network request audit, interactive
element verification, dark mode check, performance budget. It is the definitive standard.

`04-visual-verification.md` is a **quick-scan subset** — lightweight templates for when Claude
needs to confirm a single change and a full Playwright run is disproportionate to the scope.
Think "I changed one button color" vs "I rebuilt the navigation component." Rule 04 handles
the former; rule 11 handles the latter.

Both exist because forcing a full Playwright suite for a one-line CSS fix adds friction that
causes the rule to be skipped entirely. A tiered approach — light check for small changes,
full suite for significant changes — is more durable in practice.

### Rules 10 and 11 — testing vs UI verification

`10-testing.md` covers the full testing pyramid: unit tests, integration tests, API endpoint
tests, auth flow tests, webhook tests, and the automated verification flow. It applies to all
code changes, not just UI.

`11-ui-verification.md` covers only the visual and accessibility layer. It is triggered by any
change to a `.tsx`, `.html`, or `.css` file — a narrower trigger than rule 10.

The overlap is in the "after any UI change, take a screenshot" guidance. Having it in both
files means the instruction is visible to Claude regardless of which rule is most salient for
a given task. Defense-in-depth for instructions, not just for security.

---

## Rule Naming Convention

- Files are named `NN-kebab-case.md` where `NN` is a zero-padded two-digit integer.
- The integer defines **load order** within the session context. Lower numbers load first.
- `security.md` deliberately lacks a numeric prefix because it is **cross-cutting** — it
  applies at Layers 1, 2, and 5 simultaneously. Alphabetic sort places it after all numbered
  rules, which is correct: the numbered rules define behavior, security adds constraints on top.
- **Directive:** all future rule additions must use `NN+1` of the current highest number.
  Never renumber existing rules — doing so would break muscle memory and any external references.

---

## Loading Order

Claude Code loads all `.md` files from `~/.claude/rules/` at session start. The numeric
prefix determines the order in which rules appear in the context window. Rules with lower
numbers are processed first and establish the baseline that higher-numbered rules refine.

`~/.claude/CLAUDE.md` references `rules/` in its Quick Reference section. When a rule conflicts
with `CLAUDE.md`, `CLAUDE.md` wins — it is the user's personal override layer.

---

## Adding a New Rule

1. Determine the highest current `NN` (currently `19`).
2. Create `rules/20-your-rule-name.md`.
3. Follow the idiom: short intro → mandatory rules → examples → what-not-to-do.
4. Add it to the appropriate layer table in this index.
5. Update `CHANGELOG.md` under `[Unreleased]`.
6. Copy to `~/.claude/rules/` to activate locally.
