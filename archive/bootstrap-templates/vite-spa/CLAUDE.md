# Vite SPA — React 19 + Vite 6 + TypeScript 5.7

Fast single-page application with React 19, Vite 6, TypeScript strict mode, React Router 7,
Vitest 3, and Testing Library. No SSR. Deploys to any static host (Vercel, Netlify, Cloudflare Pages).

## Tech stack

- Node.js 20 LTS
- Vite 6 (build tool + dev server, port 5173)
- React 19 (concurrent features, automatic JSX runtime)
- TypeScript 5.7 (strict mode, ESNext)
- React Router 7 (client-side routing, `createBrowserRouter`)
- Vitest 3 + @testing-library/react 16 (unit + component tests, jsdom)
- ESLint 9 (flat config) + Prettier 3 (formatting)
- Path alias: `@/` → `src/`

## Build & test

| Command              | Purpose                                  |
|----------------------|------------------------------------------|
| `npm install`        | Install dependencies                     |
| `npm run dev`        | Dev server at http://localhost:5173      |
| `npm run build`      | Production build to `dist/`             |
| `npm run preview`    | Preview production build locally         |
| `npm test`           | Run tests in watch mode (Vitest)         |
| `npm run test:run`   | Run tests once (CI mode)                 |
| `npm run lint`       | ESLint check                             |
| `npm run type-check` | TypeScript type check (no emit)          |

## Code conventions

- All components are function components with explicit TypeScript interfaces for props
- Use `interface` for component props; `type` for unions and utility types
- Never use `any` — use `unknown` + type guards or proper generics
- Route components live in `src/routes/` and are lazy-loaded via React Router
- Shared UI primitives live in `src/components/ui/` — keep them generic and prop-driven
- Data-fetching logic goes in `src/hooks/` as custom hooks
- API calls go through `src/lib/api.ts` — never use `fetch` directly in components
- Environment variables accessed only through `src/lib/env.ts` — never `import.meta.env` directly

## Environment variables

Copy `.env.example` to `.env.local` for local development. All client-side env vars MUST be
prefixed `VITE_` to be exposed to the browser bundle. Never put secrets in `VITE_*` vars —
they are embedded in the built JS.

## Testing

- Tests co-located next to source: `Button.tsx` → `Button.test.tsx`
- Use `@testing-library/react` + `@testing-library/user-event` for component tests
- `src/setupTests.ts` runs before each test file (configures Testing Library)
- Target 80%+ line coverage on `src/lib/` and `src/hooks/`

## Security

- Never put API keys, secrets, or tokens in `VITE_*` env vars
- Validate all data from external APIs with Zod before rendering
- Use `Content-Security-Policy` header at the CDN/host layer (not configurable from Vite)
- Sanitize user-generated content before injecting into the DOM

## Deployment

- **Vercel / Netlify:** auto-detected Vite project; set `VITE_API_URL` in dashboard
- **Cloudflare Pages:** build command `npm run build`, output dir `dist`
- **Docker:** `nginx:alpine` serving `dist/`, with `try_files $uri /index.html` for SPA routing
- Ensure your host serves `index.html` for all routes (SPA fallback)

## When working with Claude in this project

- Before adding a new page, add its route in `src/App.tsx` using `createBrowserRouter`
- Keep `src/lib/api.ts` as the single integration point for backend calls
- Do NOT add server-side rendering — this is a pure SPA; use nextjs-webapp template instead
- Run `npm run type-check` and `npm run test:run` before committing
