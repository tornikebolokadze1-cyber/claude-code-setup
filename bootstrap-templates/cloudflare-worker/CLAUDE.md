# Cloudflare Worker — TypeScript + Wrangler 4

Edge API / webhook handler running on Cloudflare Workers. TypeScript strict mode,
Wrangler 4, built-in routing, CORS + logging middleware, HMAC webhook verification stub.

## Tech stack

- Node.js 20 LTS (for tooling only — Worker runtime is V8 Isolate)
- Wrangler 4.x (deploy, dev, tail, secret management)
- TypeScript 5.7 (strict, ES2023, `@cloudflare/workers-types`)
- Vitest 3 + `@cloudflare/vitest-pool-workers` (runs tests in the Workers runtime)
- ESLint 9 (flat config) + Prettier 3

## Build & test

| Command                              | Purpose                                    |
|--------------------------------------|--------------------------------------------|
| `npm install`                        | Install dependencies                       |
| `npm run dev`                        | Local dev with `wrangler dev` (port 8787)  |
| `npm run deploy`                     | Deploy to Cloudflare (`wrangler deploy`)   |
| `npm test`                           | Run tests (Vitest + workers pool)          |
| `npm run test:run`                   | Tests once (CI mode)                       |
| `npm run type-check`                 | TypeScript type check                      |
| `npm run lint`                       | ESLint                                     |
| `npx wrangler tail`                  | Stream live logs from deployed Worker      |
| `npx wrangler secret put SECRET_NAME`| Store a secret in Cloudflare               |

## Local development

Wrangler uses `.dev.vars` for secrets in local dev — these stay out of `wrangler.toml`:

```bash
cp .dev.vars.example .dev.vars
# Edit .dev.vars with local secret values
npm run dev
```

The worker will be available at `http://localhost:8787`.

## Routes

| Method | Path       | Handler                         |
|--------|------------|---------------------------------|
| GET    | `/health`  | Health check                    |
| POST   | `/webhook` | Inbound webhook (HMAC-verified) |
| *      | `*`        | 404 JSON response               |

## Environment / bindings

Secrets are injected as typed properties of the `Env` interface in `src/index.ts`.
Local values go in `.dev.vars`; production values are set via `wrangler secret put`.

KV and D1 binding examples are commented in `wrangler.toml` — uncomment and update
your binding names as needed.

## HMAC webhook verification

`src/routes/webhook.ts` includes a stub for HMAC-SHA256 signature verification.
Fill in your `WEBHOOK_SECRET` env var and the header name your provider uses
(e.g. `x-hub-signature-256` for GitHub, `stripe-signature` for Stripe).

## Security

- Never commit `.dev.vars` — it is in `.gitignore`
- Use `wrangler secret put` for production secrets (never `wrangler.toml` `[vars]` for secrets)
- Validate Content-Type on all POST requests before parsing body
- The CORS middleware is permissive by default — tighten `ALLOWED_ORIGINS` before production
- Rate limiting: use Cloudflare's built-in rate limiting rules in the dashboard

## Deployment

1. Authenticate: `npx wrangler login`
2. Set your `account_id` in `wrangler.toml`
3. Set secrets: `npx wrangler secret put WEBHOOK_SECRET`
4. Deploy: `npm run deploy`
5. Confirm: `curl https://<worker-name>.<subdomain>.workers.dev/health`

## When working with Claude in this project

- Keep the `Env` interface in `src/index.ts` as the single source of truth for bindings
- Add new routes in `src/lib/router.ts` and implement them in `src/routes/`
- Run `npm run type-check` before deploying — Workers types catch many runtime errors early
- Use `console.log()` for observability — it appears in `wrangler tail` and Cloudflare dashboard
