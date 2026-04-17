# Governance

This document describes how the `claude-code-setup` repository is governed, who makes decisions, and how the project evolves.

---

## 1. Maintainer

**Tornike Bolokadze** (GitHub: `@tornikebolokadze1-cyber`) is the sole maintainer as of 2026-04-17.

Responsibilities include:
- Reviewing and merging pull requests
- Cutting releases and managing the `VERSION` file
- Triaging issues and security reports
- Deciding the direction of the project

---

## 2. Decision Making

The maintainer has final say on all decisions.

Public issues are welcome for feature requests, bug reports, and general discussion. Community input is valued and considered, but there is no voting mechanism. Decisions are not made by consensus.

If a contributor disagrees with a decision, they are encouraged to open an issue explaining their reasoning. The maintainer will respond.

---

## 3. Release Cadence

Releases are cut manually when meaningful changes accumulate. There is no fixed time-based schedule.

This project follows [Semantic Versioning](https://semver.org/) (`MAJOR.MINOR.PATCH`):

| Bump | When to use |
|------|-------------|
| **PATCH** | Bug fixes, documentation fixes, README count syncs, new rules that only ADD guidance without changing existing behavior |
| **MINOR** | New hooks, new templates, new commands, new rule files, new scripts. Non-breaking additions to `install.sh` flags (e.g., a new `--flag` that is opt-in). |
| **MAJOR** | Removal of a rule, hook, or template. Breaking changes to `install.sh` defaults. Changes to the `.installed-from.json` schema. Renaming of command entrypoints. |

---

## 4. Branch Policy

### `main`

`main` is the default and protected branch. The following protections are applied directly on GitHub:

- Require pull request reviews before merging (at least 1 approval from CODEOWNERS)
- Require passing status checks (`validate`, `gitleaks`, `smoke-test`)
- Block force pushes
- Require linear history

See [`docs/branch-protection.md`](./branch-protection.md) for the step-by-step setup checklist.

### Feature and fix branches

Branch names follow the pattern `<type>/<short-description>`:

```
chore/quality-100
feat/add-rust-template
fix/install-path-regression
docs/update-governance
```

Branches should be short-lived. Merge via pull request; delete the branch after merge.

### Dependabot branches

Dependabot creates branches automatically. They are merged by the maintainer after CI passes.

---

## 5. Signed Commits

Signed commits are **recommended** but not enforced at the repository level.

To set up GPG signing:

```bash
gpg --full-generate-key
git config --global user.signingkey <KEYID>
git config --global commit.gpgsign true
```

To use SSH signing as an alternative:

```bash
gh ssh-key add ~/.ssh/id_ed25519.pub --title "signing-key"
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

---

## 6. CI/CD Requirements

All pull requests must pass the following checks before merging:

| Check | Blocking? | Purpose |
|-------|-----------|---------|
| `validate` | Yes | Lints YAML/JSON, checks script syntax |
| `gitleaks` | Yes | Detects accidentally committed secrets |
| `smoke-test` | Yes | Runs `install.sh --dry-run` against each template |
| `claude-review` | No (advisory) | AI-assisted code review; informational only |

A failing `smoke-test` is a **hard block** — the PR cannot be merged until it passes.

---

## 7. Security Process

Security vulnerabilities should be reported as described in [`SECURITY.md`](../SECURITY.md).

- The maintainer commits to acknowledging reports within **48 hours**.
- Coordinated disclosure is strongly preferred. Do not open a public issue for a vulnerability until a fix is available.
- Once a fix is ready and deployed, the reporter will be credited in the release notes (unless they prefer to remain anonymous).

---

## 8. Breaking Change Process

Breaking changes require additional process to protect downstream users:

1. **Propose via issue first.** Open a GitHub issue describing the change, the motivation, and the migration path. Allow at least a few days for community feedback.
2. **If accepted**, implement the change on a `feat/<change>` branch.
3. **Update `CHANGELOG.md`** under `### Changed` with a `BREAKING:` tag describing what changed and what users must do.
4. **Bump the MAJOR version** in the `VERSION` file.
5. **Document the migration path** in a new file at `docs/migration/vX-to-vY.md`.
6. Open a pull request. The PR description must link to the original proposal issue.

---

## 9. Deprecation Policy

Features are not removed without warning.

1. The feature is marked deprecated in the relevant file (comment or printed warning from `install.sh --check`).
2. The deprecation is noted in `CHANGELOG.md` under `### Deprecated`.
3. The feature lives for **at least one MINOR release** while deprecated.
4. After that grace period, it can be removed in the next MAJOR release, following the Breaking Change Process above.

---

## 10. License and Attribution

This project is licensed under the **MIT License**. See [`LICENSE`](../LICENSE) for the full text.

Contributions are accepted under the same MIT License. By submitting a pull request, contributors agree that their work is licensed under MIT.

Significant contributors will be added to `CONTRIBUTORS.md`. This file does not exist yet and will be created upon the first external contribution.
