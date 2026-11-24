# Scan report template

`/nrd-scan` writes one file, `docs/scans/<repo>-<YYYY-MM-DD>.md`. Each finding section is self-contained, so it can be pasted into a Linear issue as is.

```markdown
# Security scan: <owner/repo> @ <sha7> (<YYYY-MM-DD>)

Scope: <whole repo | paths>. Files read: <N>. Not reviewed: <paths or "none">.

| # | Severity | Rule | Location | Issue |
|---|---|---|---|---|
| 1 | critical | `biz.unauthenticated_webhook` | `src/app/api/webhook.py:44-65` | <title> |

---

## Fix brief (paste above the findings in a ticket)

I need you to fix <a confirmed security finding | N confirmed security findings> in our codebase. Treat <this | each> as a real exploitable issue, not a linter nit.

Rules:
* Stay scoped to <this finding | these findings>. Do not refactor unrelated code.
* Confirm the issue still exists at the location below before changing anything.
* Group fixes by file. One PR is fine when they share a root cause; split PRs when they don't.   ← multi-finding only
* Prefer the recommended fix. A different approach is fine only if it fully closes the exploit, not just the symptom.
* Add or update tests that would have caught this.
* Open a PR whose description states what was exploitable and how the fix closes it.

---

## Finding 1 — <critical | high> / <secrets | infrastructure | injection | authz | business logic | supply chain>

**Issue:** <title>

**Repository:** <owner/repo> — [https://github.com/<owner/repo>](<https://github.com/<owner/repo>>)

**Location:** `<path>:<start-end>`

**Rule:** `<family.rule_id>`

**Exploitability:** <unauthenticated remote | authenticated low priv | authenticated high priv>

**Data at risk:** <business data | credentials>

**Evidence:** <the source → sink path or policy statement, with line refs; short code excerpt; secrets redacted to first 4 chars + length>

**Why this matters:** <attack walk-through: who sends what, and what happens>

**Blast radius:** <what the attacker reaches>

**Recommended fix:** <concrete change; code sketch if short>
```

## Evidence bar (from the scan-quality review)

Drop or downgrade a finding when:

- **Injection:** the value reaches SQL only as a bound parameter (`%s`, `$1`, `:name`). A cast failure is not injection.
- **Secrets:** the value doesn't grant access (AWS account id, email address, queue URL, public client id).
- **Duplicates:** the same location or root cause is already a finding.
- **Hypotheticals:** the exploit depends on downstream code you have not seen. Read that code, or mark the finding `consider` in the PR flow instead.

## Creating tickets

Never create Linear issues from a scan unless the user confirms the list in chat. When they do:

- Create one issue per repo: the fix brief plus all findings, or one issue per finding if the user asks.
- Title: `NRD scan: <issue title>` for a single finding, or `NRD scan: <N> findings in <repo>`.
- Label `Security` when the team has it.
