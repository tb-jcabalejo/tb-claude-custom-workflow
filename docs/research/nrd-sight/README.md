# NRD Sight: how it reviews PRs and the codebase

A study of every NRD Sight review on tb-jcabalejo's PRs, written as a spec we can replicate in our own Claude Code reviewer.

**Evidence base (pulled 2026-11-24)**

| Source | Count |
|---|---|
| My PRs on GitHub (open + closed, 2026-06-05 → 2026-11-20) | 103 across 10 repos |
| PRs that NRD Sight reviewed | 37 (9 repos) |
| NRD Sight PR reviews (summary bodies) | 77, 2026-08-03 → 2026-11-23 |
| NRD Sight inline comments | 31 (since 2026-10-22) |
| Findings tagged in those bodies | 173 tags, ~97 distinct titles |
| NRD Sight check runs | 1 per reviewed commit |
| Linear tickets produced by NRD Sight codebase scans | 23 read (39 findings) |

Raw corpus: [corpus/](corpus/) (`reviews.json`, `inline-comments.json`, `unique-finding-titles.tsv`, `my-prs.json`). Use it as the golden set when calibrating a replica.

---

## 1. Two modes

| Mode | Where it shows up | Unit of output |
|---|---|---|
| **PR review** | GitHub app `nrd-sight[bot]`: a check run, a PR review, inline comments | Findings on one diff, re-checked on every push |
| **Codebase scan** | Linear tickets ("NRD Sight task: …", or a plain security title) | Confirmed exploitable findings per repo, with rule ids, written as a fix brief |

The two use different severity scales and different finding shapes (sections 3–9 vs section 10).

---

## 2. PR review lifecycle

1. **Trigger:** every push to an open PR. 77 reviews were posted on 77 distinct head commits, so each review is pinned to one SHA. Reviews per PR: 1 (22 PRs), 2–5 (13 PRs), 7–8 (2 PRs).
2. **Check run** `NRD Sight review` starts on the push and completes in about 1–1.5 min.
   - Conclusion is always `success`. Title is `N findings open` or `Review delivered`.
   - Summary as of 2026-11-23: *"Review delivered; no blocking findings open. Advisory mode: findings are reported and tracked but never hold the merge."* That wording implies a blocking mode exists that is not enabled for us.
3. **PR review**, always with state `COMMENTED`. It never sends `APPROVE` or `REQUEST_CHANGES`.
4. **Inline comments** (since 2026-10-22) repeat a subset of the summary's findings: usually 1–3 per review, the new ones that map to a diff line. Findings carried over from earlier revisions don't get a second inline comment. A comment's `line` becomes `null` once a later push moves the code.
5. **Hidden markers** for state tracking:
   - Review: `<!-- nrd-sight-review:<review-uuid>:<head-sha> -->`
   - Inline finding: `<!-- nrd-sight-finding:<finding-uuid> -->`

**What it reads (shown by what it cites):**
- The diff, plus full files outside the diff (e.g. `README.md:145`, upstream callers).
- The PR title, description and test-plan checklist.
- **The linked Linear ticket.** On admin-frontend-open-distribution#39 it quotes the requirement from ENG-2274 (now OPE-307): *"an alternative must fully close the exploit, not merely hide it in the frontend"*. That text is in the Linear issue, not the PR body.
- Its own earlier findings, and the author's replies to them.
- Related PRs in other repos (it asks to "link admin-api-python#427 as the enforcement").

---

## 3. Review body: exact template

```markdown
## NRD Sight review

<ONE verdict sentence: does the change do what the PR/ticket claims, and what is the main open risk.>

**Done well:** <ONE specific strength, naming the mechanism, file or test that proves it.>

**Since the last revision:** <N earlier findings verified fixed>, <N answered by your replies>, <N still open>.   ← re-reviews only

**1. [<severity> · <category>] <Title that states the consequence>**
<One paragraph: the concrete failure scenario. Inputs → wrong outcome, with code identifiers.>
- Fix: <the smallest change that closes it; alternatives if a product decision is needed>
- Where: <path:line or path:start-end; extra context locations separated by ";"> [(still open from an earlier revision)]
- Cost: <what the fix costs or trades off: migration, cross-repo change, extra query, behavior change>
- On your reply: <rebuttal with new evidence when the author's reply did not resolve it>   ← optional

**2. …**

_Disagree with a finding? Reply on it or in a pull request comment: replies are read on the next push._

_Reviewed automatically by [NRD Sight](https://app.nrdsight.com/reviews). Findings weigh tradeoffs, not style — an empty review means nothing material was found._

<!-- nrd-sight-review:<uuid>:<head-sha> -->
```

**Clean review (14 of 77):** the verdict and *Done well* lines, then exactly:

> No material findings. Architecture, security, performance, cost, reliability and correctness all look sound for this change.

That sentence names the six dimensions it says it checks on every PR.

**Inline comment template:**

```markdown
**[<severity> · <category>] <Title>**
<Two or three sentences: the failure scenario.>
- Fix: …
- Cost: …

<!-- nrd-sight-finding:<uuid> -->
```

**Rules that hold across all 77 bodies:**

| Rule | Observed |
|---|---|
| Verdict is one sentence | 109–351 chars; openers such as "Solid change:", "Correctly fixes …", "This version does not fix ENG-2274: …" |
| Exactly one *Done well* | 76 of 77 have it; 42 of those praise specific tests (often by test name) |
| Findings are numbered, one title line each | Titles 29–112 chars and state the consequence ("Audit insert failure returns 500 after the write has committed"), not the code smell |
| Every finding has Fix and Where | Cost is left out only when there is no meaningful trade-off (26 of ~170) |
| Paragraphs are length-capped | Lines are cut with "…" at about 370 chars |
| Findings per review | 0 (14), 1 (24), 2 (24), 3–4 (7), 5–7 (8). No hard cap is visible |
| It says what it could not see | "test_listing_issues_db.py … were only partly visible and not fully reviewed"; "depends on backend PRs that I can't see" |
| No style comments | The footer says so, and none of the 173 findings is about style |

---

## 4. Severity scale (PR review)

| Severity | Tags | Used for | Decision rule we can replicate |
|---|---|---|---|
| **critical** | 18 (all `security`) | An exploit is still open, or a security fix does not close what the ticket says it closes | An attacker or unauthorized user can do something now, and this PR either introduced it or claims to fix it but does not |
| **important** | 80 | Wrong results or data, writes that are lost or misreported, AC not met, misleading PR description, failures after commit | A real user or data path produces a wrong outcome under normal use, or reviewers would approve on false claims |
| **consider** | 75 | Edge cases, perf and cost, deploy ordering, duplicated logic, "verify this assumption" | Plausible but conditional, or a trade-off the author may accept knowingly |

Distinct findings by category and severity (~97 titles):

| Category | critical | important | consider |
|---|---|---|---|
| correctness | – | 25 | 22 |
| security | 4 | 7 | 5 |
| reliability | – | 6 | 8 |
| performance | – | – | 9 |
| ownership | – | 5 | 1 |
| architecture | – | – | 2 |
| pattern_fit | – | – | 2 |
| cost | – | – | 1 |

---

## 5. What it checks, by category

These checkpoints come from the actual findings. PR references are `repo#number`; afod = admin-frontend-open-distribution, aap = admin-api-python.

### correctness (largest bucket)
- **Behavior matches the ticket's acceptance criteria.** "Matrix does not auto-collapse on drill-down, as the acceptance criteria require" (afod#66); "Dashboard role set excludes roles named in the acceptance criteria" (opendistribution-api#19).
- **Null, zero and empty semantics.** "api_cost_currency is always sent even when api_cost is null" (afod#21); "clear_fulfillment check does not account for api_cost=0.0" (aap#174); "_find_unlinked_admin_purchase silently no-ops when order_number is None" (aap#281).
- **Silent data loss or coercion.** "int(raw) coercion on invoice id keys can silently drop or mis-key rows" (aap#299); "Client-side row filtering can silently drop/truncate data at the 5,000-row export cap" (afod#32).
- **Every code path gets the fix.** "TradeDesk transfers bypass the comp-outage hold" while the UPDATE path holds (marketplace-sync-manager#75); "No-comps hold leaks GA and seatless StubHub listings".
- **Shared or derived state stays consistent.** "Removing row 1 silently changes the shared currency for all other rows" (afod#27); "Drawer holds a row snapshot that goes stale after Refresh" (afod#54).
- **SQL and view logic.** Filters actually applied ("source column is exposed but never filtered", snowflake-migration#11); joins that duplicate rows ("Orphan POS rows duplicate across Outbox events", opendistribution-api#19); guards on the right grain ("Settle guard checks rows, not sessions").
- **Validation removed without a replacement.** "Removing quantity-total validation drops client-side protection with no visible replacement" (afod#31).
- **Wrong identifier or unit shown.** "Stale POS matrix cell shows listing count, not excess tickets" (afod#54); "'Open in POS' keys on StubHub listing id, not a POS listing id".

### security
- **Authorization is enforced on the server, never only in the SPA.** Every critical finding is this (afod#33, afod#39): "An attacker doesn't use this SPA. They send a PATCH with their Firebase token from curl."
- **Client-supplied roles and ids are untrusted.** "Role list is client-supplied and can be stale or tampered with" (afod#33).
- **Ownership or IDOR checks are real.** "Ownership check is just 'the list endpoint returned this order'".
- **Audit trails are server-side, tamper-resistant and complete.** "Audit trail is a console.info in the browser"; "Audit omits cost fields on legacy-shape writes" (aap#427).
- **New routes have role rows.** "Verify the new route key has role rows, or the page opens to every signed-in user" (admin-frontend#452).
- **Read and write permissions are separate.** "Edit-payload endpoint grants full read access with no separate write gate" (aap#243).
- **Inputs are constrained to what the UI offers.** "Timezone query param accepts any valid IANA zone" (aap#374).

### reliability
- **Ordering of side effects and transaction boundaries.** "Audit insert failure returns 500 after the write has committed" (aap#427).
- **Migrations ship with the code that needs them, and deploy order is stated.** "No migration for open_dist.sales_order_field_update_audit"; "Audit table DDL not in this PR; deploy order matters".
- **DDL locking.** "Check constraint validation scans the whole table under ACCESS EXCLUSIVE" (postgresql-migration-open-distribution#28).
- **Staleness and freshness guards on data pipelines.** "_dt snapshot has no 12-hour staleness guard"; "Pricing comps read a table that is no longer written".
- **Failure handling around external calls.** "No error handling around the two Invoice Log fetches" (aap#299); "Timed-out Snowflake threads keep running on the shared default executor".
- **Races and locks.** "Insert path can race with the TD/SH poller and create duplicate purchase rows"; "Advisory lock namespace shared across all orders" (aap#281, aap#321).
- **Degraded mode is visible.** "Empty comps may reprice … with no alert".
- **Rate limits survive missing dependencies.** "StubHub GET can run uncapped when the Redis client is missing".

### performance and cost
- Re-queries inside loops ("Re-fetches all purchase rows with FOR UPDATE after every insert", aap#321).
- Full scans on scheduled tasks ("Hourly task scans the full 90-day listing history twice", snowflake-migration#11).
- Missing indexes for new lookups ("No index for the new latest-pos-snapshot lookup"; "Confirm indexes exist for the per-run count and per-session delete").
- Blocking work on the async event loop ("Share index built synchronously on the event loop", opendistribution-api#71).
- Unbounded caches ("Share cache holds whole-account indexes with no byte bound").
- Extra network round trips per user action ("Each save adds three network round trips, one a 500-row list fetch").
- Warehouse cost (`cost`): "Unscoped MAX(INSERTDATE) scan on every summary cache miss".

### ownership: does the PR tell the truth?
- **The description and test plan match the diff.** "PR description and test plan describe behavior the code no longer has … Reviewers will approve a security fix that isn't there." (afod#39); "Description promises a persisted, atomic audit that isn't in the diff" (opendistribution-api#2).
- **The right ticket is linked.** "Change doesn't match the linked ticket: ENG-307 is 'Create a new repo for API …'".
- **No leftover scaffolding.** "Debug-logging scaffolding writing to a hardcoded Windows path" (aap#321).
- **Scope:** an out-of-scope change is called out when it ships into a shared file.

### architecture and pattern_fit
- Defenses that cannot work at that layer ("121-line payload snapshot guards a threat the SPA cannot stop").
- Readers and writers out of sync after a change ("Comp reader points at a table this change stops writing").
- Duplicated rules that will drift ("Comp-set rules duplicated in two views instead of shared"; "New quote-aware record splitter duplicates logic sales-orders export doesn't use").

---

## 6. How it treats tests

There is **no "missing tests" category**. Tests are evidence, used four ways:

1. **Praise tests that prove behavior.** 42 of 76 *Done well* lines are about tests, for example: *"the DB-gated tests run the real query on seeded temp-table copies, so each filter is proven by behavior rather than string match."* It names the tests (`test_retry_of_one_message_reuses_session_keys`).
2. **Check that a test exercises the claimed path.** *"The added test uses seats "[1, 2]", which overlaps itself, so it does not exercise this path."*
3. **Check tests against the description.** *"the new test asserts the opposite: no `get`, no `getUserRoles`, no audit."*
4. **Ask for the specific regression test inside the Fix.** 22 Fix bullets do this, e.g. "add a legacy-shape audit test", rather than a generic "add tests".

---

## 7. Ticket and description conformance

- It finds the ticket from the key in the PR title or branch (OPE-…, ENG-…, COR2-…) and reads the Linear issue.
- The verdict often states ticket closure outright: "This version does not fix ENG-2274 …"; "matches the OPE-82 goal".
- An unmet AC becomes a `correctness` finding. A description or test plan that is false becomes an `ownership` finding. For a security ticket it can rise to `critical`.
- It tells you when *not* to close the ticket: "Link that PR here, or don't close ENG-2274 from this one."

---

## 8. Re-review protocol (every push)

1. Reload earlier findings (by finding uuid) and classify each one as **verified fixed**, **answered by your replies**, or **still open**. Print the counts in *Since the last revision*.
2. Keep still-open findings in the list, with "(still open from an earlier revision)" on their *Where* line.
3. Read the author's replies on the finding or in PR comments (feature visible since 2026-10-26). Either mark the finding answered, or add **On your reply:** with new evidence.
4. Re-scan the new diff for new findings.
5. Known weakness to avoid: the same open issue is sometimes re-raised under a new title next to the carried-over one (marketplace-sync-manager#75 findings 1 and 2; afod#39 has the description finding three times). A replica should dedupe by location and root cause.

---

## 9. How the format evolved

| Date | Change |
|---|---|
| 2026-08-03 → 08-05 | "NRD Insight review": `### N finding(s)` header; prose blocks *Evidence / Tradeoff / Recommendation* |
| from 2026-08-28 | Renamed "NRD Sight review"; `Fix / Where / Cost` bullets; numbered findings |
| from 2026-10-22 | Inline comments per finding |
| from 2026-10-26 | Reply loop ("Disagree with a finding? Reply …", "answered by your replies", "On your reply:") |
| by 2026-11-23 | Check-run summary states "Advisory mode … never hold the merge" |

---

## 10. Codebase scan mode (Linear fix tickets)

**Source:** 23 Linear tickets, 2026-10-01 → 2026-10-30. That is 39 findings (38 unique; OPE-320 is a copy of OPE-305). People paste NRD's scan export into a ticket, titled "NRD Sight task: …" or with the finding's own title. Scans covered mostly Lambda services (tradedesk-*, opendistribution-stubhub-*, marketplace-sync-manager, pricer and AMS importers). They read app code, `terraform/*.tf`, `.github/workflows/*.yml`, `.env.*` and `deploy.sh`.

### Ticket template (exact)

The preamble is written to be pasted straight into a coding agent:

```markdown
I need you to fix <a confirmed security finding | N confirmed security findings> in our codebase. Treat <this | each> as a real exploitable issue, not a linter nit.

Rules:
* Stay scoped to <this finding | these findings>. Do not refactor unrelated code.
* Confirm the issue still exists <at the location below> before changing anything.
* Group fixes by file. One PR is fine when they share a root cause; split PRs when they don't.   ← multi-finding only
* Prefer the recommended fix. A different approach is fine only if it fully closes the exploit, not just the symptom.
* Add or update tests that would have caught this.
* Open a PR whose description states what was exploitable and how the fix closes it.   (multi: "list each finding and how it was closed")

## [Finding N — ]<critical | high> / <category>

**Issue:** <title>
**Repository:** owner/repo — [url](<url>)
**Location:** path:line | path:start-end
**Rule:** <family.rule_id>
**Exploitability:** unauthenticated remote | authenticated low priv | authenticated high priv
**Data at risk:** business data | credentials
**Evidence:** <quoted code with line refs>
**Why this matters:** <attack narrative with a concrete payload or request>
**Blast radius:** <everything the attacker can reach>
**Recommended fix:** <concrete change, often with a code sketch>
```

### Scales (different from the PR review)
- **Severity:** critical (30) and high (9). Scans never use `important` or `consider`.
- **Exploitability:** authenticated low priv (22), unauthenticated remote (14), authenticated high priv (3).
- **Data at risk:** business data (21), credentials (18).

### Rule catalog

| Rule id | Count | Triggers on | Example |
|---|---|---|---|
| `secrets.committed_live` | 11 | Literal keys or credentials in Terraform, `.env.*` or workflows | New Relic license key in `terraform/lambda.tf` (OPE-323); AWS key in `.env.staging` (ENG-2242) |
| `infrastructure.iam_wildcard` | 9 | `Action: *`, `sqs:*`, `s3:*`, `Resource: *`, or managed `*FullAccess` on Lambda, Firehose or Scheduler roles | tradedesk-sales-webhook `terraform/iam.tf:23-100` (OPE-106 #3) |
| `secrets.in_logs_or_bundle` | 4 | Credentials echoed in CI logs, or tokens passed around without sanitization | S3 credentials printed by `deploy.sh` (AMSI-12) |
| `injection.sql` | 4 | SQL built by concatenation | `hours_cutoff` (OPE-325), `event_id` (OPE-102) |
| `biz.unauthenticated_webhook` | 4 | Webhook with no HMAC signature check or replay protection | OPE-106, OPE-312, OPE-314 |
| `biz.race_money` | 1 | DB upsert and SQS enqueue on money state not atomic | OPE-305 |
| `biz.no_rate_limit` | 1 | Public webhook with no throttling | OPE-100 |
| `biz.workflow_skip` | 1 | Unvalidated enum or action passed through to downstream branches | OPE-106 #4 |
| `authz.idor` | 1 | Client-supplied ids with no server-side ownership check | ENG-2274 / OPE-307 |
| `supply.` / `infrastructure.secrets_in_environment` | 1 + 1 | Credentials in Lambda env vars instead of Secrets Manager | AMSI-13 (same issue under two ids) |

Rule families: `secrets.*`, `infrastructure.*`, `injection.*`, `biz.*`, `authz.*`, `supply.*`.

### How the two modes connect
ENG-2274 (now OPE-307) started as an `authz.idor` scan finding. Its fix PRs (afod#33, afod#39, aap#427, opendistribution-api#2) were then PR-reviewed against that ticket. The scan's "fully close the exploit, not just the symptom" rule is exactly what produced the four `critical · security` PR findings. In practice, the scan defines the requirement and the PR review enforces it.

### Scan quality: what not to copy
The preamble's "Confirm the issue still exists" line matters because the scans over-claim:
- **Injection without a sink:**
  - OPE-102 is rated critical, yet its own evidence says the query "uses parameterized query (%s)".
  - OPE-325's `(%s || ' hours')::interval` binds the value, so the payload only breaks the cast.
  - OPE-103 #4 builds HTTP query params, not SQL.
- **Non-secrets rated critical:** an AWS account ID (OPE-282), an email address (OPE-101), SQS queue URLs (OPE-265 #1).
- **Duplicates and drift:**
  - OPE-320 is a copy of OPE-305.
  - OPE-100 and OPE-314 point at the same lines.
  - Near-identical IAM wildcards are rated critical/low-priv in OPE-262 but high/high-priv in OPE-324.
- **Redaction defects:**
  - OPE-282 says "[REDACTED]" but still prints the account ID in full.
  - Redaction replaced `os.getenv(` inside code samples.
  - Linear turned `:secret:` in Secrets Manager ARNs into an emoji (OPE-119, OPE-324).

A replica should:
- Require a concrete source → sink path before tagging `injection.*`.
- Call something a secret only if it grants access.
- Dedupe findings by location and root cause.
- Redact before posting, and put ARNs in code spans.

---

## 11. Replicating it in our Claude Code workflow

### Shape (built)
- **Rubric and templates:** [`.claude/skills/nrd-review/`](../../../.claude/skills/nrd-review/SKILL.md): `SKILL.md`, `review-template.md`, `scan-template.md`.
- **Agent:** [`.claude/agents/nrd-reviewer.md`](../../../.claude/agents/nrd-reviewer.md). Read-only; returns the body plus a findings JSON; never posts.
- **Command:** [`/nrd-review`](../../../.claude/commands/nrd-review.md). [`nrd-review-bundle.sh`](../../../.claude/scripts/nrd-review-bundle.sh) gathers the inputs, the command spawns the agent and validates the format, then saves `docs/reviews/<repo>-<N>-<sha7>.md`.
  - `--compare` scores the review against NRD Sight at the same commit.
  - `--post` posts a COMMENT review with inline comments.
  - The header is "Claude review", with `tb-review` / `tb-finding` markers, so it is never mistaken for the real bot.
- **Scan command:** [`/nrd-scan`](../../../.claude/commands/nrd-scan.md). Writes `docs/scans/<repo>-<date>.md` and creates Linear tickets only after you confirm.

### Inputs to collect before the agent runs
| Input | How |
|---|---|
| Diff and changed files at head | `gh pr diff N`, `gh pr view N --json title,body,headRefOid,baseRefName,files` |
| Full content of touched files and their direct callers | Read at the head SHA; graphify `path` / `explain` for blast radius (diff-first, per graphify.md) |
| Linked ticket and AC | Ticket key from title or branch → Linear `get_issue` (description = requirements + AC) |
| Earlier review and finding ids | Our own markers `<!-- tb-review:<uuid>:<sha> -->` / `<!-- tb-finding:<uuid> -->` from earlier bodies (`gh api repos/…/pulls/N/reviews`) |
| Author replies | `gh api repos/…/pulls/N/comments` and `…/issues/N/comments` posted after the last review |
| Related PRs | Links in the description or ticket attachments |

### Rubric to paste into the agent

```xml
<role>Senior reviewer for Ticketboat (FastAPI/Python, React/Vite/AntD, Postgres, Snowflake, AWS Lambda/SQS); priorities: material defects only, evidence-backed, smallest fix.</role>
<task>Review one PR at one head SHA and return a review body in the exact NRD template.</task>
<dimensions>correctness, security, reliability, performance, cost, architecture, pattern_fit, ownership</dimensions>
<severity>
  critical = exploitable now, or a security fix that does not close what it claims.
  important = wrong outcome under normal use, data loss or misreport, AC not met, or a PR description/test plan that would mislead an approver.
  consider = conditional edge case, perf/cost, deploy ordering, duplication, or an assumption to verify.
</severity>
<checks>
  - Each AC in the linked ticket: met / not met / not visible.
  - Description and test plan claims vs the diff; leftover debug code; correct ticket linked.
  - Authorization on the server; client roles/ids untrusted; audit server-side and complete.
  - Null/zero/empty semantics; silent coercion or truncation; every code path gets the fix.
  - Transaction boundaries and side-effect order; migrations present, lock impact, deploy order.
  - Freshness guards, external-call failure handling, races and locks, degraded-mode alerting.
  - Per-row queries, full scans, missing indexes, event-loop blocking, unbounded caches.
  - Tests: do they exercise the claimed path by behavior, not string match? Name the regression test a Fix needs.
</checks>
<forbidden>No style or naming comments. No finding without a concrete failure scenario and a location. No generic "add tests". No APPROVE/REQUEST_CHANGES.</forbidden>
<error_handling>If a file or the ticket is not visible, say so in the verdict ("not reviewed: …") instead of guessing. If the reply resolves a finding, mark it answered; if not, add "On your reply:" with evidence. Dedupe by location + root cause.</error_handling>
<output_format>
  ## <Reviewer> review
  1 verdict sentence (≤350 chars) · **Done well:** 1 specific item · **Since the last revision:** counts (re-reviews only)
  Numbered findings: **N. [severity · category] consequence title (≤110 chars)**, 1 paragraph (≤370 chars), then - Fix / - Where (path:line) / - Cost (omit if none) / - On your reply (optional).
  If none: "No material findings. Architecture, security, performance, cost, reliability and correctness all look sound for this change."
  Footer: replies are read on the next push; findings weigh tradeoffs, not style.
</output_format>
```

### Fitting it to our cycle
- Our `backend-reviewer` / `frontend-reviewer` return Critical / Suggestion / Nice. Map NRD **critical + important → Critical** (triggers a rework plan) and **consider → Suggestion**.
- Run it before opening the PR, at Review in `/project-manager`, so NRD Sight's findings are already closed when the real bot runs.
- **Calibrate on the corpus:** pick 10 reviewed commits (include afod#39, aap#427, marketplace-sync-manager#75, snowflake-migration#11 and a few clean ones), run the replica at the same SHA, and compare finding recall, severity agreement and false positives against `reviews.json`.

### What we can't see from the outside
- The model, prompt and context budget it uses, how it chooses lines outside the diff, and the rule that would turn "advisory" into "blocking".
- Whether the scan mode and the PR review share rule ids (the PR review never prints rule ids).
