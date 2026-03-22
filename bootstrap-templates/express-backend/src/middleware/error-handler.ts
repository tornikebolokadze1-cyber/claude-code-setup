import type { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { AppError } from '../types';
import type { ApiResponse } from '../types';
import { logger } from '../utils/logger';

/**
 * Global error handling middleware.
 * Must be registered LAST in the middleware chain (4-argument signature).
 */
export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  // Zod validation errors
  if (err instanceof ZodError) {
    const response: ApiResponse = {
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Request validation failed',
        details: err.errors.map((e) => ({
          path: e.path.join('.'),
          message: e.message,
        })),
      },
      meta: { timestamp: new Date().toISOString() },
    };
    res.status(400).json(response);
    return;
  }

  // Known operational errors
  if (err instanceof AppError) {
    const response: ApiResponse = {
      success: false,
      error: {
        code: err.code,
        message: err.message,
      },
      meta: { timestamp: new Date().toISOString() },
    };
    res.status(err.statusCode).json(response);
    return;
  }

  // Unexpected errors — log full stack, return generic message
  logger.error('Unhandled error', {
    name: err.name,
    message: err.message,
    stack: err.stack,
  });

  const response: ApiResponse = {
    success: false,
    error: {
      code: 'INTERNAL_SERVER_ERROR',
      message:
        process.env['NODE_ENV'] === 'production'
          ? 'An unexpected error occurred'
          : err.message,
    },
    meta: { timestamp: new Date().toISOString() },
  };
  res.status(500).json(response);
}

/**
 * 404 handler for unmatched routes.
 * Register AFTER all routes but BEFORE the error handler.
 */
export function notFoundHandler(req: Request, _res: Response, next: NextFunction): void {
  const error = new AppError(
    `Route not found: ${req.method} ${req.originalUrl}`,
    404,
    'NOT_FOUND',
  );
  next(error);
}
