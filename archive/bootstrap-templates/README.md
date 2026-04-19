# Bootstrap Templates — Which one do I pick?

9 pre-configured project starters. Use this guide to pick the right one.

---

## Decision tree

```
Do you need a UI?
├── Yes, web UI
│   ├── Need SEO, server-rendered pages, or auth middleware?
│   │   └── → nextjs-webapp  (Next.js 15 + Supabase + Tailwind + App Router)
│   ├── Just a fast SPA, no SSR needed?
│   │   └── → vite-spa  (React 19 + Vite 6 + React Router 7)
│   └── Need server-rendered UI from a Python backend?
│       └── → fastapi-backend  (FastAPI + Jinja2 templates)
│
├── Yes, chat/messaging UI
│   └── → telegram-bot  (python-telegram-bot async)
│
└── No UI — pure backend / service
    ├── Deploy to the edge / serverless?
    │   └── → cloudflare-worker  (TS Worker + Wrangler 4)
    ├── Node/TypeScript server (REST or webhook handler)?
    │   └── → express-backend  (Express 5 + TypeScript)
    ├── Python server (REST API or ML backend)?
    │   └── → fastapi-backend  (FastAPI + Pydantic + SQLAlchemy)
    ├── Runs as an AI agent with tools and memory?
    │   └── → ai-agent  (LangChain + LangGraph)
    ├── Visual workflow automation (no-code / low-code)?
    │   └── → n8n-workflow  (n8n JSON workflows + deploy scripts)
    └── Mix of code + n8n automation?
        └── → hybrid-code-n8n  (Express/FastAPI + n8n client + webhooks)
```

---

## Feature matrix

| Template            | Stack                             | Auth example         | Tests            | Observability-ready | Deploy target            |
|---------------------|-----------------------------------|----------------------|------------------|---------------------|--------------------------|
| `nextjs-webapp`     | Next.js 15, React 19, TypeScript  | Supabase Auth + RLS  | Vitest + TL      | Console + Vercel    | Vercel / any Node host   |
| `vite-spa`          | React 19, Vite 6, TypeScript      | Bring your own       | Vitest + TL      | Console             | Vercel / CF Pages / S3   |
| `fastapi-backend`   | FastAPI, Pydantic, SQLAlchemy     | JWT stub             | pytest           | Structured logging  | Railway / Fly.io / Docker|
| `express-backend`   | Express 5, TypeScript             | JWT stub             | Jest / Vitest    | Morgan / Winston    | Railway / Fly.io / Docker|
| `ai-agent`          | LangChain, LangGraph, Python      | None (internal tool) | pytest           | LangSmith stub      | Cloud Run / Modal        |
| `telegram-bot`      | python-telegram-bot 21.x          | Telegram user ID     | pytest           | Console             | VPS / Railway            |
| `cloudflare-worker` | TS Worker, Wrangler 4             | Bring your own       | Vitest (workers) | wrangler tail       | Cloudflare Workers       |
| `n8n-workflow`      | n8n (JSON workflows)              | n8n credentials      | None (manual)    | n8n execution logs  | n8n Cloud / self-hosted  |
| `hybrid-code-n8n`   | Express/FastAPI + n8n client      | Webhook tokens       | Jest / pytest    | Dual (code + n8n)   | Any + n8n Cloud          |

---

## Stability labels

Templates are graded on how much customisation they need before production use:

### Production-ready (works out of the box, fully functional)

- **`nextjs-webapp`** — App Router, Supabase auth, route groups, Vitest, middleware
- **`fastapi-backend`** — Pydantic models, routers, schemas, config validation
- **`vite-spa`** — React 19, Vite 6, React Router 7, typed API client, Vitest
- **`cloudflare-worker`** — Router, CORS, logging, HMAC stub, Workers Vitest

### Near-ready (solid structure, needs domain customisation)

- **`express-backend`** — Error handler, rate limiting, health route; add your auth layer
- **`ai-agent`** — LangGraph shape with planner/executor/reviewer; plug in your tools
- **`telegram-bot`** — Handlers for start/help/echo; add your command logic

### Docs-heavy skeletons (good reference architecture, lighter on runnable code)

- **`n8n-workflow`** — Example JSON workflow + deploy scripts; requires n8n instance
- **`hybrid-code-n8n`** — Architecture doc + integration stubs; glue code needed

---

## Template conventions

Every template in this repository ships with the following files:

| File               | Purpose                                                              |
|--------------------|----------------------------------------------------------------------|
| `CLAUDE.md`        | Project-specific Claude guidance (how to run, test, deploy)         |
| `STRUCTURE.md`     | Annotated directory tree with rationale for each folder             |
| `.env.example`     | All required environment variable names with placeholder values     |
| `.gitignore`       | Stack-appropriate ignore rules                                       |
| `README.md`        | Human getting-started guide                                          |
| Working test command | `npm test` / `pytest` — runs out of the box                       |

**If you add a new template**, ensure all six items above are present before opening a PR.
Update this file's decision tree, feature matrix, and stability label.

---

## Roadmap (Phase 2)

Templates planned for the next release:

| Template             | Stack                               | Status  |
|----------------------|-------------------------------------|---------|
| `sveltekit-app`      | SvelteKit 2, Vite, TypeScript       | Planned |
| `remotion-video`     | Remotion 4, React, TypeScript       | Planned |
| `cli-tool`           | Commander (Node) or Typer (Python)  | Planned |
| `react-native-app`   | Expo 52, React Native, TypeScript   | Planned |

To request a template, open an issue with the `template-request` label.
