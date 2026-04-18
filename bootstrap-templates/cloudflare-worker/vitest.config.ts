import { defineWorkersConfig } from "@cloudflare/vitest-pool-workers/config";

// Use the Workers-specific config for tests that run inside the Workers runtime.
// For pure unit tests (no Workers globals), you can use plain defineConfig instead.
export default defineWorkersConfig({
  test: {
    poolOptions: {
      workers: {
        wrangler: { configPath: "./wrangler.toml" },
      },
    },
  },
});
