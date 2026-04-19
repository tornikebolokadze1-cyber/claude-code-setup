/**
 * Merge class names conditionally (simple alternative to clsx/cn)
 */
export function cn(...classes: (string | undefined | null | false)[]): string {
  return classes.filter(Boolean).join(" ");
}

/**
 * Format a date to a locale string
 */
export function formatDate(date: Date | string): string {
  return new Date(date).toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

/**
 * Sleep for a given number of milliseconds
 */
export function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
