import type { Express } from 'express';
import healthRouter from './health';

/**
 * Register all route modules on the Express application.
 * Add new routers here as the API grows.
 */
export function registerRoutes(app: Express): void {
  app.use(healthRouter);

  // Add additional route modules below:
  // app.use('/api/v1/users', usersRouter);
  // app.use('/api/v1/products', productsRouter);
}
