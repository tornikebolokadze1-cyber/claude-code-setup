import { withCors } from "./middleware/cors";
import { withLogging } from "./middleware/logging";
import { createRouter } from "./lib/router";
import { handleHealth } from "./routes/health";
import { handleWebhook } from "./routes/webhook";

/**
 * Env interface — defines all bindings and secrets available to this Worker.
 *
 * Secrets are injected by Wrangler at runtime; they never appear in source.
 * - Local dev: set in .dev.vars
 * - Production: set with `wrangler secret put SECRET_NAME`
 *
 * Bindings (KV, D1, R2) are declared in wrangler.toml and typed here.
 */
export interface Env {
  ENVIRONMENT: string;
  WEBHOOK_SECRET: string;

  // Uncomment as you add bindings in wrangler.toml:
  // KV: KVNamespace;
  // DB: D1Database;
  // BUCKET: R2Bucket;
}

const router = createRouter<Env>();

router.get("/health", handleHealth);
router.post("/webhook", handleWebhook);

export default {
  async fetch(
    request: Request,
    env: Env,
    ctx: ExecutionContext
  ): Promise<Response> {
    return withLogging(request, () =>
      withCors(request, () => router.handle(request, env, ctx))
    );
  },
} satisfies ExportedHandler<Env>;
