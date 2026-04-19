import type { Request, Response, NextFunction } from 'express';

/**
 * Standard API response envelope.
 */
export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: unknown;
  };
  meta?: {
    timestamp: string;
    requestId?: string;
  };
}

/**
 * Health check response payload.
 */
export interface HealthResponse {
  status: 'ok' | 'degraded' | 'down';
  timestamp: string;
  uptime: number;
  environment: string;
}

/**
 * Operational error with HTTP status code.
 * Throw this from any handler or service to return a structured error response.
 */
export class AppError extends Error {
  public readonly statusCode: number;
  public readonly code: string;
  public readonly isOperational: boolean;

  constructor(message: string, statusCode: number, code: string) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.isOperational = true;
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

/**
 * Typed Express request handler.
 */
export type AsyncHandler = (
  req: Request,
  res: Response,
  next: NextFunction,
) => Promise<void>;

/**
 * Pagination query parameters.
 */
export interface PaginationParams {
  page: number;
  limit: number;
  offset: number;
}

/**
 * Paginated response wrapper.
 */
export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

/**
 * Environment configuration type.
 */
export interface AppConfig {
  port: number;
  nodeEnv: string;
  corsOrigin: string;
  rateLimitWindowMs: number;
  rateLimitMax: number;
}
