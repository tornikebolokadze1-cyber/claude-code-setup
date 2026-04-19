# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 0.4.x | ✅ |
| 0.3.x | ❌ — please upgrade to 0.4.x |
| 0.2.x and earlier | ❌ |

This project moves fast; only the latest minor release is supported for
security fixes. Users of older releases are encouraged to upgrade; the
upgrade path is documented in `CHANGELOG.md`.

## Reporting a vulnerability

If you discover a security issue, please **do not open a public issue**.
Instead, email **tornikebolokadze1@gmail.com** with:

- A description of the issue
- Reproduction steps or a proof-of-concept (if safe to share)
- The impact you believe it has (RCE, credential leak, path traversal, etc.)
- Any suggested mitigation

Expect:

- **Acknowledgement within 48 hours**
- **Initial assessment within 7 days**
- **Patch within 14 days for critical issues**; longer for lower-severity

## Threat model — scaffolder delegation (v0.4+)

`/setup-AI-Pulse-Georgia` delegates project scaffolding to third-party
community tools (`npx --yes create-next-app@latest`, `pipx run cookiecutter ...`,
`npm create vite@latest`, `npm create cloudflare@latest`). Running these
commands executes arbitrary code from the npm / PyPI / GitHub supply chain
with the invoking user's privileges. Risks:

- Compromised upstream maintainer chain (see tj-actions/changed-files, March 2025)
- Typo-squatting packages
- Postinstall scripts with RCE primitives

### Mitigations in v0.4.1

- Claude must ask the user for consent before the first scaffolder invocation
  on a given machine (cached in `~/.claude/.consent-scaffolders.json`).
- Scaffolders run in a sibling temp directory, not the project root, with
  `--disable-git` / `--no-git` / `--skip-git` flags. Files are `rsync`-ed
  into the project root afterward.
- Fallback to frozen `archive/bootstrap-templates/` when scaffolder fails.

### Residual risks (user must accept)

- Package integrity is trusted at the registry level (no PGP verification).
- Cookiecutter templates from GitHub are not SHA-pinned (tracked in repo issues).
- Node's `postinstall` lifecycle scripts run by default (no `--ignore-scripts`).

If any of these are unacceptable for your threat model, use the fallback
path (`archive/bootstrap-templates/<stack>/`) instead of the scaffolder.

## What is NOT a vulnerability

- A hook in `hooks/reference/` failing because its Python dependency is
  not installed — hooks are opt-in, and the user is expected to wire them
  manually per `hooks/README.md`.
- `archive/bootstrap-templates/**` being frozen at v0.3.0 dependency
  versions — archived templates are archetypes, not live code. Consumers
  who copy them must update dependencies themselves.
- Dependabot alerts on `archive/**` — Dependabot is intentionally scoped
  away from archived paths.

## Security-adjacent rules

The `rules/security.md` file ships OWASP Top 10 guidance for downstream
projects. The repo itself eats this dogfood: see `.gitignore` (§4.2),
`.github/workflows/ci.yml` (secret scan, least-privilege permissions),
and `.gitleaks.toml` (custom rules for Telegram / n8n / Supabase tokens).

## History

- v0.4.0 — Delegation-based scaffolding introduced supply-chain surface.
- v0.4.1 — Threat model documented, consent protocol added, CI hardened.
