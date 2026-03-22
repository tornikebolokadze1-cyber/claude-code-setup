import { N8nTriggerPayload, N8nTriggerResponse } from "../types";

/**
 * N8nClient - Service for triggering n8n workflows.
 *
 * Communicates with n8n via:
 * 1. Webhook triggers (production URLs) - for triggering specific workflows
 * 2. n8n API - for managing workflows programmatically
 */
export class N8nClient {
  private instanceUrl: string;
  private apiKey: string;
  private webhookSecret: string;

  constructor() {
    this.instanceUrl = process.env.N8N_INSTANCE_URL || "";
    this.apiKey = process.env.N8N_API_KEY || "";
    this.webhookSecret = process.env.WEBHOOK_SHARED_SECRET || "";
  }

  /**
   * Trigger an n8n workflow via its production webhook URL.
   *
   * In n8n, set up a Webhook node as the trigger. Use the production URL
   * (not test URL) so the workflow runs without the n8n editor open.
   */
  async triggerWebhook(
    webhookPath: string,
    data: N8nTriggerPayload
  ): Promise<N8nTriggerResponse> {
    const url = `${this.instanceUrl}/webhook/${webhookPath}`;

    console.log(`Triggering n8n webhook: ${url}`);

    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Webhook-Secret": this.webhookSecret,
      },
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(
        `n8n webhook failed (${response.status}): ${errorText}`
      );
    }

    const result = await response.json();
    return {
      success: true,
      executionId: result.executionId,
      data: result,
    };
  }

  /**
   * Trigger a workflow by ID using the n8n API.
   * Requires N8N_API_KEY to be set.
   */
  async triggerWorkflow(
    workflowId: string,
    data?: Record<string, unknown>
  ): Promise<N8nTriggerResponse> {
    if (!this.apiKey) {
      throw new Error("N8N_API_KEY is required to trigger workflows via API");
    }

    const url = `${this.instanceUrl}/api/v1/workflows/${workflowId}/execute`;

    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-N8N-API-KEY": this.apiKey,
      },
      body: JSON.stringify(data ? { data } : {}),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(
        `n8n API call failed (${response.status}): ${errorText}`
      );
    }

    const result = await response.json();
    return {
      success: true,
      executionId: result.data?.executionId,
      data: result.data,
    };
  }

  /**
   * Check if the n8n instance is reachable.
   */
  async ping(): Promise<boolean> {
    if (!this.instanceUrl) return false;

    try {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), 5000);

      const response = await fetch(`${this.instanceUrl}/healthz`, {
        method: "GET",
        signal: controller.signal,
      });

      clearTimeout(timeout);
      return response.ok;
    } catch {
      return false;
    }
  }
}
