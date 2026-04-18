# Next.js Web App — Next.js 14 + Supabase + Tailwind + Vitest

Full-stack web application using Next.js App Router, Supabase (auth + database), Tailwind CSS, shadcn/ui, and Zod-validated server actions.

## Tech stack

- Node.js 20 LTS
- Next.js 14 (App Router, Server Components by default)
- TypeScript (strict mode)
- Supabase (PostgreSQL + Auth + Storage)
- Tailwind CSS + shadcn/ui (styling and component library)
- Zod (server action and API route validation)
- Vitest + Testing Library (unit and component tests)
- ESLint + Prettier (code quality)

## Build & test

| Command | Purpose |
|---------|---------|
| `npm install` | Install dependencies |
| `npm run dev` | Start dev server (localhost:3000) |
| `npm run build` | Production build |
| `npm start` | Run production build locally |
| `npx vitest run` | Run full test suite |
| `npm run lint` | Run ESLint |

## Code conventions

- Default to Server Components; add `'use client'` only when the component needs browser APIs, event handlers, or React hooks
- Server actions live in `src/app/actions/`; validate all inputs with Zod before touching the database
- Follow shadcn/ui patterns: copy primitives into `src/components/ui/`, compose them in feature components
- Use Supabase server client (`src/lib/supabase/server.ts`) for data fetching in Server Components and Route Handlers; use browser client only in Client Components
- Keep `src/lib/` for pure utilities and helpers; avoid importing Next.js internals there

## Security

- Every Supabase table must have Row Level Security (RLS) policies enabled — no exceptions
- The `SUPABASE_SERVICE_ROLE_KEY` is server-only; never import it in Client Components or expose it via `NEXT_PUBLIC_*`
- CSP headers are enforced via `middleware.ts`; review before adding new external script or font sources
- Validate all server action inputs server-side with Zod even if client-side validation exists
- Never trust `userId` from the request body — always derive it from the Supabase session on the server

## Deployment

- Vercel (recommended); set up Preview and Production environments with separate Supabase projects
- Required env vars: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` (server-only)
- Run `supabase db push` or Supabase dashboard to apply migrations before deploying
- Cold start is minimal on Vercel Edge; keep middleware lightweight

## When working with Claude in this project

- Before adding a new data-fetching pattern, check whether it belongs in a Server Component, server action, or Route Handler
- Always add an RLS policy when creating a new Supabase table; Claude will remind you if you forget
- Do NOT commit `.env.local` — use `.env.example` as the tracked template
