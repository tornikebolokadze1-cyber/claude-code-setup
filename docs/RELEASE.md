# Release Checklist

Step-by-step guide for the maintainer to cut a new release.

---

## Pre-release sanity check

Run this command to verify `VERSION` and `CHANGELOG.md` are in sync before you tag:

```bash
node -e "const v=require('fs').readFileSync('VERSION','utf8').trim(); const cl=require('fs').readFileSync('CHANGELOG.md','utf8'); process.exit(cl.includes('[' + v + ']') ? 0 : 1)"
```

Exit code `0` = in sync. Exit code `1` = mismatch; fix before continuing.

---

## Steps

### 1. Ensure CI is green on `main`

```bash
gh run list --branch main --limit 5
```

All recent workflow runs must show `completed / success`. Do not release from a red `main`.

### 2. Bump `VERSION`

Edit `VERSION` to the new version string (e.g. `1.2.3`). Follow semver rules from [`GOVERNANCE.md`](./GOVERNANCE.md#3-release-cadence).

```bash
echo "1.2.3" > VERSION
```

### 3. Update `CHANGELOG.md`

- Move all entries under `[Unreleased]` to a new heading:
  ```
  ## [1.2.3] - 2026-04-17
  ```
- Open a fresh empty `[Unreleased]` block above it:
  ```markdown
  ## [Unreleased]

  ### Added
  ### Changed
  ### Fixed
  ### Deprecated
  ### Removed
  ```
- Update the compare links at the bottom of `CHANGELOG.md`:
  ```
  [Unreleased]: https://github.com/tornikebolokadze1-cyber/claude-code-setup/compare/v1.2.3...HEAD
  [1.2.3]: https://github.com/tornikebolokadze1-cyber/claude-code-setup/compare/v1.2.2...v1.2.3
  ```

### 4. Verify README counts

Confirm the counts in `README.md` (rules, hooks, templates, commands) match the actual files on disk:

```bash
echo "Rules:     $(ls rules/*.md 2>/dev/null | wc -l)"
echo "Hooks:     $(ls hooks/*.sh 2>/dev/null | wc -l)"
echo "Commands:  $(ls commands/*.md 2>/dev/null | wc -l)"
echo "Templates: $(ls -d bootstrap-templates/*/ 2>/dev/null | wc -l)"
```

Update the README badge/count values if they are stale.

### 5. Tag the release (signed)

```bash
git tag -s vX.Y.Z -m "Release vX.Y.Z"
git push --tags
```

Use a GPG- or SSH-signed tag. If signing is not configured, see the signed commits section in [`GOVERNANCE.md`](./GOVERNANCE.md#5-signed-commits).

### 6. Create the GitHub release

Trim `CHANGELOG.md` to just the new version section and pass it as release notes:

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z" \
  --generate-notes \
  --notes-file CHANGELOG.md
```

Review the generated release notes on GitHub and edit if needed.

### 7. Announce (optional)

- Update any README version badge if present.
- Post to the Tbilisi developer community or relevant channels if the release is significant.

---

## Hotfix releases

For urgent fixes on `main`:

1. Create a `hotfix/<description>` branch from `main`.
2. Apply the minimal fix.
3. Follow steps 1–7 above, bumping only the PATCH version.
4. Merge the hotfix branch back into `main` after tagging.
