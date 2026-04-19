/**
 * JSON response helpers.
 *
 * Use these instead of `new Response(JSON.stringify(...))` directly so that
 * Content-Type and status codes are applied consistently across the Worker.
 */

const JSON_HEADERS = {
  "Content-Type": "application/json",
} as const;

export function ok<T>(data: T, status = 200): Response {
  return new Response(JSON.stringify({ success: true, data }), {
    status,
    headers: JSON_HEADERS,
  });
}

export function created<T>(data: T): Response {
  return ok(data, 201);
}

export function error(
  message: string,
  status = 500,
  code?: string
): Response {
  return new Response(
    JSON.stringify({
      success: false,
      error: { code: code ?? `HTTP_${status}`, message },
    }),
    { status, headers: JSON_HEADERS }
  );
}

export function notFound(message = "Not found"): Response {
  return error(message, 404, "NOT_FOUND");
}

export function badRequest(message: string): Response {
  return error(message, 400, "BAD_REQUEST");
}

export function unauthorized(message = "Unauthorized"): Response {
  return error(message, 401, "UNAUTHORIZED");
}

export function methodNotAllowed(): Response {
  return error("Method not allowed", 405, "METHOD_NOT_ALLOWED");
}
