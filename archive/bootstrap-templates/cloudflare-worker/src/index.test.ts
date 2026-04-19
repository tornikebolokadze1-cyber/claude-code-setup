import { describe, it, expect } from "vitest";
import worker from "./index";
import type { Env } from "./index";

/**
 * Integration tests for the Worker's main routes.
 *
 * These tests run inside the Cloudflare Workers runtime via
 * @cloudflare/vitest-pool-workers, giving you accurate globals
 * and crypto.subtle availability.
 */

const mockEnv: Env = {
  ENVIRONMENT: "test",
  WEBHOOK_SECRET: "test-secret",
};

const mockCtx = {
  waitUntil: (_promise: Promise<unknown>) => {},
  passThroughOnException: () => {},
} as unknown as ExecutionContext;

function makeRequest(method: string, path: string, body?: unknown): Request {
  return new Request(`http://localhost${path}`, {
    method,
    headers: body ? { "Content-Type": "application/json" } : {},
    body: body ? JSON.stringify(body) : undefined,
  });
}

describe("GET /health", () => {
  it("returns 200 with status ok", async () => {
    const response = await worker.fetch(
      makeRequest("GET", "/health"),
      mockEnv,
      mockCtx
    );
    expect(response.status).toBe(200);
    const body = await response.json<{ success: boolean; data: { status: string } }>();
    expect(body.success).toBe(true);
    expect(body.data.status).toBe("ok");
  });

  it("includes environment in response", async () => {
    const response = await worker.fetch(
      makeRequest("GET", "/health"),
      mockEnv,
      mockCtx
    );
    const body = await response.json<{ data: { environment: string } }>();
    expect(body.data.environment).toBe("test");
  });
});

describe("POST /webhook", () => {
  it("returns 200 with received: true for valid JSON", async () => {
    const response = await worker.fetch(
      makeRequest("POST", "/webhook", { type: "test.event", data: {} }),
      mockEnv,
      mockCtx
    );
    expect(response.status).toBe(200);
    const body = await response.json<{ data: { received: boolean } }>();
    expect(body.data.received).toBe(true);
  });

  it("returns 400 for non-JSON content type", async () => {
    const request = new Request("http://localhost/webhook", {
      method: "POST",
      headers: { "Content-Type": "text/plain" },
      body: "plain text",
    });
    const response = await worker.fetch(request, mockEnv, mockCtx);
    expect(response.status).toBe(400);
  });
});

describe("Unknown route", () => {
  it("returns 404 for unregistered paths", async () => {
    const response = await worker.fetch(
      makeRequest("GET", "/does-not-exist"),
      mockEnv,
      mockCtx
    );
    expect(response.status).toBe(404);
  });
});

describe("CORS", () => {
  it("handles OPTIONS preflight with 204", async () => {
    const request = new Request("http://localhost/health", {
      method: "OPTIONS",
      headers: { Origin: "http://localhost:5173" },
    });
    const response = await worker.fetch(request, mockEnv, mockCtx);
    expect(response.status).toBe(204);
    expect(response.headers.get("Access-Control-Allow-Origin")).toBeTruthy();
  });
});
