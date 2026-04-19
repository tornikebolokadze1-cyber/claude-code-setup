import dotenv from 'dotenv';
dotenv.config();

import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { registerRoutes } from './routes';
import { errorHandler, notFoundHandler } from './middleware/error-handler';
import { defaultRateLimiter } from './middleware/rate-limit';
import { logger } from './utils/logger';
import type { AppConfig } from './types';

const config: AppConfig = {
  port: parseInt(process.env['PORT'] ?? '3000', 10),
  nodeEnv: process.env['NODE_ENV'] ?? 'development',
  corsOrigin: process.env['CORS_ORIGIN'] ?? '*',
  rateLimitWindowMs: parseInt(process.env['RATE_LIMIT_WINDOW_MS'] ?? '900000', 10),
  rateLimitMax: parseInt(process.env['RATE_LIMIT_MAX'] ?? '100', 10),
};

export function createApp(): express.Express {
  const app = express();

  // --- Security middleware ---
  app.use(helmet());
  app.use(
    cors({
      origin: config.corsOrigin,
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
      credentials: true,
    }),
  );

  // --- Rate limiting ---
  app.use(defaultRateLimiter);

  // --- Body parsing ---
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // --- Routes ---
  registerRoutes(app);

  // --- Error handling (must be last) ---
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

// Start the server only when this file is executed directly (not imported by tests)
if (require.main === module) {
  const app = createApp();
  app.listen(config.port, () => {
    logger.info(`Server started on port ${config.port} [${config.nodeEnv}]`);
  });
}
