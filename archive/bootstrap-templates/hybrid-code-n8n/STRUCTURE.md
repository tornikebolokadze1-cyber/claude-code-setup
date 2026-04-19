# Hybrid Code + n8n Project Structure

## Architecture Philosophy

**CODE = Brain** (complex logic, state, decisions)
**N8N = Nervous System** (connections, triggers, routing, reactions)

```
project-root/
├── CLAUDE.md                 # AI assistant rules for this hybrid project
├── STRUCTURE.md              # This file
├── package.json              # Node.js dependencies
├── tsconfig.json             # TypeScript config
├── .env.example              # Environment template
├── .env                      # Local environment (git-ignored)
│
├── src/                      # APPLICATION CODE (the Brain)
│   ├── index.ts              # Entry point - Express server
│   ├── routes/
│   │   ├── webhook.ts        # Receives callbacks FROM n8n workflows
│   │   └── health.ts         # Health check endpoint
│   ├── services/
│   │   └── n8n-client.ts     # Triggers n8n workflows via webhook/API
│   └── types/
│       └── index.ts          # Shared TypeScript types
│
├── workflows/                # N8N WORKFLOWS (the Nervous System)
│   ├── README.md             # How to import/manage n8n workflows
│   └── example-automation.json  # Example workflow JSON
│
└── docs/
    └── architecture.md       # Detailed architecture diagram
```

## How It Works

### Code Side (this repo)
- Runs as a standard Node.js/Express server
- Handles HTTP requests, auth, database, complex business logic
- Exposes webhook endpoints that n8n can call
- Triggers n8n workflows when automations are needed

### n8n Side (cloud instance)
- Runs on the n8n cloud instance
- Handles scheduled tasks, third-party integrations, notifications
- Calls back to the code server via webhooks
- Manages retry logic and error handling for external services

### Integration Flow

```
[User Request] → [Code Server] → (complex logic) → [n8n Webhook Trigger]
                                                            ↓
                                                    [n8n Workflow]
                                                    (send email, call API, etc.)
                                                            ↓
                                                    [n8n HTTP Request Node]
                                                            ↓
                                              [Code Server /api/webhooks/n8n]
                                              (process result, update DB)
```

## When to Put Logic Where

| Put in CODE                        | Put in N8N                          |
| ---------------------------------- | ----------------------------------- |
| User authentication                | Scheduled data syncs                |
| Database CRUD                      | Email/Slack notifications           |
| Complex business rules             | Third-party API integrations        |
| UI/API serving                     | Data transformation pipelines       |
| Real-time processing               | Retry-heavy external calls          |
| Stateful operations                | Cron-triggered automations          |
| Security-critical logic            | Webhook routing and fan-out         |
