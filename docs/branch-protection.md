# Branch Protection Setup — `main`

This checklist tells the maintainer exactly what to configure to protect the `main` branch.
Apply once after the repository is created or whenever protections need to be reset.

---

## Settings to apply

| Setting | Value |
|---------|-------|
| Required approving reviews | 1 (from CODEOWNERS) |
| Dismiss stale reviews on new push | Yes |
| Require status checks to pass | `validate`, `gitleaks`, `smoke-test` |
| Require branches to be up to date | Yes |
| Require linear history | Yes |
| Require signed commits | Optional (recommended; see GOVERNANCE.md §5) |
| Allow force pushes | No |
| Allow deletions | No |

---

## GitHub UI — step by step

1. Open the repository on GitHub.
2. Go to **Settings** → **Branches** (left sidebar).
3. Under **Branch protection rules**, click **Add rule**.
4. In **Branch name pattern**, type `main`.
5. Check **Require a pull request before merging** → set **Required approvals** to `1`.
6. Check **Dismiss stale pull request approvals when new commits are pushed**.
7. Check **Require status checks to pass before merging**.
   - Search for and add: `validate`, `gitleaks`, `smoke-test`.
   - Check **Require branches to be up to date before merging**.
8. Check **Require linear history**.
9. Leave **Require signed commits** unchecked (or check it if all contributors have signing configured).
10. Ensure **Allow force pushes** is unchecked.
11. Ensure **Allow deletions** is unchecked.
12. Click **Create** (or **Save changes**).

---

## Equivalent `gh api` command

For scripted or reproducible setup, use the REST API with the payload in
[`docs/branch-protection.json`](./branch-protection.json):

```bash
gh api repos/tornikebolokadze1-cyber/claude-code-setup/branches/main/protection \
  --method PUT \
  --input docs/branch-protection.json
```

> Requires a token with `repo` scope (admin access). Run this after the first
> push to `main` so the branch exists.

---

## Verifying current protection

```bash
gh api repos/tornikebolokadze1-cyber/claude-code-setup/branches/main/protection \
  --jq '{
    required_reviews: .required_pull_request_reviews.required_approving_review_count,
    linear_history: .required_linear_history.enabled,
    force_push_blocked: (.allow_force_pushes.enabled | not),
    required_checks: [.required_status_checks.contexts[]]
  }'
```
