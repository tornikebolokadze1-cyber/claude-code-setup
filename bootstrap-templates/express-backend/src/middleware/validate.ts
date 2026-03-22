import type { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';

/**
 * Specifies which parts of the request to validate.
 */
interface ValidationSchemas {
  body?: ZodSchema;
  query?: ZodSchema;
  params?: ZodSchema;
}

/**
 * Middleware factory that validates request data against Zod schemas.
 *
 * Usage:
 *   router.post('/users', validate({ body: createUserSchema }), createUser);
 *   router.get('/users/:id', validate({ params: userIdSchema }), getUser);
 */
export function validate(schemas: ValidationSchemas) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const errors: ZodError[] = [];

    if (schemas.body) {
      const result = schemas.body.safeParse(req.body);
      if (!result.success) {
        errors.push(result.error);
      } else {
        req.body = result.data;
      }
    }

    if (schemas.query) {
      const result = schemas.query.safeParse(req.query);
      if (!result.success) {
        errors.push(result.error);
      } else {
        (req as Request).query = result.data as typeof req.query;
      }
    }

    if (schemas.params) {
      const result = schemas.params.safeParse(req.params);
      if (!result.success) {
        errors.push(result.error);
      } else {
        req.params = result.data as typeof req.params;
      }
    }

    if (errors.length > 0) {
      // Merge all ZodErrors into a single error and pass to the error handler
      const combined = new ZodError(errors.flatMap((e) => e.errors));
      next(combined);
      return;
    }

    next();
  };
}
