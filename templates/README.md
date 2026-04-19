# `templates/` — Reference templates

This directory ships reference templates that `/setup-AI-Pulse-Georgia`
and related tooling point users at. They are **not** automatically
injected into projects; they are manually copied or referenced.

## Files

### `CLAUDE.md.example` (73 lines)

Reference template for a project-level `CLAUDE.md`. Follows Anthropic's
April 2026 convention: under 80 lines, scannable in one screen, with
Jinja-style `{{placeholder}}` tokens.

**Use it when:** `/setup-AI-Pulse-Georgia` §2.7.1 needs to generate a
project-specific `CLAUDE.md`. Claude substitutes `{{project-name}}`,
`{{language}}`, etc., based on detected stack.

### `settings.local.json.example`

Reference permissions overlay for `.claude/settings.local.json`. Implements:

- Rule 06 deny-list (destructive actions) — 50+ entries covering `rm -rf`,
  `git push --force`, `DROP TABLE`, shutdown, `curl | bash`, SSH key reads, etc.
- Security.md §1.2 least-privilege allow-list scoped to common dev operations

**Use it when:** a user sets up a new project and wants a starting-point
permissions configuration. Copy to `.claude/settings.local.json` at project
root and prune entries that are too restrictive for the specific workflow.

## Where these are installed

`install.sh` copies the full `templates/` directory to
`~/.claude/templates/`. Users reference them with absolute paths:

- `~/.claude/templates/CLAUDE.md.example`
- `~/.claude/templates/settings.local.json.example`

## Extending

To add a new reference template:

1. Drop a file here (e.g., `CONTRIBUTING.md.example`).
2. Update this README.
3. Reference it from `commands/setup-phases/phase-1.md` or `phase-2.md`
   where appropriate.
4. `install.sh` copies it automatically — no changes needed there.
