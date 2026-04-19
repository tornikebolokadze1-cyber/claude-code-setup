# {{PROJECT_NAME}}

> Cloudflare Worker — TypeScript + Wrangler 4

Edge API / webhook handler on Cloudflare Workers. Includes typed routing,
CORS + logging middleware, and an HMAC webhook verification stub.

## Prerequisites

- Node.js 20+
- A Cloudflare account (free tier works)
- Wrangler CLI (installed as a dev dependency)

## Getting started

```bash
# 1. Install dependencies
npm install

# 2. Set up local secrets
cp .dev.vars.example .dev.vars
# Edit .dev.vars with local values

# 3. Start local dev server
npm run dev
# → http://localhost:8787
```

## Authentication (first deploy)

```bash
# Log in to Cloudflare
npx wrangler login

# Set your account_id in wrangler.toml (find in Cloudflare dashboard)

# Set production secrets
npx wrangler secret put WEBHOOK_SECRET

# Deploy
npm run deploy
```

## Available scripts

| Script                  | Description                           |
|-------------------------|---------------------------------------|
| `npm run dev`           | Local dev with `wrangler dev`         |
| `npm run deploy`        | Deploy to Cloudflare                  |
| `npm test`              | Vitest in watch mode                  |
| `npm run test:run`      | Tests once (CI mode)                  |
| `npm run type-check`    | TypeScript type check                 |
| `npm run lint`          | ESLint                                |
| `npx wrangler tail`     | Stream live logs from deployed Worker |

## Routes

| Method | Path       | Description             |
|--------|------------|-------------------------|
| GET    | `/health`  | Health check            |
| POST   | `/webhook` | Inbound webhook handler |

## Environment & secrets

| Variable         | Where set              | Description               |
|------------------|------------------------|---------------------------|
| `ENVIRONMENT`    | `wrangler.toml [vars]` | "production" / "staging"  |
| `WEBHOOK_SECRET` | `wrangler secret put`  | HMAC secret for webhooks  |

Local dev: copy `.dev.vars.example` → `.dev.vars` and fill in values.
Production: `npx wrangler secret put WEBHOOK_SECRET`.

**Never put secrets in `wrangler.toml` `[vars]` — those are committed to git.**

## Adding KV / D1 bindings

1. Create the resource: `npx wrangler kv namespace create MY_KV`
2. Uncomment the binding in `wrangler.toml` and paste the returned ID
3. Add the binding to the `Env` interface in `src/index.ts`
4. Use it in handlers: `env.KV.get("key")`

## Project structure

See [STRUCTURE.md](./STRUCTURE.md) for the full annotated directory tree.

## Tech stack

- [Wrangler 4](https://developers.cloudflare.com/workers/wrangler/) — deploy + dev CLI
- [TypeScript 5.7](https://www.typescriptlang.org) — type safety
- [@cloudflare/workers-types](https://github.com/cloudflare/workers-types) — Workers globals
- [Vitest 3](https://vitest.dev) + [@cloudflare/vitest-pool-workers](https://github.com/cloudflare/workers-vitest) — tests in the Workers runtime
- [ESLint 9](https://eslint.org) + [Prettier 3](https://prettier.io) — code quality
