# Express + TypeScript Backend Template

## Directory Structure

```
express-backend/
├── package.json            # Dependencies and scripts
├── tsconfig.json           # TypeScript configuration (strict mode, path aliases)
├── .env.example            # Environment variable template
├── STRUCTURE.md            # This file
├── src/
│   ├── index.ts            # Application entry point — creates and starts the Express server
│   ├── routes/
│   │   ├── index.ts        # Route registry — mounts all route modules onto the app
│   │   └── health.ts       # GET /health — liveness/readiness probe endpoint
│   ├── middleware/
│   │   ├── error-handler.ts  # Global error handling middleware (catches all unhandled errors)
│   │   ├── validate.ts       # Zod-based request validation middleware factory
│   │   └── rate-limit.ts     # Rate limiting configuration (express-rate-limit)
│   ├── utils/
│   │   └── logger.ts       # Structured console logger with ISO timestamps and log levels
│   └── types/
│       └── index.ts        # Shared TypeScript types and interfaces
└── tests/
    └── health.test.ts      # Integration test for the health endpoint (supertest + jest)
```

## Quick Start

```bash
npm install
cp .env.example .env
npm run dev          # Development with hot reload (ts-node)
npm run build        # Compile TypeScript to dist/
npm start            # Run compiled JavaScript from dist/
npm test             # Run Jest test suite
npm run lint         # Run ESLint
npm run format       # Run Prettier
```

## Architecture Decisions

- **Validation**: Zod schemas validate request body, query, and params at the middleware layer before reaching handlers.
- **Error Handling**: A centralized error handler catches all thrown errors and returns consistent JSON responses. Operational errors use the `AppError` class with HTTP status codes.
- **Rate Limiting**: Configured per-route or globally. Defaults to 100 requests per 15-minute window per IP.
- **Logging**: A lightweight logger utility with `info`, `warn`, `error`, and `debug` levels. No external dependency — replace with Winston or Pino when scaling.
- **Security**: Helmet sets secure HTTP headers. CORS is configured via environment variables. Rate limiting prevents abuse.

## Environment Variables

| Variable       | Default                | Description                        |
|----------------|------------------------|------------------------------------|
| `PORT`         | `3000`                 | Server listen port                 |
| `NODE_ENV`     | `development`          | Environment (development/production/test) |
| `CORS_ORIGIN`  | `*`                    | Allowed CORS origins               |
| `RATE_LIMIT_WINDOW_MS` | `900000`       | Rate limit window in milliseconds  |
| `RATE_LIMIT_MAX`       | `100`          | Max requests per window per IP     |
