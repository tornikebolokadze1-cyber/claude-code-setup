# Development Workflow Standards

## 1. Research First (Before Writing Code)

MANDATORY before implementing any feature:

1. **Search existing solutions**: `gh search repos`, `gh search code`, npm/PyPI/crates.io
2. **Check library docs**: Verify API behavior and current versions
3. **Review existing codebase**: Look for similar patterns already implemented
4. **Port proven solutions** over building from scratch

Never reinvent what already exists and is well-maintained.

## 2. Planning Phase

For any non-trivial feature (3+ files):

1. Define the scope: what changes, what stays
2. Identify dependencies and risks
3. Break into phases with checkpoints
4. Consider: data model → backend logic → API → frontend → tests

## 3. TDD Workflow (RED → GREEN → IMPROVE)

For every feature and bugfix:

1. **RED**: Write a failing test that describes the desired behavior
2. **GREEN**: Write the minimum code to make the test pass
3. **IMPROVE**: Refactor while keeping tests green
4. Verify 80%+ coverage

For bug fixes specifically:
1. Write a test that reproduces the bug (RED)
2. Fix the bug (GREEN)
3. Verify the test now passes
4. This prevents regression forever

## 4. Code Review Integration

After implementation:
1. Self-review: re-read every changed file
2. Run full test suite
3. Check for: security, performance, readability
4. Address ALL critical and high severity issues before merge

## 5. Commit Standards

Conventional commits format:
```
type: description

[optional body]
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

Examples:
- `feat: add user email verification`
- `fix: prevent duplicate form submissions`
- `refactor: extract auth middleware from routes`
- `test: add integration tests for payment flow`

## 6. Branch Strategy

- `main` — production-ready code only
- `develop` — integration branch
- `feature/description` — new features
- `fix/description` — bug fixes
- `hotfix/description` — emergency production fixes

Never commit directly to main.

## 7. Pre-Merge Checklist

Before any PR merge:
- [ ] All tests pass (unit + integration + e2e)
- [ ] No linter warnings
- [ ] No type errors
- [ ] No console.log / debug statements
- [ ] No hardcoded secrets
- [ ] Documentation updated if API changed
- [ ] Commit messages follow convention
- [ ] Branch is up to date with target

## 8. Model Selection (Claude)

Choose the right model for the task:
- **Haiku**: Lightweight tasks, pair programming, frequent invocation
- **Sonnet**: Optimal for coding tasks and multi-agent coordination
- **Opus**: Deep reasoning, architectural planning, complex analysis

## 9. Context Management

- Avoid using the final 20% of context for large code modifications
- Use `/compact` before reaching 60% context usage
- For large changes: break into smaller sessions with handoff notes
