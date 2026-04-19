// ============================================================
// Shared types for the hybrid Code + n8n architecture
// ============================================================

/**
 * Payload received FROM n8n workflows via webhook callback.
 * n8n sends this to POST /api/webhooks/n8n after completing work.
 */
export interface N8nWebhookPayload {
  /** Event type identifier (e.g., "automation.completed") */
  event: string;
  /** The n8n workflow ID that sent this callback */
  workflowId: string;
  /** The n8n execution ID for tracing */
  executionId?: string;
  /** Arbitrary data payload from the workflow */
  data: Record<string, unknown>;
  /** ISO timestamp of when n8n sent this */
  timestamp?: string;
}

/**
 * Payload sent TO n8n workflows when triggering via webhook.
 * The code server sends this to start an n8n workflow.
 */
export interface N8nTriggerPayload {
  /** Action identifier for the workflow to process */
  action: string;
  /** Data the workflow needs to do its job */
  data: Record<string, unknown>;
  /** URL for n8n to call back when done (defaults to /api/webhooks/n8n) */
  callbackUrl?: string;
  /** Metadata for tracing and debugging */
  meta?: {
    source: string;
    correlationId?: string;
    userId?: string;
  };
}

/**
 * Response from triggering an n8n workflow.
 */
export interface N8nTriggerResponse {
  success: boolean;
  executionId?: string;
  data?: Record<string, unknown>;
  error?: string;
}

/**
 * Health check response shape.
 */
export interface HealthStatus {
  status: "ok" | "degraded" | "down";
  uptime: number;
  timestamp: string;
  services: {
    server: string;
    n8n: string;
  };
  environment: string;
}
