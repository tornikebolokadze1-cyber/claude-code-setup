# Security Rules for Claude Code

These rules are MANDATORY. Claude MUST follow every rule below without exception.
This configuration is designed for NON-TECHNICAL users who write prompts only.

---

## 1. CORE SECURITY PRINCIPLES

### 1.1 Defense in Depth
- Never rely on a single security control. Layer defenses at every boundary.
- Validate input on the client AND the server. Never trust one side alone.
- Apply security at the network, application, and data layers simultaneously.

### 1.2 Principle of Least Privilege
- Every function, service, and user gets the MINIMUM permissions required.
- Database users get read-only access unless writes are explicitly needed.
- API keys are scoped to only the endpoints they need.
- File permissions default to 644 (files) and 755 (directories). Never 777.

### 1.3 Secure by Default
- All new projects MUST include security headers, input validation, and error handling from the first commit.
- HTTPS is mandatory. Never generate HTTP-only configurations.
- Authentication is required for every endpoint except explicitly public ones.
- CORS must be restrictive. Never use wildcard origins in production.

### 1.4 Zero Trust
- Authenticate and authorize every request, even between internal services.
- Never trust data from any source without validation, including your own database.
- Session tokens must be validated on every request, not just at login.

---

## 2. OWASP TOP 10 -- SIMPLIFIED RULES

These are the 10 most common ways applications get hacked.
Claude MUST prevent all of them automatically.

### A01: Broken Access Control
WHAT IT MEANS: Users can access things they should not be allowed to access.
RULES:
- Every API endpoint MUST check if the user is allowed to access it.
- Never expose database IDs in URLs without checking ownership.
- Always verify the logged-in user owns the resource they are requesting.
- Deny access by default. Only allow what is explicitly permitted.
- Never rely on hiding a URL as a security measure.

### A02: Cryptographic Failures
WHAT IT MEANS: Sensitive data is stored or transmitted without proper encryption.
RULES:
- Passwords MUST be hashed with bcrypt (cost factor 12+) or argon2id. NEVER store plaintext passwords.
- All traffic MUST use HTTPS/TLS 1.2+. Never HTTP.
- Sensitive data at rest MUST be encrypted (AES-256-GCM).
- Never implement custom cryptography. Use established libraries only.
- Never log sensitive data (passwords, tokens, credit cards, SSNs).
- Generate random values with crypto.randomBytes (Node.js) or secrets module (Python). NEVER use Math.random or the basic random module for security purposes.

### A03: Injection
WHAT IT MEANS: Attackers insert malicious code through user input fields.
RULES:
- ALWAYS use parameterized queries and prepared statements. NEVER concatenate user input into SQL.
- ALWAYS use ORM methods (Prisma, Sequelize, SQLAlchemy, Django ORM) instead of raw SQL when possible.
- If raw SQL is unavoidable, use ONLY parameterized queries with placeholders.
- Sanitize all user input that will be rendered in HTML to prevent XSS.
- Never pass user input to shell commands. If unavoidable, use allowlists.
- Never use eval, Function constructor, or similar dynamic code execution with user input.

### A04: Insecure Design
WHAT IT MEANS: The application architecture itself has security flaws.
RULES:
- Rate limit all authentication endpoints (max 5 attempts per minute).
- Rate limit all API endpoints (sensible defaults per endpoint type).
- Implement account lockout after repeated failed login attempts.
- Use CAPTCHA or proof-of-work for public-facing forms.
- Never trust client-side validation alone. Always validate on the server.
- Design with the assumption that every input is an attack.

### A05: Security Misconfiguration
WHAT IT MEANS: The application or server is configured with insecure defaults.
RULES:
- Remove all default credentials before deployment.
- Disable directory listing on web servers.
- Remove or restrict access to admin panels, debug endpoints, and status pages.
- Set security headers on every response (see Section 6).
- Disable verbose error messages in production. Never expose stack traces.
- Keep all dependencies updated. Run npm audit or pip audit regularly.

### A06: Vulnerable Components
WHAT IT MEANS: Using libraries or frameworks with known security holes.
RULES:
- Run dependency audits before every deployment.
- Pin dependency versions in production. Use lock files.
- Never use deprecated or unmaintained packages.
- Review new dependencies before adding them. Check download counts, last update date, and known vulnerabilities.
- Prefer packages with active security maintenance.

### A07: Authentication Failures
WHAT IT MEANS: Login systems that can be bypassed or broken.
RULES:
- Passwords MUST be minimum 8 characters. Recommend 12+.
- Implement multi-factor authentication (MFA) for sensitive operations.
- Session tokens MUST be cryptographically random, at least 128 bits.
- Sessions MUST expire after inactivity (max 30 minutes for sensitive apps).
- Invalidate sessions server-side on logout. Do not rely on deleting cookies.
- Never expose session tokens in URLs.
- Implement brute-force protection with exponential backoff.

### A08: Data Integrity Failures
WHAT IT MEANS: Code or data can be modified without detection.
RULES:
- Verify integrity of all downloaded packages (use lock files with checksums).
- Implement Subresource Integrity (SRI) for CDN-hosted scripts.
- Sign and verify all webhooks and API callbacks.
- Use Content Security Policy to prevent unauthorized script execution.
- Never auto-deserialize data from untrusted sources without validation.

### A09: Logging and Monitoring Failures
WHAT IT MEANS: Attacks happen and nobody notices.
RULES:
- Log all authentication events (login, logout, failed attempts).
- Log all access control failures (unauthorized access attempts).
- Log all input validation failures.
- NEVER log sensitive data (passwords, tokens, PII, credit card numbers).
- Include timestamps, user IDs, IP addresses, and request IDs in logs.
- Store logs in append-only storage. Logs must not be modifiable.
- Set up alerts for anomalous patterns (spike in failed logins, unusual access patterns).

### A10: Server-Side Request Forgery (SSRF)
WHAT IT MEANS: Attackers trick the server into making requests to internal systems.
RULES:
- Validate and sanitize ALL URLs provided by users.
- Never allow requests to internal IP ranges (10.x, 172.16-31.x, 192.168.x, 127.x, 169.254.x).
- Use allowlists for permitted external domains when possible.
- Disable HTTP redirects when fetching user-provided URLs, or limit redirect count.
- Never expose raw responses from internal services to users.

---

## 3. DATA PROTECTION RULES

### 3.1 Personal Data (PII)
- Collect only the minimum data needed. If you do not need it, do not store it.
- Encrypt PII at rest and in transit.
- Implement data retention policies. Delete data when no longer needed.
- Provide mechanisms for users to export and delete their data (GDPR compliance).
- Never log PII in application logs.
- Mask or redact PII in non-production environments.

### 3.2 Data Classification
- PUBLIC: Marketing content, public documentation. No special protection needed.
- INTERNAL: Business data, internal communications. Require authentication.
- CONFIDENTIAL: PII, financial data, health records. Require encryption + access controls.
- RESTRICTED: Credentials, encryption keys, master secrets. Require vault + audit logging.

### 3.3 Database Security
- Use a dedicated database user per application. Never use the root/admin account.
- Grant minimum required permissions (SELECT only if writes are not needed).
- Enable query logging for sensitive tables.
- Encrypt database connections with TLS.
- Backup databases with encryption. Test restore procedures.
- Never store database connection strings in code. Use environment variables.

### 3.4 File Upload Security
- Validate file type by checking magic bytes, not just the extension.
- Limit file size (default: 5MB unless explicitly larger is needed).
- Store uploads outside the web root. Never serve them directly.
- Generate random filenames. Never use the original filename for storage.
- Scan uploads for malware when possible.
- Set Content-Disposition: attachment for downloads.

---

## 4. SECRETS MANAGEMENT RULES

### 4.1 Absolute Prohibitions
- NEVER hardcode secrets, API keys, passwords, or tokens in source code.
- NEVER commit .env files, credential files, or private keys to git.
- NEVER log secrets in any form (including partial masking).
- NEVER transmit secrets in URL query parameters.
- NEVER store secrets in frontend/client-side code.
- NEVER share secrets via chat, email, or tickets.

### 4.2 Required Practices
- Store all secrets in environment variables loaded from .env files (development) or a secrets manager (production).
- Every project MUST have a .gitignore that excludes: .env, .env.*, *.pem, *.key, *.p12, *.pfx, *.jks, credentials.json, serviceAccountKey.json, and any secrets/ directory.
- Every project SHOULD have a .env.example with placeholder values (never real secrets).
- Rotate secrets on a regular schedule (90 days maximum for production).
- Use different secrets for each environment (development, staging, production).

### 4.3 Secret Detection
- Run secret scanning on every commit (using gitleaks, trufflehog, or detect-secrets).
- Block commits that contain detected secrets.
- If a secret is accidentally committed, consider it COMPROMISED. Rotate immediately.
- Scan git history periodically for leaked secrets.

### 4.4 How to Reference Secrets
- Node.js: Use process.env.SECRET_NAME with validation that it exists at startup.
- Python: Use os.environ["SECRET_NAME"] with validation that it exists at startup.
- NEVER inline secret values in code, even as "defaults" or "fallbacks."

---

## 5. NETWORK SECURITY RULES

### 5.1 Transport Security
- ALL connections MUST use TLS 1.2 or higher.
- HSTS header is MANDATORY with a minimum max-age of 31536000 (1 year).
- Include subdomains in HSTS when possible.
- Redirect all HTTP requests to HTTPS.
- Use secure cookies (Secure, HttpOnly, SameSite=Strict flags).

### 5.2 API Security
- Authenticate every API request (API key, JWT, OAuth 2.0).
- Rate limit all endpoints. Defaults:
  - Authentication endpoints: 5 requests per minute per IP.
  - Read endpoints: 100 requests per minute per user.
  - Write endpoints: 30 requests per minute per user.
  - File upload endpoints: 10 requests per minute per user.
- Validate Content-Type headers on all requests.
- Implement request size limits (default: 1MB for JSON, 5MB for file uploads).
- Version all APIs. Never break backward compatibility without a version bump.
- Return consistent error response format. Never expose internal details.

### 5.3 CORS Configuration
- NEVER use wildcard origins (Access-Control-Allow-Origin: *) in production.
- Use an explicit allowlist of permitted origins.
- Set credentials: true only when cookies or auth headers are needed.
- Restrict methods to only those the API actually supports.
- Set appropriate maxAge for preflight caching.

### 5.4 WebSocket Security
- Authenticate WebSocket connections during the handshake.
- Validate all messages received over WebSocket.
- Implement rate limiting on WebSocket messages.
- Set maximum message size limits.
- Use wss:// (TLS) exclusively. Never ws://.

---

## 6. SECURITY HEADERS -- MANDATORY

Claude MUST include these headers in every web application:

Required headers for all responses:
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- X-XSS-Protection: 1; mode=block
- Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
- Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self';
- Referrer-Policy: strict-origin-when-cross-origin
- Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=()

For Node.js/Express: Use the helmet middleware.
For Python/Flask: Use flask-talisman.
For Python/Django: Set SECURE_* settings in settings.py.
For Nginx: Add headers via add_header directives with the "always" flag.

---

## 7. RESOURCE LIMITS

### 7.1 Application Limits
- Request body size: 1MB maximum (JSON), 5MB (file uploads), 50MB (media uploads with explicit approval).
- Request timeout: 30 seconds for API calls, 120 seconds for file processing.
- Maximum query results: 100 items per page default, 1000 absolute maximum.
- Maximum concurrent connections per user: 10.
- Maximum WebSocket connections per user: 5.
- Maximum session duration: 24 hours, with 30-minute inactivity timeout.

### 7.2 Rate Limits (Per IP Unless Noted)
- Login attempts: 5 per minute, lockout after 10 failures for 15 minutes.
- Password reset: 3 per hour.
- Account creation: 3 per hour.
- API read: 100 per minute per authenticated user.
- API write: 30 per minute per authenticated user.
- File upload: 10 per minute, 100MB total per hour.
- Email sending: 10 per hour per user.

### 7.3 Database Limits
- Query timeout: 5 seconds for user-facing queries, 30 seconds for background jobs.
- Connection pool: minimum 5, maximum 20 connections per application instance.
- Row limit on SELECT without explicit pagination: 100 rows.
- Transaction timeout: 10 seconds.

### 7.4 Process Limits
- Child process timeout: 30 seconds maximum.
- Memory limit per process: 512MB default.
- CPU time limit: 10 seconds for synchronous operations.
- Temporary file cleanup: delete after 1 hour.

---

## 8. ERROR HANDLING RULES

### 8.1 Production Error Responses
- NEVER expose stack traces, file paths, SQL queries, or internal IPs to users.
- Return generic error messages with a unique error ID for support reference.
- Log the full error details server-side with the same error ID.

### 8.2 Error Codes
- 400: Invalid input (include which fields are invalid, not why).
- 401: Not authenticated (do not say "wrong password" vs "user not found").
- 403: Not authorized (do not explain what permissions are missing).
- 404: Not found (use this for authorization failures too, to avoid enumeration).
- 429: Rate limited (include Retry-After header).
- 500: Internal error (never include details).

---

## 9. DEPENDENCY SECURITY

### 9.1 Before Adding Any Dependency
Claude MUST verify:
- The package has more than 1,000 weekly downloads on npm / 500 on PyPI.
- The package was updated within the last 12 months.
- The package has no known critical or high vulnerabilities.
- The package name is spelled correctly (typosquatting prevention).
- The package is from the official registry (no custom registries without explicit approval).

### 9.2 Lock Files
- ALWAYS commit lock files (package-lock.json, yarn.lock, pnpm-lock.yaml, Pipfile.lock).
- Use npm ci (not npm install) in CI/CD pipelines.
- Review lock file changes in PRs for unexpected dependency additions.

---

## 10. GIT SECURITY RULES

### 10.1 Branch Protection
- Never force push to main or master.
- Never delete main or master branches.
- Always create feature branches for changes.
- Require pull request reviews before merging.

### 10.2 Commit Security
- Every commit must pass secret scanning.
- Never commit generated files, build artifacts, or dependencies.
- Every repository MUST have a comprehensive .gitignore.

### 10.3 Git Configuration
- Claude must NEVER modify global git configuration.
- Claude must NEVER modify user.email or user.name.
- Claude must NEVER use --force or --force-with-lease without explicit user approval.

---

## 11. CONTAINER AND DEPLOYMENT SECURITY

### 11.1 Docker
- Never run containers as root. Always specify a non-root USER.
- Never use --privileged flag.
- Never mount the host root filesystem.
- Pin base image versions. Never use :latest in production.
- Scan images for vulnerabilities before deployment.
- Use multi-stage builds to minimize attack surface.

### 11.2 Environment Configuration
- Use separate configurations for development, staging, and production.
- Never use production credentials in development.
- Never deploy with debug mode enabled.
- Set NODE_ENV=production or equivalent for production deployments.

---

## 12. INCIDENT RESPONSE

If Claude detects a potential security issue during development:
1. STOP the current task immediately.
2. ALERT the user with a clear description of the issue.
3. EXPLAIN the risk in simple terms.
4. PROVIDE specific steps to fix the issue.
5. DO NOT proceed until the user acknowledges the security concern.

---

## SUMMARY FOR NON-TECHNICAL USERS

Think of these rules as locks on your house:
- Every door has a lock (authentication on every endpoint).
- Each person gets only the keys they need (least privilege).
- You check IDs at the door (input validation).
- Your valuables are in a safe (encryption).
- You have cameras and alarms (logging and monitoring).
- You never hide a spare key under the mat (no hardcoded secrets).
- You keep your locks updated (dependency updates).
- You have insurance and a plan if something goes wrong (error handling and incident response).

Claude will enforce ALL of these rules automatically. You do not need to remember them.
Just describe what you want to build, and Claude will make it secure by default.
