/**
 * Runtime environment variable validation.
 *
 * Access all env vars through this module — never use `import.meta.env`
 * directly in components or hooks. This gives you a single place to validate
 * and provides typed, narrowed values everywhere.
 *
 * Vite only exposes variables prefixed with VITE_ to the browser bundle.
 * Never store secrets in VITE_ variables — they are embedded in built JS.
 */

function requireEnv(key: string): string {
  const value = import.meta.env[key];
  if (value === undefined || value === "") {
    throw new Error(
      `Missing required environment variable: ${key}\n` +
        `Copy .env.example to .env.local and fill in the value.`
    );
  }
  return value as string;
}

function optionalEnv(key: string, defaultValue: string): string {
  const value = import.meta.env[key];
  return value !== undefined && value !== "" ? (value as string) : defaultValue;
}

export const env = {
  VITE_APP_TITLE: optionalEnv("VITE_APP_TITLE", "My App"),
  VITE_API_URL: requireEnv("VITE_API_URL"),
} as const;
