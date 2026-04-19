import { env } from "./env";

export class ApiError extends Error {
  constructor(
    message: string,
    public readonly status: number,
    public readonly body: unknown
  ) {
    super(message);
    this.name = "ApiError";
  }
}

type RequestOptions = Omit<RequestInit, "body"> & {
  body?: unknown;
};

/**
 * Typed fetch wrapper that:
 * - Prepends VITE_API_URL to relative paths
 * - Serialises JSON request bodies
 * - Throws ApiError for non-2xx responses
 * - Returns parsed JSON
 */
async function request<T>(
  endpoint: string,
  { body, headers, ...options }: RequestOptions = {}
): Promise<T> {
  const url = endpoint.startsWith("http")
    ? endpoint
    : `${env.VITE_API_URL}${endpoint}`;

  const response = await fetch(url, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...headers,
    },
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });

  if (!response.ok) {
    let errorBody: unknown;
    try {
      errorBody = await response.json();
    } catch {
      errorBody = await response.text();
    }
    throw new ApiError(
      `HTTP ${response.status} ${response.statusText}`,
      response.status,
      errorBody
    );
  }

  // Handle 204 No Content
  if (response.status === 204) {
    return undefined as T;
  }

  return response.json() as Promise<T>;
}

export const api = {
  get: <T>(endpoint: string, options?: Omit<RequestOptions, "body">) =>
    request<T>(endpoint, { method: "GET", ...options }),

  post: <T>(endpoint: string, body: unknown, options?: RequestOptions) =>
    request<T>(endpoint, { method: "POST", body, ...options }),

  put: <T>(endpoint: string, body: unknown, options?: RequestOptions) =>
    request<T>(endpoint, { method: "PUT", body, ...options }),

  patch: <T>(endpoint: string, body: unknown, options?: RequestOptions) =>
    request<T>(endpoint, { method: "PATCH", body, ...options }),

  delete: <T>(endpoint: string, options?: RequestOptions) =>
    request<T>(endpoint, { method: "DELETE", ...options }),
};
