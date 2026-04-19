# Cloudflare Worker — Directory Structure

## Directory Tree

```
project-name/
├── .dev.vars.example         # Local secret template (committed)
├── .dev.vars                 # Local secrets (git-ignored)
├── .env.example              # Non-secret local config (committed)
├── .gitignore                # CF Worker + Node ignores
├── .prettierrc.json          # Prettier config
├── eslint.config.js          # ESLint 9 flat config
├── package.json              # Dependencies and scripts
├── tsconfig.json             # TypeScript: ES2023, Workers types
├── vitest.config.ts          # Vitest: workers pool
├── wrangler.toml             # Wrangler config (name, compat date, bindings)
└── src/
    ├── index.ts              # Entry: Env interface + fetch handler
    ├── index.test.ts         # Integration tests for main routes
    ├── lib/
    │   ├── router.ts         # Minimal request router (method + path matching)
    │   └── responses.ts      # JSON response helpers (ok, error, notFound)
    ├── middleware/
    │   ├── cors.ts           # CORS headers middleware
    │   └── logging.ts        # Request/response logging middleware
    └── routes/
        ├── health.ts         # GET /health
        └── webhook.ts        # POST /webhook with HMAC signature stub
```

## Rationale

| File / Dir             | Purpose                                                       |
|------------------------|---------------------------------------------------------------|
| `wrangler.toml`        | Wrangler config: name, compat date, KV/D1 binding examples   |
| `src/index.ts`         | Worker entry; defines `Env` + chains middleware → router     |
| `src/lib/router.ts`    | Keeps `index.ts` clean; one route registration = one call    |
| `src/lib/responses.ts` | Consistent JSON shape for all responses                      |
| `src/middleware/`      | Cross-cutting concerns (CORS, logging) applied in `index.ts` |
| `src/routes/`          | One handler per logical endpoint                             |
| `.dev.vars`            | Wrangler's local equivalent of `.env.local` (gitignored)     |

## Naming conventions

- All source files are `kebab-case.ts`
- Exported handler functions: `handleHealth`, `handleWebhook`, etc.
- Middleware: `withCors(request, next)`, `withLogging(request, next)`
