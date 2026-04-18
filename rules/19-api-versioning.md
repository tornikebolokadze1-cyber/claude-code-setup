# API Versioning Standards

Every API that is consumed by more than one service or by any external client MUST be versioned.
A consumer that ships today should still work six months from now without being force-upgraded.

---

## 1. Versioning Scheme

Use SemVer-style MAJOR.MINOR.PATCH in your internal model, but expose only MAJOR in the API
surface. Consumers pin to a major version; minor and patch changes are transparent to them.

| Version component | When to bump |
|-------------------|-------------|
| **MAJOR** | Any breaking change. Existing consumers will need to update their code. |
| **MINOR** | New fields, new endpoints, new optional parameters. Backward compatible. |
| **PATCH** | Bug fixes, performance improvements, documentation corrections. Consumers need not change anything. |

**Breaking change definition** — any of the following requires a MAJOR bump:

- Removing a field, endpoint, or parameter that consumers currently use.
- Renaming a field or endpoint.
- Changing a field's data type (e.g., `id` from `integer` to `string`).
- Changing an existing enum to remove a value.
- Changing required vs optional status of a field (making optional → required is breaking).
- Changing the semantic meaning of a field without changing its name.
- Changing authentication or authorization requirements.

---

## 2. Versioning Strategy — URL vs Header vs Content Negotiation

| Strategy | URL example | Header example | Use when |
|----------|-------------|----------------|----------|
| **URL path** | `/api/v2/users` | — | Public REST APIs, mobile app backends, any API with external consumers |
| **Request header** | `/api/users` | `API-Version: 2` | Internal APIs between services in the same organization |
| **Content negotiation** | `/api/users` | `Accept: application/vnd.myapp.v2+json` | Mature REST APIs following HATEOAS; rarely appropriate for new projects |
| **Query parameter** | `/api/users?version=2` | — | Do not use — pollutes caches and URLs, hard to route |

### Decision rules

**Use URL path versioning when:**

- The API has external consumers (third parties, mobile apps, public SDKs).
- Different major versions may coexist on different servers or containers.
- You want to be able to point `v1` and `v2` at different code deployments independently.

**Use header versioning when:**

- The API is internal-only (consumed only by services you control).
- You want clean URLs in logs and documentation.
- You are certain all consumers are under your control and can be updated in lockstep.

**Never use query parameter versioning.** CDNs and proxies cache by URL including query strings
in unpredictable ways. Routing logic based on query parameters is harder to read and test.

---

## 3. URL Path Versioning — Implementation

```text

/api/v1/users          ← version 1 (supported)
/api/v2/users          ← version 2 (current)
/api/v3/users          ← version 3 (preview, opt-in)

```text

Rules:

- The prefix is always lowercase `v` followed by the major version integer: `v1`, `v2`.
- The current stable version is always available without a `latest` alias. Never use `/api/latest/` — it makes pinning impossible.
- All versions are served from the same host. Do not use subdomains for versioning (`v2.api.example.com`) — it complicates TLS certificates and DNS.
- Route handlers for each major version are in separate files or modules to avoid version bleed.


---

## 4. Deprecation Policy

### Minimum notice period

- **Public APIs (external consumers):** 90 days minimum from deprecation announcement to removal.
- **Internal APIs (same organization):** 30 days minimum, with cross-team acknowledgment.
- **Webhook payload versions:** 180 days minimum (consumers may not monitor logs daily).

### Required deprecation signals

Every deprecated endpoint MUST emit all four signals:

1. `Deprecation` HTTP header -- date the feature was deprecated: `Deprecation: Sat, 01 Mar 2026 00:00:00 GMT`
2. `Sunset` HTTP header -- date it stops working, plus a `Link` header to the migration guide.
3. `warning` field in the JSON response body with `code: "DEPRECATED"` and removal date in the message.
4. CHANGELOG entry under the version that introduced the deprecation.


### What must accompany every deprecation

- Migration guide published at a stable URL before the deprecation announcement.
- Usage stats showing who is still calling the deprecated endpoint (so you can reach out).
- New endpoint (the replacement) must be live and documented before the old one is deprecated.

---

## 5. Breaking Changes Checklist

Before shipping a MAJOR version bump, complete every item:

- [ ] All breaking changes are listed in `CHANGELOG.md` under the new major version.
- [ ] A migration guide is published at a stable, versioned URL.
- [ ] Every affected field or endpoint has the `Deprecation` and `Sunset` headers set in v(N-1).
- [ ] Minimum notice period has elapsed (90 days for public, 30 days for internal).
- [ ] At least one reviewer outside the owning team has signed off on the migration guide.
- [ ] All SDKs published by your organization have been updated to the new version.
- [ ] Clients with active traffic on the old version have been notified directly.
- [ ] Rollback plan is documented: what happens if v(N) is reverted to v(N-1)?

---

## 6. Backward Compatibility Guarantees

**Always safe (never requires a major bump):**

- Adding new optional fields to request or response bodies.
- Adding new endpoints.
- Adding new optional query parameters.
- Adding new values to an enum that consumers are expected to handle with a default case.
- Relaxing validation (accepting more inputs than before).

**Always breaking (always requires a major bump):**

- Removing or renaming any field, parameter, or endpoint.
- Changing a field's type.
- Adding a new required field to a request body.
- Narrowing validation (rejecting inputs that were previously accepted).
- Changing the meaning of an existing status code.

**Requires feature flag + consumer opt-in (not a major bump, but not silently deployed):**

- Adding a new enum value that consumers must explicitly handle (not catch-all safe).
- Changing default behavior of an existing parameter.
- Changing sort order, pagination defaults, or response field ordering.

---

## 7. GraphQL-Specific Rules

GraphQL APIs are not versioned at the URL level. Use field-level deprecation instead.

```graphql

type User {
  id: ID!
  name: String!
  email: String!
  username: String @deprecated(reason: "Use `handle` instead. Removed after 2026-09-01.")
  handle: String!
}

```text

Rules for GraphQL APIs:

- Mark deprecated fields with `@deprecated(reason: "...")` — the reason MUST include the removal date.
- Never remove a deprecated field before its removal date has passed.
- Never change the type of an existing field — add a new field with the new type.
- Never make a nullable field non-nullable — it breaks all existing queries that do not handle null.
- Introspection MUST remain enabled in production. Disabling it breaks client code generation.
- Run schema linting (`graphql-inspector`, `graphql-schema-linter`) on every CI run to catch accidental breaking changes.
- Use `graphql-inspector diff` in CI to detect and classify schema changes as breaking/non-breaking.

---

## 8. Internal APIs

Services within the same organization that call each other have relaxed rules, but versioning is
still required.

| Rule | Public API | Internal API |
|------|-----------|--------------|
| Versioning required | Yes | Yes |
| Minimum deprecation notice | 90 days | 30 days |
| Migration guide required | Yes | Yes (cross-team Slack announcement acceptable) |
| Sunset headers required | Yes | Recommended |
| Semver discipline | MAJOR.MINOR.PATCH | MAJOR.MINOR.PATCH |

Internal APIs MUST maintain a **cross-service deprecation log**: a shared document (Notion,
Confluence, or a `docs/deprecations.md` in the monorepo) that lists every deprecated endpoint,
which services consume it, and the target removal date. Without this log, "internal" deprecations
silently break consumers.

---

## 9. Webhook Versioning

Webhooks are push-based and asynchronous. The consumer may not be watching closely.

Rules:

- Each webhook consumer is pinned to a specific payload version at registration time.
- Payload version is included in every webhook delivery as a header: `X-Webhook-Version: 2` and `Content-Type: application/json`.

- Breaking changes to webhook payloads require a new version number, not an in-place change.
- Both old and new payload versions are delivered simultaneously during the migration period.
- Consumers self-migrate at their own pace within the 180-day sunset window.
- Provide a webhook replay API so consumers can re-process historical events after migrating.
- Never silently change a webhook payload. If a consumer has not acknowledged the new version
  after the sunset date, pause delivery and notify via email before removing the old version.

---

## 10. SDK Versioning

SDKs that wrap your API follow their own release cycle but must align on MAJOR versions:

| Rule | Detail |
|------|--------|
| SDK MAJOR must match API MAJOR | SDK v2.x wraps API v2. SDK v3.x wraps API v3. |
| SDK MINOR/PATCH are independent | SDK v2.3.1 is a patch to the SDK, not to the API. |
| New SDK MAJOR must ship before API v(N-1) sunset | Consumers need time to upgrade the SDK. |
| Migration guide in SDK repo | `MIGRATION.md` with before/after code examples. |
| Old SDK MAJOR maintained for the API deprecation period | Security patches only after the deprecation clock starts. |

---

## 11. Sunset Procedure

When the sunset date arrives:

1. **One week before:** send final reminder email/notification to all registered consumers.
2. **On sunset date:**
   - Return `410 Gone` with a `Link` header pointing to the migration guide:
     ```
     HTTP/1.1 410 Gone
     Link: <https://docs.example.com/migration/v2>; rel="successor-version"
     Content-Type: application/json

     {
       "error": "API_SUNSET",
       "message": "This API version has been retired. See https://docs.example.com/migration/v2",
       "sunset_date": "2026-09-01"
     }
     ```
   - Do not return `404 Not Found` — it is ambiguous. `410 Gone` is intentionally permanent.

3. **Before disabling:** pull usage stats from the last 30 days. If any consumer is still
   calling the endpoint with > 100 requests/day, escalate to a human review before proceeding.

4. **After 30 days at 410:** remove the route handler and associated code.
5. **Changelog entry:** add a `### Removed` section under the version that removed the endpoint.
