import { Router, Request, Response } from "express";
import { N8nClient } from "../services/n8n-client";

export const healthRouter = Router();

/**
 * GET /health
 *
 * Returns health status of both the code server and n8n connectivity.
 */
healthRouter.get("/", async (_req: Request, res: Response) => {
  const n8nClient = new N8nClient();
  let n8nStatus = "unknown";

  try {
    const reachable = await n8nClient.ping();
    n8nStatus = reachable ? "connected" : "unreachable";
  } catch {
    n8nStatus = "error";
  }

  const health = {
    status: "ok",
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    services: {
      server: "running",
      n8n: n8nStatus,
    },
    environment: process.env.NODE_ENV || "development",
  };

  const httpStatus = n8nStatus === "error" ? 503 : 200;
  res.status(httpStatus).json(health);
});
