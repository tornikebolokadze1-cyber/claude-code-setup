import { Router, Request, Response } from "express";
import crypto from "crypto";
import { N8nWebhookPayload } from "../types";

export const webhookRouter = Router();

/**
 * Verify the shared secret from n8n webhook calls.
 * n8n should send the secret in the X-Webhook-Secret header.
 */
function verifyWebhookSecret(req: Request): boolean {
  const secret = process.env.WEBHOOK_SHARED_SECRET;
  if (!secret) {
    console.warn("WEBHOOK_SHARED_SECRET not set - skipping verification");
    return true;
  }

  const provided = req.headers["x-webhook-secret"];
  if (!provided || typeof provided !== "string") {
    return false;
  }

  // Timing-safe comparison to prevent timing attacks
  return crypto.timingSafeEqual(
    Buffer.from(secret),
    Buffer.from(provided)
  );
}

/**
 * POST /api/webhooks/n8n
 *
 * Receives callbacks from n8n workflows.
 * n8n sends results here after completing automations.
 */
webhookRouter.post("/n8n", (req: Request, res: Response) => {
  // Verify shared secret
  if (!verifyWebhookSecret(req)) {
    console.error("Webhook secret verification failed");
    res.status(401).json({ error: "Unauthorized" });
    return;
  }

  const payload = req.body as N8nWebhookPayload;
  console.log(`Received n8n callback: event=${payload.event}, workflow=${payload.workflowId}`);

  // Route based on event type
  switch (payload.event) {
    case "automation.completed":
      handleAutomationCompleted(payload);
      break;
    case "notification.sent":
      handleNotificationSent(payload);
      break;
    case "sync.finished":
      handleSyncFinished(payload);
      break;
    default:
      console.log(`Unhandled event type: ${payload.event}`);
  }

  res.json({
    received: true,
    event: payload.event,
    timestamp: new Date().toISOString(),
  });
});

/**
 * GET /api/webhooks/n8n
 *
 * n8n can ping this to verify the endpoint is reachable.
 */
webhookRouter.get("/n8n", (_req: Request, res: Response) => {
  res.json({
    status: "ready",
    accepts: "POST",
    description: "n8n webhook callback endpoint",
  });
});

// --- Event Handlers ---

function handleAutomationCompleted(payload: N8nWebhookPayload): void {
  console.log("Automation completed:", payload.data);
  // TODO: Update database, notify user, etc.
}

function handleNotificationSent(payload: N8nWebhookPayload): void {
  console.log("Notification sent:", payload.data);
  // TODO: Log notification delivery status
}

function handleSyncFinished(payload: N8nWebhookPayload): void {
  console.log("Sync finished:", payload.data);
  // TODO: Process synced data, update records
}
