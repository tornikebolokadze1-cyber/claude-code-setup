# Security Policy

## Supported Versions

| Version / Branch | Supported |
| ---------------- | --------- |
| `main`           | ✅ Yes    |
| Older tags       | ❌ No     |

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

Email **tornikebolokadze1@gmail.com** with the subject line:

```
[SECURITY] claude-code-setup
```

Include:
- A description of the issue and its potential impact
- Steps to reproduce or a proof-of-concept (if applicable)
- Affected files / rule / hook / template names

**Response SLA:** You will receive an acknowledgment within **48 hours**. A fix or mitigation plan will follow as soon as practical.

## Scope

This repository is a **configuration layer** — it ships rule files, hooks, slash commands, and project bootstrap templates that users apply to their own Claude Code installations.

**In scope:**
- Rules in `rules/` that encode insecure defaults which would propagate to downstream projects
- Hooks in `hooks/settings-hooks.json` that execute shell commands (injection risks, unintended side-effects)
- Bootstrap templates in `bootstrap-templates/` that scaffold insecure code patterns
- The `/setup` command in `commands/setup.md` if it installs or executes code unsafely
- `install.sh` if it performs unsafe operations

**Out of scope:**
- Security posture of **user projects** that consume this template — those projects have their own threat models and are outside our control
- Vulnerabilities in Claude Code itself — report those to [Anthropic](https://www.anthropic.com/security)
- Vulnerabilities in third-party tools or packages referenced by the templates (report upstream)

## Threat Model

This repo is a config layer, not a runtime service. The primary threat is **insecure defaults propagating to downstream projects** — for example:

- A rule that advises disabling security controls
- A hook that runs with overly broad permissions or is susceptible to command injection
- A bootstrap template that hardcodes secrets, disables HTTPS, or ships with permissive CORS

We treat any such finding as a valid security issue worth fixing promptly.
