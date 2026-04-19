# Express Backend — TypeScript + Express + Vitest

TypeScript REST API using Express with Zod validation, centralized error handling, helmet security headers, and rate limiting.

## Tech stack

- Node.js 20 LTS
- TypeScript (strict mode)
- Express 4
- Zod (request validation at route boundaries)
- Helmet (security headers)
- express-rate-limit
- Vitest + Supertest (testing)
- ESLint + Prettier (code quality)

## Build & test

| Command | Purpose |
|---------|---------|
| `npm install` | Install dependencies |
| `npm run dev` | Start dev server with hot reload (ts-node) |
| `npm run build` | Compile TypeScript to `dist/` |
| `npm start` | Run compiled server from `dist/` |
| `npx vitest run` | Run full test suite |
| `npm run lint` | Run ESLint |
| `npm run format` | Run Prettier |

## Code conventions

- Validate all incoming requests with Zod schemas in middleware before handlers touch the data; schemas live alongside the route file
- All errors flow through the centralized `error-handler.ts` middleware — never send `res.json()` directly in catch blocks
- Use the `AppError` class for operational errors with explicit HTTP status codes
- No raw SQL — use a query builder (Knex) or ORM (Prisma) with parameterized queries only
- One route module per resource; mount all routes through `src/routes/index.ts`

## Security

- `helmet()` must be applied globally in `src/index.ts` before any routes
- Rate limiting is configured per-route in `src/middleware/rate-limit.ts`; auth endpoints default to 5 req/min
- Validate webhook signatures (HMAC-SHA256) before processing any inbound webhook payload
- Set `NODE_ENV=production` in deployment — disables verbose error details in responses
- Never log request bodies that may contain credentials; mask sensitive fields before logging

## Deployment

- Railway or Fly.io; Docker-ready (`NODE_ENV=production`, `npm run build && npm start`)
- Required env vars: `PORT`, `NODE_ENV`, `CORS_ORIGIN`
- Cold start is fast (compiled JS); keep `dist/` in the Docker image, not source

## When working with Claude in this project

- Always add Zod schema validation before adding business logic to a new route
- Prefer `express-async-errors` or explicit `next(error)` over unhandled promise rejections
- Do NOT commit `.env` — use `.env.example` as the tracked template
