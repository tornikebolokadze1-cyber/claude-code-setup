import { ok, badRequest, unauthorized } from "../lib/responses";
import type { Env } from "../index";

/**
 * POST /webhook
 *
 * Inbound webhook handler with HMAC-SHA256 signature verification stub.
 *
 * To activate signature verification:
 * 1. Set WEBHOOK_SECRET via `wrangler secret put WEBHOOK_SECRET`
 * 2. Update SIGNATURE_HEADER to match your provider:
 *    - GitHub:  "x-hub-signature-256"
 *    - Stripe:  "stripe-signature"  (format differs — see Stripe docs)
 *    - Generic: "x-webhook-signature"
 * 3. Uncomment the `await verifySignature(...)` call below
 */

const SIGNATURE_HEADER = "x-webhook-signature";

/**
 * Verifies HMAC-SHA256 signature.
 * The signature is expected as "sha256=<hex-digest>".
 */
async function verifySignature(
  body: string,
  secret: string,
  signatureHeader: string
): Promise<boolean> {
  const expected = signatureHeader.startsWith("sha256=")
    ? signatureHeader.slice(7)
    : signatureHeader;

  const encoder = new TextEncoder();
  const keyData = encoder.encode(secret);
  const messageData = encoder.encode(body);

  const cryptoKey = await crypto.subtle.importKey(
    "raw",
    keyData,
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signatureBuffer = await crypto.subtle.sign("HMAC", cryptoKey, messageData);
  const computed = Array.from(new Uint8Array(signatureBuffer))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");

  // Constant-time comparison (simple version — use a proper timingSafeEqual for production)
  return expected.length === computed.length && expected === computed;
}

export async function handleWebhook(
  request: Request,
  env: Env,
  _ctx: ExecutionContext
): Promise<Response> {
  // Validate Content-Type
  const contentType = request.headers.get("content-type") ?? "";
  if (!contentType.includes("application/json")) {
    return badRequest("Content-Type must be application/json");
  }

  // Read body (needed for both signature verification and processing)
  let rawBody: string;
  try {
    rawBody = await request.text();
  } catch {
    return badRequest("Failed to read request body");
  }

  // ── HMAC Signature Verification ──────────────────────────────────────────
  // Uncomment the block below once WEBHOOK_SECRET is configured:
  //
  // const signature = request.headers.get(SIGNATURE_HEADER);
  // if (!signature) {
  //   return unauthorized("Missing signature header");
  // }
  // const isValid = await verifySignature(rawBody, env.WEBHOOK_SECRET, signature);
  // if (!isValid) {
  //   return unauthorized("Invalid signature");
  // }
  // ─────────────────────────────────────────────────────────────────────────

  // Parse payload
  let payload: unknown;
  try {
    payload = JSON.parse(rawBody);
  } catch {
    return badRequest("Invalid JSON body");
  }

  // TODO: Add your webhook event routing logic here
  // Example:
  //   const event = payload as { type: string; data: unknown };
  //   switch (event.type) {
  //     case "user.created": await handleUserCreated(event.data, env); break;
  //     default: console.log("Unhandled event type:", event.type);
  //   }

  console.log("Webhook received:", JSON.stringify(payload).slice(0, 200));

  // Suppress unused variable warning until HMAC verification is enabled
  void verifySignature;
  void SIGNATURE_HEADER;
  void unauthorized;

  return ok({ received: true });
}
