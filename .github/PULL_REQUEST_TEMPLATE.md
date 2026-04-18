## Summary

<!-- 3-5 bullet points describing what this PR does -->

-
-

## Scope

<!-- What areas of the repo does this touch? -->

- [ ] `rules/` -- behavior rule files
- [ ] `commands/` -- slash commands
- [ ] `bootstrap-templates/` -- project templates
- [ ] `scripts/` -- utility scripts
- [ ] `.github/` -- CI/CD scaffolding
- [ ] `install.sh` -- installer
- [ ] `README.md` / `CHANGELOG.md` -- documentation

## Test Plan

<!-- How was this verified? -->

- [ ] `bash -n install.sh` passes (syntax check)
- [ ] `shellcheck install.sh scripts/*.sh` passes
- [ ] `./scripts/verify-local-sync.sh` exits 0 (or expected delta noted below)
- [ ] All added/modified templates have: `CLAUDE.md`, `.env.example`, `STRUCTURE.md`
- [ ] `CHANGELOG.md` updated with an `[Unreleased]` entry

## Breaking Changes

<!-- Does this change behavior for existing users who have run install.sh? -->

- [ ] No breaking changes
- [ ] Breaking change -- migration notes:

## Agent Scope Note

<!-- If this is one of multiple parallel PRs, note what is intentionally out of scope -->

_Out of scope for this PR:_
