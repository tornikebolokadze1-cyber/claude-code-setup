<!-- Copy the content below (everything between the horizontal rules) into the PR description field -->

---

## Summary

Two-round quality upgrade against 2026 Claude Code best practices after an external base-infrastructure audit flagged missing LICENSE, CI, governance, and empirical validation.

- **Round 1** — repo hygiene: LICENSE (MIT), SECURITY.md, CONTRIBUTING.md, CHANGELOG.md, .env.example, CODEOWNERS, dependabot.yml, GitHub issue + PR templates, three CI workflows (`validate`, `gitleaks`, `claude-review`), Windows PowerShell hook variant, split of the 1875-line `setup.md` into phase files, three operator scripts, `.markdownlint.jsonc`, `.gitleaks.toml`.
- **Round 2** — empirical validation + governance: `smoke-test.yml` (5 jobs: install.sh E2E, idempotency, hook-merge, template-gitignore, rule-limit, phase-split integrity), installer hardening (`--dry-run` / `--check` / `--version` / `--force` / `--help`, manifest, versioned UTC backups, strict modes, explicit file perms), `uninstall.sh`, `scripts/validate-install.sh` doctor, `VERSION 0.2.0`, `DESIGN.md`, root `CLAUDE.md` for contributors, `docs/{GOVERNANCE,RELEASE,branch-protection}.md` + `.json`, dependabot grouping (PR noise ≈ 80% cut), `.gitignore` for four previously-missing bootstrap templates.
- **Round 3** — fix-forward: `scripts/migrate-credentials.sh` hardened against three real bugs surfaced when the scanner ran against the author's actual tree (nested-JSON flatten, explicit `~/.claude/channels/*/` subpaths, `PROJECTS_ROOT` loop). `docs/PUSH.md` first-push runbook.

**46 files changed (4 modified, 42 added), +5232 / −1873 lines across 3 commits.**

## Test plan

- [ ] `validate` workflow green (JSON / YAML / markdown-lint / shellcheck / rule-count / phase-split-integrity)
- [ ] `gitleaks` workflow green (allowlist in `.gitleaks.toml` covers `.env.example` placeholders)
- [ ] `smoke-test` workflow green (install.sh E2E + idempotency + template gitignore + hook JSON merge)
- [ ] `claude-review` workflow preflight-skips cleanly when `ANTHROPIC_API_KEY` is absent (add the secret to enable)
- [ ] README counts match actuals: 18 rules, 11 hooks, 7 templates
- [ ] `install.sh --version` prints `0.2.0`
- [ ] `install.sh --dry-run` lists files without writing
- [ ] `uninstall.sh --list` reads the manifest correctly

## Dependabot note

GitHub flagged 12 vulnerabilities on `main` at push time (1 critical, 3 high, 8 moderate). Enable **Dependency graph** + **Dependabot alerts** under Settings → Code security and analysis, leave **Dependabot security updates** off until this PR is merged (otherwise auto-PRs will pile up blocked behind branch protection). The new `.github/dependabot.yml` groups updates per ecosystem, so expect one batched PR per template per week rather than dozens of individual PRs.

## After merge

1. `git tag -a v0.2.0 -m "Release v0.2.0 — quality baseline" && git push --tags`
2. `gh release create v0.2.0 --generate-notes`
3. Apply branch protection via `docs/branch-protection.md` (or the `gh api PUT` one-liner)
4. Enable Dependabot security updates
5. Add `ANTHROPIC_API_KEY` repo secret if you want `claude-review` active

🤖 Generated with [Claude Code](https://claude.com/claude-code)
