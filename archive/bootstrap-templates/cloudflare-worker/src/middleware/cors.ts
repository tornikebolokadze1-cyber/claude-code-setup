/**
 * CORS middleware.
 *
 * Adds Access-Control-* headers to every response.
 * Handles OPTIONS preflight requests automatically.
 *
 * TODO: Replace ALLOWED_ORIGINS with your production domain(s) before deploying.
 *       Never use "*" for requests that include credentials (cookies, auth headers).
 */

const ALLOWED_ORIGINS = [
  "http://localhost:5173",  // Vite SPA dev server
  "http://localhost:3000",  // Next.js dev server
  // "https://your-production-domain.com",
];

const CORS_HEADERS = {
  "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Request-ID",
  "Access-Control-Max-Age": "86400",
} as const;

function getAllowOriginHeader(request: Request): string {
  const origin = request.headers.get("Origin") ?? "";
  return ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];
}

export async function withCors(
  request: Request,
  next: () => Promise<Response> | Response
): Promise<Response> {
  const allowOrigin = getAllowOriginHeader(request);

  // Handle preflight
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": allowOrigin,
        ...CORS_HEADERS,
      },
    });
  }

  const response = await next();

  // Clone and add CORS headers
  const headers = new Headers(response.headers);
  headers.set("Access-Control-Allow-Origin", allowOrigin);
  Object.entries(CORS_HEADERS).forEach(([key, value]) => {
    headers.set(key, value);
  });

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
