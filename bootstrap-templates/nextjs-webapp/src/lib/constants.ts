export const APP_NAME = "{{PROJECT_NAME}}";
export const APP_DESCRIPTION = "Built with Next.js 14, TypeScript, Tailwind, and Supabase";

export const ROUTES = {
  HOME: "/",
  LOGIN: "/login",
  DASHBOARD: "/dashboard",
  HEALTH: "/health",
  API: {
    EXAMPLE: "/api/example",
    AUTH_CALLBACK: "/api/auth/callback",
  },
} as const;
