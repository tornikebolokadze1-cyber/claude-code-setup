import { Router } from 'express';
import type { HealthResponse, ApiResponse } from '../types';

const router = Router();
const startTime = Date.now();

/**
 * GET /health
 * Liveness / readiness probe.
 * Returns current server status, uptime in seconds, and environment.
 */
router.get('/health', (_req, res) => {
  const health: HealthResponse = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: Math.floor((Date.now() - startTime) / 1000),
    environment: process.env['NODE_ENV'] ?? 'development',
  };

  const response: ApiResponse<HealthResponse> = {
    success: true,
    data: health,
    meta: { timestamp: health.timestamp },
  };

  res.status(200).json(response);
});

export default router;
