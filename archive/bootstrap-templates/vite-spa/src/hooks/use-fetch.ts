import { useState, useEffect, useCallback, useRef } from "react";
import { api, ApiError } from "@/lib/api";

export type FetchState<T> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: ApiError | Error };

export interface UseFetchOptions {
  /**
   * If false, the fetch will not execute automatically.
   * Call the returned `refetch` to trigger it manually.
   */
  enabled?: boolean;
}

/**
 * Generic data-fetching hook.
 *
 * Usage:
 *   const { state, refetch } = useFetch<User[]>("/users");
 */
export function useFetch<T>(
  endpoint: string,
  { enabled = true }: UseFetchOptions = {}
): { state: FetchState<T>; refetch: () => void } {
  const [state, setState] = useState<FetchState<T>>({ status: "idle" });
  const abortRef = useRef<AbortController | null>(null);

  const execute = useCallback(() => {
    // Cancel previous in-flight request
    abortRef.current?.abort();
    abortRef.current = new AbortController();

    setState({ status: "loading" });

    api
      .get<T>(endpoint, { signal: abortRef.current.signal })
      .then((data) => {
        setState({ status: "success", data });
      })
      .catch((err: unknown) => {
        // Ignore AbortError — component unmounted or refetch was called
        if (err instanceof DOMException && err.name === "AbortError") return;
        setState({
          status: "error",
          error: err instanceof Error ? err : new Error(String(err)),
        });
      });
  }, [endpoint]);

  useEffect(() => {
    if (enabled) {
      execute();
    }
    return () => {
      abortRef.current?.abort();
    };
  }, [enabled, execute]);

  return { state, refetch: execute };
}
