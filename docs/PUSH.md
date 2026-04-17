# First push + release checklist

This branch (`chore/quality-100`) contains two commits that have not yet been pushed to GitHub. Follow these steps in order.

## 1. Authenticate GitHub CLI

```bash
# From any shell:
gh auth login
# choose: GitHub.com -> HTTPS -> login with web browser -> paste one-time code
# verify:
gh auth status
```

If you prefer SSH: `gh auth login --git-protocol ssh`. Either works for this repo.

## 2. Push the branch

```bash
cd "C:\Users\AI Pulse Georgia\claude-code-setup-work"
git push -u origin chore/quality-100
```

Expected output: `* [new branch]      chore/quality-100 -> chore/quality-100`. If it fails with `403`, re-run `gh auth status`; if it fails with `non-fast-forward`, inspect `git log origin/chore/quality-100 -3` and rebase as needed.

## 3. Open a PR

```bash
gh pr create \
  --base main \
  --head chore/quality-100 \
  --title "chore: raise repo quality to A+ (98%)" \
  --body-file docs/PUSH.md
```

Or use the GitHub web UI — the PR template in `.github/PULL_REQUEST_TEMPLATE.md` will preload.

## 4. Watch CI

```bash
gh pr checks --watch
```

Expected: `validate`, `gitleaks`, `smoke-test`, `claude-review` all run. First-run gotchas:

- **`claude-review` fails if `ANTHROPIC_API_KEY` secret is absent.** It's designed to preflight-skip in that case, but verify. To add the secret: `gh secret set ANTHROPIC_API_KEY`.
- **`smoke-test` runs `install.sh` in a disposable dir on Ubuntu.** If it fails on "node not found" add an `actions/setup-node@v4` step; if it fails on "jq not found" add `sudo apt-get install -y jq` (ubuntu-latest has both by default but this can drift).
- **`gitleaks` may trip on the `.env.example` placeholder values.** The repo ships `.gitleaks.toml` with the correct allowlist — if it still trips, the allowlist needs another regex for the specific pattern.
- **`validate` — markdown-lint** may flag new files. Config is `.markdownlint.jsonc` at repo root; tune there.

Fix any failures on a new branch (`fix/ci-<issue>`), merge into `chore/quality-100`, retrigger.

## 5. Merge

Once all checks are green:

```bash
gh pr merge --squash --delete-branch
# or via UI: "Squash and merge"
```

## 6. Tag v0.2.0

```bash
git checkout main
git pull --ff-only
# Sanity check:
node -e "const v=require('fs').readFileSync('VERSION','utf8').trim(); const cl=require('fs').readFileSync('CHANGELOG.md','utf8'); process.exit(cl.includes('['+v+']') || cl.includes('[Unreleased]') ? 0 : 1)"
# If sanity passes (exit 0):
git tag -a v0.2.0 -m "Release v0.2.0 — quality baseline"
git push --tags
```

Skip the `-s` (signed) flag if you haven't configured GPG/SSH signing. Signed tags are recommended but not required by any workflow gate.

## 7. Create GitHub release

```bash
# Extract the [Unreleased] section into a temp file and use as release notes:
node -e "
const cl=require('fs').readFileSync('CHANGELOG.md','utf8');
const m=cl.match(/## \[Unreleased\]([\s\S]*?)(?=## \[|$)/);
require('fs').writeFileSync('/tmp/v0.2.0-notes.md', m ? m[1].trim() : '(see CHANGELOG.md)');
"
gh release create v0.2.0 \
  --title "v0.2.0 — quality baseline" \
  --notes-file /tmp/v0.2.0-notes.md
```

Then update `CHANGELOG.md`: move the `[Unreleased]` block under a new `## [0.2.0] — 2026-04-18` heading, open a fresh empty `[Unreleased]` block, update the compare links at the bottom.

## 8. Post-release housekeeping

```bash
# Enable branch protection on main (one-time):
gh api repos/tornikebolokadze1-cyber/claude-code-setup/branches/main/protection \
  --method PUT \
  --input docs/branch-protection.json

# Verify the protection took effect:
gh api repos/tornikebolokadze1-cyber/claude-code-setup/branches/main/protection | head -20
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `gh: command not found` | `winget install GitHub.cli` then restart shell |
| `Permission denied (publickey)` on push | Switch to HTTPS: `git remote set-url origin https://github.com/tornikebolokadze1-cyber/claude-code-setup.git` |
| `remote rejected (pre-receive hook)` | Branch protection already enforced — push to a new branch and open PR |
| CI runner is `ubuntu-latest` but your authoring was Windows — CRLF warnings on every file | `git config --global core.autocrlf input` (keeps LF in repo, converts on checkout) |
| Smoke-test fails at `chmod` step | Ubuntu runs as root in Actions — unexpected mode preserves still pass; if fail, add `sudo` or drop the chmod step |

## After push, safe to delete locally

```bash
# Optional: prune the working clone after main contains the merge
cd ~
rm -rf "C:\Users\AI Pulse Georgia\claude-code-setup-work"
```

(Skip this if you plan to keep iterating.)
