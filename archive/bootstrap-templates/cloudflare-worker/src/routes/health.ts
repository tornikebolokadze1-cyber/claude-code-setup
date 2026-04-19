import { ok } from "../lib/responses";
import type { Env } from "../index";

/**
 * GET /health
 *
 * Returns 200 with uptime and environment info.
 * Used by load balancers, uptime monitors, and CI smoke tests.
 */
export function handleHealth(
  _request: Request,
  env: Env,
  _ctx: ExecutionContext
): Response {
  return ok({
    status: "ok",
    environment: env.ENVIRONMENT,
    timestamp: new Date().toISOString(),
  });
}
