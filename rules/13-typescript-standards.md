# TypeScript/JavaScript Production Standards

## Type Safety
- Explicit types on ALL exported/public APIs; let TS infer locals
- `interface` for extensible object shapes, `type` for unions and utilities
- String literal unions instead of `enum` (e.g., `type Status = 'active' | 'inactive'`)
- Never use `any` — use `unknown` and narrow with type guards
- Validate external data with Zod: `const schema = z.object({...})` → `z.infer<typeof schema>`

## React Patterns
- Named `interface` or `type` for props — avoid `React.FC`
- Explicit callback types in props
- Use `useMemo`/`useCallback` only when profiler shows need — not everywhere
- Server Components by default (Next.js 14+); `'use client'` only when needed

## Immutability
- Spread operators for updates: `{ ...obj, field: newValue }`
- Mark parameters `Readonly<T>` where mutation is unwanted
- Prefer `const` always; `let` only when reassignment is unavoidable

## Error Handling
- `async/await` with `try-catch` — never unhandled promises
- Narrow `unknown` errors: `if (error instanceof Error) { ... }`
- Custom error classes for domain errors
- No `console.log` in production — use structured logging

## Patterns
- API responses: `{ success: boolean; data?: T; error?: { code: string; message: string }; meta?: { page: number; total: number } }`
- Repository pattern for data access with async CRUD interface
- Custom hooks: extract reusable logic; prefix with `use`

## Testing
- Framework: Vitest or Jest
- E2E: Playwright for critical user flows
- Naming: `describe('functionName', () => { it('should do X when Y', ...) })`
- Mock external APIs; test real business logic
- Coverage target: 80%+

## File Organization
- One component per file; co-locate tests (`component.test.tsx`)
- Barrel exports (`index.ts`) only at module boundary
- Max 400 lines per file; extract when larger
