# Hybrid Code + n8n Project Rules

## Architecture

This project uses a **hybrid architecture**:
- **Code Server** (TypeScript/Express) = the Brain. Handles complex logic, auth, database, UI.
- **n8n Workflows** (cloud) = the Nervous System. Handles integrations, triggers, routing, notifications.
- **Integration**: Bidirectional webhooks with shared secret authentication.

## n8n Instance

- **URL**: https://aipulsegeorgia2025.app.n8n.cloud
- Use `n8n_update_partial_workflow` for workflow edits (saves 80-90% tokens)
- Use `n8n_workflow_versions` before making changes (rollback safety)
- NEVER edit production workflows directly -- copy first

## Decision: Code vs n8n

### Put in CODE when:
- It needs database access or transactions
- It involves authentication or authorization
- It requires complex conditional logic or state machines
- It needs sub-second response times
- It handles sensitive data processing

### Put in N8N when:
- It connects to a third-party service (email, Slack, Sheets, etc.)
- It runs on a schedule (cron)
- It needs automatic retry logic
- It fans out one event to multiple actions
- It transforms and routes data between services
- It is a "glue" workflow connecting systems

### Grey area (use judgment):
- Simple API-to-API calls: n8n (unless latency matters)
- Data validation before external send: code
- Error notification: n8n
- Complex error recovery: code

## Webhook Conventions

### Code to n8n (triggering workflows)
```typescript
// Use the N8nClient service
const client = new N8nClient();
await client.triggerWebhook("webhook-path", {
  action: "action-name",
  data: { ... },
  callbackUrl: `${APP_URL}/api/webhooks/n8n`,
  meta: { source: "service-name" }
});
```

### n8n to Code (callbacks)
- Endpoint: `POST /api/webhooks/n8n`
- Always include `X-Webhook-Secret` header
- Body must follow `N8nWebhookPayload` type (see `src/types/index.ts`)
- Event types: `automation.completed`, `notification.sent`, `sync.finished`

### n8n Webhook Data Access
- In Webhook nodes: data is in `$json.body`, NOT `$json`
- In expressions: use `={{ }}` with `=` prefix
- In Code nodes: no braces, return `[{json: {...}}]`

## Testing Integrations

### Local development
1. Run the code server: `npm run dev`
2. Use ngrok for public URL: `ngrok http 3000`
3. Update n8n workflow callback URLs to ngrok URL
4. Test webhook endpoint: `curl -X POST http://localhost:3000/api/webhooks/n8n -H "Content-Type: application/json" -d '{"event":"test","workflowId":"test","data":{}}'`

### Testing n8n workflows
1. Open workflow in n8n editor
2. Use the **Test** button (uses test webhook URL)
3. Send a test trigger from code or curl
4. Check execution log in n8n for errors

### Integration test checklist
- [ ] Code server can trigger n8n webhook (check n8n execution log)
- [ ] n8n workflow can call back to code server (check server logs)
- [ ] Shared secret is verified on both sides
- [ ] Error cases return appropriate HTTP status codes
- [ ] Timeout handling works (n8n default: 300s)

## Security

- **WEBHOOK_SHARED_SECRET**: Must be set in both `.env` (code) and n8n environment variables
- Generate with: `openssl rand -hex 32`
- The code server uses timing-safe comparison (`crypto.timingSafeEqual`)
- Never log the secret value
- Rotate secrets by updating both sides simultaneously

## File Structure Quick Reference

```
src/index.ts              # Express server entry point
src/routes/webhook.ts     # Receives n8n callbacks
src/routes/health.ts      # Health check (includes n8n connectivity)
src/services/n8n-client.ts # Triggers n8n workflows
src/types/index.ts        # Shared types for webhook payloads
workflows/*.json          # Exported n8n workflow files
```

## Common Commands

```bash
npm run dev          # Start dev server with hot reload
npm run build        # Compile TypeScript
npm start            # Run compiled server
npm run lint         # Lint code
```
