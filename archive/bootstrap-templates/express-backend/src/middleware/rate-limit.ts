import rateLimit from 'express-rate-limit';

/**
 * Default rate limiter: 100 requests per 15 minutes per IP.
 * Override via RATE_LIMIT_WINDOW_MS and RATE_LIMIT_MAX environment variables.
 */
export const defaultRateLimiter = rateLimit({
  windowMs: parseInt(process.env['RATE_LIMIT_WINDOW_MS'] ?? '900000', 10),
  max: parseInt(process.env['RATE_LIMIT_MAX'] ?? '100', 10),
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many requests. Please try again later.',
    },
    meta: { timestamp: new Date().toISOString() },
  },
});

/**
 * Strict rate limiter for sensitive endpoints (e.g., auth).
 * 10 requests per 15 minutes per IP.
 */
export const strictRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many requests to this endpoint. Please try again later.',
    },
    meta: { timestamp: new Date().toISOString() },
  },
});
