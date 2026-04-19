import { notFound } from "./responses";
import type { Env } from "../index";

type Handler<E> = (
  request: Request,
  env: E,
  ctx: ExecutionContext
) => Promise<Response> | Response;

interface Route<E> {
  method: string;
  pattern: URLPattern;
  handler: Handler<E>;
}

/**
 * Minimal request router.
 *
 * Registers GET/POST/PUT/PATCH/DELETE handlers by method + path pattern.
 * Unmatched requests receive a 404 JSON response.
 *
 * Usage:
 *   const router = createRouter<Env>();
 *   router.get("/health", handleHealth);
 *   router.post("/webhook", handleWebhook);
 *   export default { fetch: (req, env, ctx) => router.handle(req, env, ctx) };
 */
export function createRouter<E = Env>() {
  const routes: Route<E>[] = [];

  function register(method: string, path: string, handler: Handler<E>) {
    routes.push({
      method: method.toUpperCase(),
      pattern: new URLPattern({ pathname: path }),
      handler,
    });
  }

  return {
    get: (path: string, handler: Handler<E>) => register("GET", path, handler),
    post: (path: string, handler: Handler<E>) => register("POST", path, handler),
    put: (path: string, handler: Handler<E>) => register("PUT", path, handler),
    patch: (path: string, handler: Handler<E>) => register("PATCH", path, handler),
    delete: (path: string, handler: Handler<E>) => register("DELETE", path, handler),

    handle(
      request: Request,
      env: E,
      ctx: ExecutionContext
    ): Promise<Response> | Response {
      const url = new URL(request.url);

      for (const route of routes) {
        if (
          route.method === request.method &&
          route.pattern.test({ pathname: url.pathname })
        ) {
          return route.handler(request, env, ctx);
        }
      }

      return notFound();
    },
  };
}
