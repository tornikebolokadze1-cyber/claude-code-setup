# Observability Standards

Every production service must be observable. If you cannot measure it, you cannot fix it.
These rules establish the minimum baseline for logs, metrics, and traces as of April 2026.

---

## 1. The Three Pillars

Observability is built from three complementary signals. Each answers a different question:

| Pillar | Question answered | Example tools |
|--------|-------------------|---------------|
| **Logs** | What happened and when? | Axiom, Datadog Logs, Loki, CloudWatch |
| **Metrics** | Is the system healthy right now? | Prometheus + Grafana, Datadog, Cloudflare Analytics |
| **Traces** | Where did this request spend its time? | Honeycomb, Jaeger, Datadog APM, Sentry Performance |

All three are required for production. Logs alone are insufficient. Metrics without traces
leave you blind to which code path caused a spike.

---

## 2. Structured Logging — Mandatory Fields

Every log line MUST be valid JSON in production. No free-text log lines.

### Minimum required fields

```json

{
  "timestamp": "2026-04-18T14:32:01.123Z",
  "level": "info",
  "service": "api-gateway",
  "version": "1.4.2",
  "request_id": "req_01HZ3K9F2BNRV8A",
  "user_id": "usr_abc123",
  "operation": "createOrder",
  "duration_ms": 142,
  "status": "success"
}

```text

Field rules:

- `timestamp` — ISO 8601 UTC always. Never local time.
- `level` — one of: `error`, `warn`, `info`, `debug`. No other values.
- `service` — matches the deployment unit name (e.g. `nextjs-webapp`, `fastapi-backend`).
- `version` — semver of the deployed artifact. Populated from `process.env.APP_VERSION`.
- `request_id` — propagated from the `X-Request-Id` header; generated if absent. See Section 6.
- `user_id` — omit entirely (do not set to `null`) if the request is unauthenticated.
- `operation` — the function or route name being executed. Human-readable, no spaces.
- `duration_ms` — wall-clock time for the operation. Always an integer.
- `status` — `success` or `error`. For HTTP: map 2xx → `success`, 4xx/5xx → `error`.

## 3. Log Levels — When to Use Each

| Level | Use when | Example |
|-------|----------|---------|
| `error` | The operation failed and user impact occurred | Database timeout, payment declined, file not found |
| `warn` | The operation succeeded but something was unexpected | Slow query (>2s), retry succeeded, deprecated field used |
| `info` | Normal lifecycle events worth recording | Request received, order created, user logged in |
| `debug` | Detailed internal state useful for diagnosis | Function entry/exit, intermediate values, cache hit/miss |

- Production environments: log `error`, `warn`, and `info`. Never `debug` in prod (volume + PII risk).
- Staging environments: log all four levels.
- Development environments: log all four levels, pretty-printed is acceptable.

---

## 4. Metrics — RED Method (Web Services)

Apply the RED method to every HTTP service and gRPC endpoint:

| Metric | Definition | Alert threshold |
|--------|-----------|-----------------|
| **Rate** | Requests per second | Page if drops to 0 (service down) |
| **Errors** | Error rate as % of total requests | Page if >1% sustained for 5 min |
| **Duration** | p50, p95, p99 latency in milliseconds | Page if p99 > 2000ms for 5 min |

Minimum metric set per service:

```text

http_requests_total{method, route, status_code}        # counter
http_request_duration_seconds{method, route, quantile} # summary/histogram
http_requests_in_flight                                 # gauge

```text

---

## 5. Metrics — USE Method (Infrastructure / Workers)

Apply the USE method to every host, worker, database, and queue:

| Metric | Definition | Alert threshold |
|--------|-----------|-----------------|
| **Utilization** | % of time the resource is busy | Warn at 70%, page at 90% |
| **Saturation** | Work queued waiting for the resource | Page if queue depth > 1000 or growing |
| **Errors** | Error count or rate | Page if error rate > 0.1% |

Minimum metric set per database:

```text

db_connections_active                      # gauge
db_connections_idle                        # gauge
db_query_duration_seconds{operation}       # histogram
db_errors_total{error_type}               # counter

```text

### Metric cardinality limits

High-cardinality labels destroy Prometheus performance. Rules:

- NEVER use user IDs, request IDs, or UUIDs as label values.
- NEVER use full URLs as label values — normalize to route patterns (`/api/users/:id`).
- Maximum unique label combinations per metric: 10,000.
- If you need per-user data, use logs or traces, not metrics.

---

## 6. Distributed Tracing

### Correlation ID propagation

Every inbound HTTP request MUST have an `X-Request-Id` header.
Generate one if absent and echo it back in the response. Propagate it unchanged to all
downstream service calls.

### OpenTelemetry (OTel) — the default standard as of 2026

Use OpenTelemetry SDKs for all new instrumentation. It is vendor-neutral and supported by every
major observability platform. Never use vendor-specific trace SDKs -- they create lock-in.
The OTLP exporter targets: Datadog, Honeycomb, Jaeger, or Grafana Tempo.

Use the W3C  header for cross-service trace propagation -- OTel handles this
automatically. Do not implement custom trace ID schemes.

### Span naming convention

```text

{http.method} {http.route}          → "POST /api/orders"
{db.operation} {db.name}.{table}    → "SELECT orders.items"
{messaging.operation} {queue.name}  → "publish order-events"
{rpc.service}/{rpc.method}          → "OrderService/CreateOrder"

```text

---

## 7. Alerting Tiers

### P0 — Wake the developer (page immediately, any time)

| Condition | Threshold |
|-----------|-----------|
| Service is down | Error rate = 100% for 1 min OR health check failing for 2 min |
| Data loss risk | Database replication lag > 30s |
| Security event | Secret scan found credentials in a commit; auth bypass detected |
| SLA breach imminent | p99 latency > 5000ms for 5 min |

Response: on-call developer paged within 5 minutes. Acknowledge within 15 minutes.

### P1 — Business hours response (notify, respond same day)

| Condition | Threshold |
|-----------|-----------|
| Elevated error rate | Error rate 1–5% sustained for 10 min |
| High latency | p99 latency 2000–5000ms for 10 min |
| Queue backup | Message queue depth > 10,000 and growing |
| Disk filling | Disk usage > 80% on any production volume |

Response: team notified in Slack/email. Fix within 4 hours during business hours.

### P2 — Weekly review (track, schedule fix)

| Condition | Threshold |
|-----------|-----------|
| Slow queries | Any query p95 > 500ms |
| Retry rate | Retry rate > 5% on any operation |
| Memory trend | Memory usage trending up over 7 days without restart |
| Test failure rate | Flaky test rate > 2% |

Response: added to the weekly engineering review. Fix within the sprint.

### P3 — Monthly review (informational)

| Condition | Examples |
|-----------|---------|
| Trends and capacity | Traffic growth projections, cost trends |
| Deprecation warnings | Old API versions still in use, deprecated dependency calls |
| Coverage drift | Test coverage dropping below 75% |

Response: reviewed monthly. No immediate action required.

---

## 8. Cost Control

### Trace sampling rates

Sampling 100% of traces is expensive at scale. Use these defaults:

| Traffic level | Recommended sampling rate |
|--------------|--------------------------|
| < 100 req/s | 100% (trace everything) |
| 100–1,000 req/s | 10% |
| 1,000–10,000 req/s | 1% |
| > 10,000 req/s | 0.1% with tail-based sampling for errors |

Always sample 100% of error traces regardless of overall rate. Configure this in OTel
as a `ParentBased(TraceIdRatioBased)` sampler combined with an always-on error sampler.

### Log retention tiers

| Log type | Retention | Storage class |
|----------|-----------|--------------|
| Error logs | 90 days | Hot (fast search) |
| Audit logs (auth, payments) | 1 year | Warm |
| Info/debug logs | 14 days | Hot |
| Security event logs | 2 years | Warm + immutable |

### Metric retention

- High-resolution (raw, 15s intervals): 7 days.
- Medium-resolution (1-min rollups): 60 days.
- Low-resolution (1-hour rollups): 2 years.

Prometheus default retention is 15 days at full resolution. Configure remote write
to a long-term store (Thanos, Cortex, Grafana Mimir) for anything beyond 15 days.

---

## 9. Tooling Baseline -- April 2026

Choose one stack and use it consistently. Do not mix Datadog and Prometheus in the same project.

| Option | Stack | Best for |
|--------|-------|----------|
| **A -- Open-source** | Prometheus + Grafana, Loki, Tempo, Sentry (self-hosted) | Cost-sensitive, infra-savvy teams |
| **B -- SaaS unified** | Datadog + Sentry; OTel SDK -> Datadog OTLP endpoint | Single pane of glass, managed hosting |
| **C -- Honeycomb** | Honeycomb + Sentry; OTel SDK -> Honeycomb OTLP endpoint | High-cardinality debugging, microservices |
| **D -- Serverless** | Vercel Analytics + Axiom + Sentry | Next.js on Vercel, Cloudflare Workers, edge |

### What NOT to do

- Do not use `console.log` as a substitute for structured logging.
- Do not build a custom metrics system — use Prometheus client libraries.
- Do not use vendor-specific trace SDKs — always use OpenTelemetry.
- Do not store logs in the application database — use a dedicated log store.
- Do not alert on every log line — alert on aggregated rates and thresholds.
