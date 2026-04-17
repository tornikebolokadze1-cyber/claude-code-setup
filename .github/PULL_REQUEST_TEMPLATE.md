## Summary

<!-- One or two sentences describing what this PR does. -->

## Motivation

<!-- Why is this change needed? Link to an issue if applicable. Closes #... -->

## What Changed

<!-- Bullet list of the key changes. Focus on *what* changed, not *how*. -->

-
-

## Testing Performed

<!-- Describe how you tested this. e.g. "Ran ./install.sh twice against ~/.claude.test/ on macOS 14." -->

**OS tested:** <!-- macOS / Ubuntu / Windows (Git Bash) -->

## Checklist

- [ ] README counts updated if rules / hooks / templates were added or removed
- [ ] New hook(s) tested on at least one OS (noted above)
- [ ] New rule file(s) are under 400 lines
- [ ] No secrets committed (API keys, tokens, passwords)
- [ ] `install.sh` is still idempotent (ran twice, no errors or duplicates)
- [ ] `hooks/settings-hooks.json` is valid JSON:
      `jq -e . hooks/settings-hooks.json`  
      *(no jq? use `node -e "JSON.parse(require('fs').readFileSync('hooks/settings-hooks.json'))"` )*
- [ ] Markdown renders correctly (checked GitHub preview or `markdownlint`)
- [ ] New bootstrap templates include `CLAUDE.md`, `.gitignore`, `README.md`, `.env.example` and were smoke-tested
