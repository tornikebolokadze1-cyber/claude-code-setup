# Universal Production Coding Standards

These principles apply to ALL languages and frameworks.

---

## 1. Immutability First

- ALWAYS create new objects — NEVER mutate existing ones
- Use language-specific immutable constructs:
  - TS: `Readonly<T>`, spread operators, `Object.freeze()`
  - Python: `@dataclass(frozen=True)`, `tuple`, `frozenset`
  - Go: return new structs instead of modifying pointers
  - Rust: `let` by default, `let mut` only when needed
  - Swift: `let` over `var`, prefer structs over classes
  - Kotlin: `val` over `var`, `data class` for immutables

## 2. File Organization

- Many focused files > few large files
- Target: 200-400 lines per file, max 800
- One primary concept per file (one component, one service, one model)
- Group by feature/domain, not by type

## 3. Function Size

- Functions under 50 lines — extract when larger
- One responsibility per function
- Max 4 levels of nesting — extract to helper functions
- Name functions by what they DO, not how they do it

## 4. Error Handling

- ALWAYS handle errors at every level — never silently swallow
- Provide context: "failed to create user: database timeout"
- Use language-appropriate error types (not generic strings)
- Log errors where they are HANDLED, not where they are THROWN
- Never expose internal error details to users in production

## 5. Input Validation

- Validate at ALL system boundaries: user input, API responses, file reads
- Use schema validation libraries (Zod, Pydantic, etc.)
- Fail fast with clear error messages
- Sanitize all user input before rendering (XSS prevention)

## 6. Naming

- Variables/functions: describe WHAT, not HOW
- Booleans: `isActive`, `hasPermission`, `canEdit` — verb prefixes
- Collections: plural nouns (`users`, `items`)
- Functions: verb + noun (`createUser`, `validateEmail`, `fetchOrders`)
- Constants: SCREAMING_SNAKE_CASE for true constants
- No abbreviations except universally known (url, id, db, api)

## 7. Dependencies

- Minimize external dependencies — each one is a liability
- Before adding: check downloads, last update, known vulnerabilities
- Pin versions in production lock files
- Audit regularly: `npm audit`, `pip audit`, `go mod verify`

## 8. Configuration

- ZERO hardcoded values for: URLs, ports, credentials, feature flags
- Environment variables for deployment-specific config
- Config files for application defaults
- Validate all config at startup — fail fast if missing

## 9. Logging

- Structured logging (JSON format) in production
- Log levels: ERROR (broken), WARN (degraded), INFO (lifecycle), DEBUG (development)
- Include: timestamp, request_id, user_id, operation, duration
- NEVER log: passwords, tokens, PII, credit cards, session IDs

## 10. Code Quality Verification

Before considering code complete, verify:
- [ ] All functions < 50 lines
- [ ] All files < 800 lines
- [ ] Nesting depth ≤ 4 levels
- [ ] Error handling at every boundary
- [ ] No hardcoded config values
- [ ] Immutable patterns applied
- [ ] Tests written and passing
- [ ] No console.log/print in production code
