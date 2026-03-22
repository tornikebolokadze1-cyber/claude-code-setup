# Architecture

## Overview

This document describes how the n8n workflows in this project are organized,
how they connect to each other, and how data flows through them.

## Workflow Categories

### Trigger Workflows

Entry points that start automation flows. These listen for external events.

| Trigger Type   | Description                              | Example                     |
|----------------|------------------------------------------|-----------------------------|
| **Webhook**    | HTTP endpoints that receive POST/GET     | API integrations, forms     |
| **Schedule**   | Cron-based time triggers                 | Daily reports, hourly syncs |
| **App Trigger**| Events from connected apps (Slack, etc.) | New message, new row        |
| **Manual**     | Triggered by hand or via API call        | One-off tasks, testing      |

### Processing Workflows

Core logic that transforms, validates, routes, and enriches data.

Common patterns:
- **If/Switch** nodes for conditional routing
- **Code** nodes for custom transformations (return `[{json: {...}}]`)
- **Merge** nodes to combine data from multiple sources
- **Loop Over Items** for batch processing

### Integration Workflows

Connect to external services (databases, APIs, SaaS tools).

- Use n8n credential management for all secrets
- Prefer built-in nodes over raw HTTP Request nodes when available
- Handle rate limits with Wait nodes and error handling

## Data Flow

```
External Event
      │
      ▼
┌─────────────┐
│   Trigger    │  (Webhook, Schedule, App Event)
└─────┬───────┘
      │
      ▼
┌─────────────┐
│  Validate    │  (If node — check required fields)
└─────┬───────┘
      │
  ┌───┴───┐
  │       │
  ▼       ▼
Valid   Invalid
  │       │
  ▼       ▼
┌──────┐ ┌──────────┐
│Process│ │Error Resp│
└──┬───┘ └──────────┘
   │
   ▼
┌─────────────┐
│   Output     │  (Respond, Store, Notify)
└─────────────┘
```

## Workflow-to-Workflow Communication

n8n workflows can call each other using these patterns:

1. **Execute Workflow node** — One workflow triggers another by ID, passing data
   directly. Best for synchronous sub-workflows.
2. **Webhook chaining** — One workflow sends an HTTP request to another workflow's
   webhook URL. Best for decoupled, independently deployable workflows.
3. **Shared data stores** — Workflows read/write to a common database, spreadsheet,
   or queue. Best for async processing pipelines.

## Error Handling

- Use **Error Trigger** workflows to catch failures globally.
- Add **error outputs** on critical nodes to handle failures gracefully.
- Log errors to a central location (database, Slack channel, or logging service).
- Use **retry on fail** settings for transient errors (API timeouts, rate limits).

## Environment Strategy

| Environment | Instance / Tag  | Purpose                          |
|-------------|-----------------|----------------------------------|
| Development | `[DEV]` prefix  | Building and testing workflows   |
| Staging     | `[STAGING]`     | Pre-production validation        |
| Production  | `[PROD]` prefix | Live workflows serving real data |

Always copy a production workflow before making changes. Never edit `[PROD]`
workflows directly.
