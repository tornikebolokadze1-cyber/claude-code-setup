# Next.js 14 + TypeScript + Tailwind + Supabase

## Directory Tree

```
project-name/
├── .env.local                  # Local environment variables (git-ignored)
├── .env.example                # Template for env vars (committed)
├── .eslintrc.json              # ESLint configuration
├── .gitignore                  # Git ignore rules
├── next.config.mjs             # Next.js configuration
├── package.json                # Dependencies and scripts
├── postcss.config.mjs          # PostCSS for Tailwind
├── tailwind.config.ts          # Tailwind CSS configuration
├── tsconfig.json               # TypeScript configuration
├── middleware.ts               # Auth middleware (Supabase)
├── src/
│   ├── app/                    # App Router (Next.js 14)
│   │   ├── layout.tsx          # Root layout (Server Component)
│   │   ├── page.tsx            # Home page (Server Component)
│   │   ├── globals.css         # Global styles + Tailwind directives
│   │   ├── health/
│   │   │   └── route.ts        # GET /health — API health check
│   │   ├── api/
│   │   │   ├── auth/
│   │   │   │   └── callback/
│   │   │   │       └── route.ts  # Supabase auth callback
│   │   │   └── example/
│   │   │       └── route.ts      # Example API route
│   │   ├── (auth)/             # Auth route group
│   │   │   ├── login/
│   │   │   │   └── page.tsx    # Login page (Client Component)
│   │   │   └── layout.tsx      # Auth layout
│   │   └── (dashboard)/        # Protected route group
│   │       ├── dashboard/
│   │       │   └── page.tsx    # Dashboard page
│   │       └── layout.tsx      # Dashboard layout
│   ├── components/
│   │   ├── ui/                 # Reusable UI primitives
│   │   │   └── button.tsx      # Button component
│   │   ├── forms/              # Form components
│   │   ├── layouts/            # Layout components
│   │   │   └── header.tsx      # Header component
│   │   └── providers/          # Context providers
│   │       └── supabase-provider.tsx
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── client.ts       # Browser Supabase client
│   │   │   ├── server.ts       # Server Supabase client
│   │   │   └── middleware.ts   # Middleware Supabase client
│   │   ├── utils.ts            # Utility functions
│   │   └── constants.ts        # App constants
│   ├── hooks/                  # Custom React hooks
│   │   └── use-user.ts         # User auth hook
│   └── types/
│       ├── database.ts         # Supabase DB types
│       └── index.ts            # Shared types
├── tests/
│   ├── health.test.ts          # Health endpoint test
│   └── setup.ts                # Test setup
└── supabase/
    ├── config.toml             # Supabase local config
    └── migrations/             # Database migrations
        └── .gitkeep
```
