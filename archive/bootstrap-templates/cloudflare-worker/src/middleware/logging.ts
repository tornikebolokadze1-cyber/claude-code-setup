/**
 * Request/response logging middleware.
 *
 * Logs method, path, status, and duration.
 * Output is visible in `wrangler tail` and the Cloudflare dashboard.
 */

export async function withLogging(
  request: Request,
  next: () => Promise<Response> | Response
): Promise<Response> {
  const start = Date.now();
  const { method, url } = request;
  const path = new URL(url).pathname;

  let response: Response;
  try {
    response = await next();
  } catch (err) {
    const duration = Date.now() - start;
    console.error(
      JSON.stringify({
        method,
        path,
        status: 500,
        duration_ms: duration,
        error: err instanceof Error ? err.message : String(err),
      })
    );
    throw err;
  }

  const duration = Date.now() - start;
  console.log(
    JSON.stringify({
      method,
      path,
      status: response.status,
      duration_ms: duration,
    })
  );

  return response;
}
