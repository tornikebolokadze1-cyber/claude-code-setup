# n8n Workflows

## Overview

This directory contains exported n8n workflow JSON files. These workflows run on the n8n cloud instance and integrate with the code server via webhooks.

**n8n Instance:** https://aipulsegeorgia2025.app.n8n.cloud

## Importing Workflows

### Via n8n UI
1. Open the n8n instance in your browser
2. Go to **Workflows** > **Add Workflow** (or use Ctrl+O / Cmd+O to import)
3. Click the three-dot menu > **Import from File**
4. Select the `.json` file from this directory
5. Update any credentials (API keys, OAuth tokens) in the workflow nodes
6. Activate the workflow

### Via n8n API
```bash
curl -X POST "https://aipulsegeorgia2025.app.n8n.cloud/api/v1/workflows" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -H "Content-Type: application/json" \
  -d @workflows/example-automation.json
```

## Workflow Files

| File                        | Description                                    |
| --------------------------- | ---------------------------------------------- |
| `example-automation.json`   | Receives data from code server, processes it, and calls back with results |

## Conventions

### Naming
- Workflow names: `[Project] - Description` (e.g., `[MyApp] - Send Welcome Email`)
- Webhook paths: `kebab-case` matching the action (e.g., `send-notification`)

### Callback Pattern
Every workflow that receives a trigger from the code server should:
1. Start with a **Webhook** node (trigger)
2. Do its work (send emails, call APIs, transform data, etc.)
3. End with an **HTTP Request** node that calls back to the code server
4. The callback URL: `POST {APP_URL}/api/webhooks/n8n`
5. Include `X-Webhook-Secret` header for authentication

### Security
- Always set the `X-Webhook-Secret` header when calling back to the code server
- Use n8n credentials for third-party API keys (never hardcode)
- Use production webhook URLs (not test URLs) in the code server config

## Exporting Workflows

To update a workflow file after editing in n8n:

1. Open the workflow in n8n
2. Click the three-dot menu > **Export as JSON**
3. Save to this directory, replacing the old file
4. Commit the change with a clear message

Or via API:
```bash
curl "https://aipulsegeorgia2025.app.n8n.cloud/api/v1/workflows/{id}" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" | jq . > workflows/my-workflow.json
```
