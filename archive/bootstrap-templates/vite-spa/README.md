# {{PROJECT_NAME}}

> React 19 + Vite 6 + TypeScript SPA

## Prerequisites

- Node.js 20+
- npm 10+

## Getting started

```bash
# 1. Install dependencies
npm install

# 2. Set up environment variables
cp .env.example .env.local
# Edit .env.local — set VITE_API_URL to your backend

# 3. Start the dev server
npm run dev
# → http://localhost:5173
```

## Available scripts

| Script                  | Description                          |
|-------------------------|--------------------------------------|
| `npm run dev`           | Dev server with HMR                  |
| `npm run build`         | Production build to `dist/`          |
| `npm run preview`       | Preview production build             |
| `npm test`              | Vitest in watch mode                 |
| `npm run test:run`      | Vitest single run (CI)               |
| `npm run test:coverage` | Coverage report                      |
| `npm run lint`          | ESLint check                         |
| `npm run lint:fix`      | ESLint auto-fix                      |
| `npm run type-check`    | TypeScript type check                |

## Project structure

See [STRUCTURE.md](./STRUCTURE.md) for the full annotated directory tree.

## Adding a new page

1. Create `src/routes/MyPage.tsx`
2. Add the route in `src/App.tsx`:
   ```tsx
   { path: "my-page", element: <MyPage /> }
   ```
3. Add a `<NavLink to="/my-page">` in `RootLayout`

## Environment variables

| Variable         | Required | Description               |
|------------------|----------|---------------------------|
| `VITE_APP_TITLE` | No       | App title shown in the UI |
| `VITE_API_URL`   | Yes      | Base URL for backend API  |

All `VITE_*` variables are embedded in the built JS bundle — **do not put secrets here**.

## Deployment

### Vercel / Netlify
Auto-detected Vite project. Set `VITE_API_URL` in the dashboard under Environment Variables.

### Cloudflare Pages
- Build command: `npm run build`
- Output directory: `dist`
- Add a redirect rule: `/* → /index.html` (200) for SPA routing

### Docker
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
# nginx.conf must include: try_files $uri /index.html;
```

## Tech stack

- [Vite 6](https://vite.dev) — build tool
- [React 19](https://react.dev) — UI library
- [TypeScript 5.7](https://www.typescriptlang.org) — type safety
- [React Router 7](https://reactrouter.com) — client-side routing
- [Vitest 3](https://vitest.dev) — testing
- [Testing Library](https://testing-library.com) — component tests
- [ESLint 9](https://eslint.org) + [Prettier 3](https://prettier.io) — code quality
