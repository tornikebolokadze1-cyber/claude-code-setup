import { describe, it, expect } from "vitest";
import { GET } from "../src/app/health/route";

describe("GET /health", () => {
  it("returns healthy status with 200", async () => {
    const response = await GET();
    const body = await response.json();

    expect(response.status).toBe(200);
    expect(body.status).toBe("healthy");
    expect(body.timestamp).toBeDefined();
    expect(body.version).toBeDefined();
    expect(body.environment).toBeDefined();
    expect(typeof body.uptime).toBe("number");
  });
});
