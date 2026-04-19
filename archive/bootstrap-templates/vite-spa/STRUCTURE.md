# Vite SPA — Directory Structure

## Directory Tree

```
project-name/
├── .env.example              # Env var template (committed)
├── .env.local                # Local env vars (git-ignored)
├── .gitignore                # Vite + Node standard ignores
├── .prettierrc.json          # Prettier config
├── eslint.config.js          # ESLint 9 flat config
├── index.html                # HTML entry point (Vite convention)
├── package.json              # Dependencies and scripts
├── tsconfig.json             # TypeScript: composite root
├── tsconfig.app.json         # TypeScript: strict + ESNext (browser)
├── tsconfig.node.json        # TypeScript: for vite.config.ts (Node)
├── vite.config.ts            # Vite: React plugin, @/ alias, port 5173
├── vitest.config.ts          # Vitest: jsdom, setupFiles
├── public/
│   └── favicon.ico           # Static assets served at root
└── src/
    ├── main.tsx              # React 19 entry: createRoot + RouterProvider
    ├── App.tsx               # Router: createBrowserRouter + layout shell
    ├── setupTests.ts         # Vitest global setup (Testing Library)
    ├── styles/
    │   └── globals.css       # CSS reset + CSS custom properties
    ├── routes/
    │   ├── Home.tsx          # / — landing page
    │   ├── About.tsx         # /about
    │   └── NotFound.tsx      # * — 404 catch-all
    ├── components/
    │   └── ui/
    │       ├── Button.tsx    # Reusable button with variant prop
    │       └── Button.test.tsx  # Component test (Vitest + Testing Library)
    ├── hooks/
    │   └── use-fetch.ts      # Generic data-fetching hook with loading/error state
    ├── lib/
    │   ├── api.ts            # Typed fetch wrapper with error handling
    │   └── env.ts            # Runtime env variable validation (import.meta.env)
    └── types/
        └── index.ts          # Shared TypeScript types / interfaces
```

## Rationale

| Directory            | Purpose                                                    |
|----------------------|------------------------------------------------------------|
| `src/routes/`        | One file per page route; loaded by React Router            |
| `src/components/ui/` | Generic, reusable primitives (no business logic)           |
| `src/hooks/`         | Reusable stateful logic extracted from components          |
| `src/lib/`           | Pure utilities; no React imports; easy to unit-test        |
| `src/types/`         | Shared interfaces and type aliases                         |
| `src/styles/`        | Global CSS only; component styles co-located or CSS modules|
| `public/`            | Files copied verbatim to `dist/` — accessible at root URL  |

## Naming conventions

- Component files: `PascalCase.tsx` (e.g. `Button.tsx`)
- Non-component files: `kebab-case.ts` (e.g. `use-fetch.ts`, `api.ts`)
- Test files: co-located, `*.test.tsx` / `*.test.ts`
- CSS modules (if added): `Component.module.css`
