export type { Database, Json } from "./database";

/**
 * Generic API response type
 */
export interface ApiResponse<T = unknown> {
  data?: T;
  error?: string;
  message?: string;
}

/**
 * Pagination params
 */
export interface PaginationParams {
  page: number;
  limit: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}
