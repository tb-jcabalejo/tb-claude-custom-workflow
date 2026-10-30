---
name: security-audit
description: Perform OWASP-aligned security checks on code and APIs. Use when auditing for vulnerabilities, reviewing security, or working with security-engineer.
---

# Security Audit

## OWASP Top 10 Quick Checks

### A01 Broken Access Control
- [ ] Auth required on protected routes
- [ ] User can only access own resources (no IDOR)
- [ ] Role/permission checks server-side, not client-only

### A02 Cryptographic Failures
- [ ] Sensitive data encrypted at rest and in transit
- [ ] No sensitive data in URLs, logs, or error messages
- [ ] Strong algorithms (e.g., bcrypt for passwords, TLS 1.2+)

### A03 Injection
- [ ] Parameterized queries / ORM for SQL
- [ ] Input sanitized for XSS (escape output, CSP)
- [ ] No `eval`, `exec`, or dynamic code execution on user input

### A04 Insecure Design
- [ ] Threat model for sensitive flows
- [ ] Rate limiting on auth endpoints
- [ ] Secure defaults (no debug mode in prod)

### A05 Security Misconfiguration
- [ ] No default credentials
- [ ] Error pages don't leak stack traces
- [ ] Security headers (CSP, HSTS, X-Frame-Options)

### A06 Vulnerable Components
- [ ] Dependencies scanned (npm audit, pip audit, Snyk)
- [ ] No known vulnerable packages in production

### A07 Auth Failures
- [ ] Strong password policy
- [ ] Session invalidation on logout
- [ ] No credential stuffing (rate limit, lockout)

### A08 Software/Data Integrity
- [ ] Dependencies from trusted sources
- [ ] Integrity checks for critical assets

### A09 Logging & Monitoring
- [ ] Auth failures logged
- [ ] Sensitive actions auditable
- [ ] No sensitive data in logs

### A10 SSRF
- [ ] User-controlled URLs validated
- [ ] Internal services not exposed to user input

## Output Format
- **Critical**: Must fix before release
- **High**: Fix soon
- **Medium**: Plan remediation
- **Low**: Consider for future
