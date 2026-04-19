/**
 * Shared TypeScript types and interfaces.
 *
 * Keep this file for domain-level types shared across multiple modules.
 * Component-specific props and API response shapes should live closer to
 * their usage (in the component or lib file).
 */

/** Generic paginated API response wrapper */
export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    page: number;
    pageSize: number;
    total: number;
    totalPages: number;
  };
}

/** Standard API error response shape */
export interface ApiErrorResponse {
  code: string;
  message: string;
  details?: Record<string, string[]>;
}

/** Example domain type — replace with your own */
export interface User {
  id: string;
  email: string;
  displayName: string;
  createdAt: string;
}
