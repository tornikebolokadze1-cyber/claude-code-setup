# Architecture: Hybrid Code + n8n

## System Diagram

```
┌─────────────────────────────────────────────────────────┐
│                      USERS / CLIENTS                     │
│                  (Browser, Mobile, API)                   │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                                                          │
│              CODE SERVER (the Brain)                      │
│              Express.js / TypeScript                      │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌────────────────────┐     │
│  │  Routes   │  │ Services │  │    Database         │     │
│  │          │  │          │  │                    │     │
│  │ /api/*   │  │ Auth     │  │  Users, Orders,    │     │
│  │ /health  │  │ Business │  │  State, Logs       │     │
│  │ /webhooks│  │ N8nClient│  │                    │     │
│  └──────────┘  └────┬─────┘  └────────────────────┘     │
│                      │                                    │
└──────────────────────┼────────────────────────────────── ┘
                       │
          ┌────────────┼────────────┐
          │            │            │
          ▼            ▼            ▼
   ┌─────────┐  ┌──────────┐  ┌──────────┐
   │ Trigger  │  │ Trigger  │  │ Receive  │
   │ via      │  │ via      │  │ callback │
   │ Webhook  │  │ API      │  │ from n8n │
   └────┬─────┘  └────┬─────┘  └────▲─────┘
        │              │             │
        ▼              ▼             │
┌────────────────────────────────────┼────────────────────┐
│                                    │                     │
│              N8N INSTANCE (the Nervous System)           │
│              aipulsegeorgia2025.app.n8n.cloud            │
│                                    │                     │
│  ┌──────────────┐  ┌──────────────┴──────────────┐      │
│  │  Scheduled    │  │  Webhook-Triggered           │      │
│  │  Workflows    │  │  Workflows                   │      │
│  │              │  │                              │      │
│  │  - Daily sync │  │  - Process data              │      │
│  │  - Cleanup    │  │  - Send notifications        │      │
│  │  - Reports    │  │  - Call external APIs         │      │
│  └──────┬───────┘  └──────────────┬──────────────┘      │
│         │                         │                      │
│         ▼                         ▼                      │
│  ┌────────────────────────────────────────────┐         │
│  │           External Services                 │         │
│  │  Email, Slack, Stripe, Google Sheets, etc.  │         │
│  └────────────────────────────────────────────┘         │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## Responsibility Split

### CODE handles (the Brain)
- **User Interface** - Serving web pages, API responses
- **Authentication & Authorization** - Login, sessions, permissions
- **Complex Business Logic** - Calculations, validations, state machines
- **Database Operations** - CRUD, queries, migrations, transactions
- **Real-time Features** - WebSockets, live updates
- **Security** - Input validation, rate limiting, encryption

### N8N handles (the Nervous System)
- **Scheduled Tasks** - Cron jobs, periodic syncs, cleanup routines
- **Third-party Integrations** - Email (SendGrid), Slack, Google Sheets, CRMs
- **Notification Routing** - Deciding who gets notified and how
- **Data Pipelines** - ETL from external sources, data transformation
- **Retry Logic** - Automatic retries for flaky external APIs
- **Webhook Fan-out** - One event triggers multiple downstream actions

## Integration Points

### 1. Code triggers n8n (outbound)

The code server calls n8n webhook URLs to start workflows:

```typescript
const n8nClient = new N8nClient();
await n8nClient.triggerWebhook("send-notification", {
  action: "send-notification",
  data: { userId: "123", message: "Your order shipped" },
  callbackUrl: "https://myapp.com/api/webhooks/n8n",
  meta: { source: "order-service", correlationId: "abc-123" },
});
```

### 2. n8n calls back to code (inbound)

n8n workflows end with an HTTP Request node that POSTs results back:

```
POST /api/webhooks/n8n
Headers: { "X-Webhook-Secret": "shared-secret" }
Body: {
  "event": "notification.sent",
  "workflowId": "abc123",
  "executionId": "exec456",
  "data": { "delivered": true, "channel": "email" }
}
```

### 3. n8n scheduled workflows (autonomous)

Some workflows run on a schedule without code server involvement:
- Daily report generation
- Periodic data sync from external APIs
- Cleanup of stale records

These may still call back to the code server to store results.

## Data Flow Examples

### Example: New User Welcome Email

```
1. User signs up          → Code Server creates user in DB
2. Code triggers n8n      → POST /webhook/send-welcome-email
3. n8n workflow runs       → Sends email via SendGrid
4. n8n calls back         → POST /api/webhooks/n8n { event: "notification.sent" }
5. Code updates DB        → Mark welcome email as sent
```

### Example: Daily Sales Report

```
1. n8n cron trigger        → Every day at 9 AM
2. n8n queries code API    → GET /api/reports/daily-sales
3. n8n formats report      → Transform data into email-friendly format
4. n8n sends email         → Via SendGrid to sales team
5. n8n calls back          → POST /api/webhooks/n8n { event: "sync.finished" }
```

## Security

- **Shared Secret**: Both directions use `X-Webhook-Secret` header with timing-safe comparison
- **HTTPS**: All webhook URLs must use HTTPS in production
- **n8n API Key**: Used only server-side, never exposed to clients
- **IP Allowlisting**: Consider restricting webhook endpoints to n8n's IP range
