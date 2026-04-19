#!/usr/bin/env node
// patch-settings-2026.mjs
// Patches ~/.claude/settings.json to add 2026-era improvements:
//   1. MCP lazy-loading via `enabledMcpServers` array (reduces context by ~95%)
//   2. New 2026 hook events: ConfigChange, PostCompact, SessionEnd
//
// Safe:
//   - Creates a timestamped backup before writing.
//   - Dry-run by default; pass --execute to apply.
//   - Preserves all existing keys. Only adds.
//
// Usage:
//   node scripts/patch-settings-2026.mjs             # dry-run (shows diff)
//   node scripts/patch-settings-2026.mjs --execute   # apply changes
//
// Respects CLAUDE_CONFIG_DIR (falls back to ~/.claude).

import { existsSync, readFileSync, writeFileSync, copyFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const CONFIG_DIR = process.env.CLAUDE_CONFIG_DIR || join(homedir(), ".claude");
const SETTINGS = join(CONFIG_DIR, "settings.json");
const args = process.argv.slice(2);
const EXECUTE = args.includes("--execute") || args.includes("-x");

if (!existsSync(SETTINGS)) {
  console.error(`settings.json not found at ${SETTINGS}`);
  process.exit(1);
}

const raw = readFileSync(SETTINGS, "utf-8");
let cfg;
try {
  cfg = JSON.parse(raw);
} catch (e) {
  console.error(`Invalid JSON in ${SETTINGS}: ${e.message}`);
  process.exit(1);
}

const changes = [];

// ---------- 1. MCP lazy-loading ----------
// If any MCP servers are configured via mcpServers or enabledMcpjsonServers,
// make sure enabledMcpServers is explicitly listed (triggers lazy-load mode).
const mcpKeys = new Set();
for (const key of ["mcpServers", "enabledMcpjsonServers", "mcp"]) {
  const v = cfg[key];
  if (v && typeof v === "object") {
    for (const k of Object.keys(v)) mcpKeys.add(k);
  }
}
if (mcpKeys.size > 0 && !Array.isArray(cfg.enabledMcpServers)) {
  cfg.enabledMcpServers = [...mcpKeys];
  changes.push(`+ enabledMcpServers: [${[...mcpKeys].join(", ")}] (lazy-load)`);
} else if (Array.isArray(cfg.enabledMcpServers)) {
  changes.push(`= enabledMcpServers already present (${cfg.enabledMcpServers.length} servers)`);
} else {
  changes.push(`- no MCP servers detected; skipping lazy-load patch`);
}

// ---------- 2. New 2026 hook events ----------
cfg.hooks ||= {};

function addHookEvent(name, entry) {
  const cur = cfg.hooks[name];
  if (Array.isArray(cur) && cur.length > 0) {
    changes.push(`= hooks.${name} already configured (${cur.length} entries); leaving alone`);
    return;
  }
  cfg.hooks[name] = [entry];
  changes.push(`+ hooks.${name} added`);
}

// ConfigChange: log any settings mutation mid-session
addHookEvent("ConfigChange", {
  matcher: "*",
  hooks: [{
    type: "command",
    command: 'mkdir -p "$HOME/.claude/audit-logs" && echo "[$(date -u +%FT%TZ)] ConfigChange" >> "$HOME/.claude/audit-logs/config-changes.log"'
  }]
});

// PostCompact: mark that context was compacted (helpful for debugging)
addHookEvent("PostCompact", {
  matcher: "*",
  hooks: [{
    type: "command",
    command: 'mkdir -p "$HOME/.claude/audit-logs" && echo "[$(date -u +%FT%TZ)] PostCompact" >> "$HOME/.claude/audit-logs/session-events.log"'
  }]
});

// SessionEnd: append session summary
addHookEvent("SessionEnd", {
  matcher: "manual|timeout",
  hooks: [{
    type: "command",
    command: 'mkdir -p "$HOME/.claude/audit-logs" && echo "[$(date -u +%FT%TZ)] SessionEnd" >> "$HOME/.claude/audit-logs/session-events.log"'
  }]
});

// ---------- Report ----------
console.log("Planned changes to", SETTINGS);
for (const c of changes) console.log("  " + c);

if (!EXECUTE) {
  console.log("\nDRY-RUN. Re-run with --execute to apply.");
  process.exit(0);
}

// Backup
const stamp = new Date().toISOString().replace(/[:.]/g, "-");
const backup = `${SETTINGS}.backup-${stamp}`;
copyFileSync(SETTINGS, backup);
console.log(`\nBackup: ${backup}`);

writeFileSync(SETTINGS, JSON.stringify(cfg, null, 2) + "\n", "utf-8");
console.log(`Wrote ${SETTINGS}`);
