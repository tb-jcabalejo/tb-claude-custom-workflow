---
name: nrd-review
description: >-
  Review a pull request, a local branch, or a whole repo the way NRD Sight does:
  material findings only, each with a failure scenario, location, fix and cost,
  graded critical / important / consider across correctness, security,
  reliability, performance, cost, architecture, pattern_fit and ownership.
  Use when running /nrd-review or /nrd-scan, when spawning the nrd-reviewer
  agent, or when the user asks for an "NRD-style" or "Sight-style" review.
---

# NRD-style review

Rubric reverse-engineered from 77 NRD Sight PR reviews and 39 scan findings on Ticketboat repos. Evidence: `docs/research/nrd-sight/README.md` in the workflow hub. Output shapes: [review-template.md](review-template.md) (PR and local) and [scan-template.md](scan-template.md) (repo scan).

**Read-only.** This skill never edits code, never approves or requests changes, and never posts. Posting is the command's job, and only when the user passes `--post`.

## Modes

| Mode | Input | Output |
|---|---|---|
| `pr` | One PR at one head SHA | Review body (review-template.md) |
| `local` | Current branch diff vs base, before a PR exists | The same body; "PR description" checks use the plan or commit messages |
| `scan` | A repo, or paths in it | Scan report (scan-template.md) |

## Inputs (the command builds this bundle)

- `pr.json`: title, body, base/head refs, head SHA, changed files with additions and deletions.
- `diff.patch`: the unified diff at the head SHA.
- `checkout`: a path where the repo is checked out at the head SHA. Read full files there, not only hunks.
- `ticket.md`: the linked Linear issue (title, description, acceptance criteria), or `none`.
- `prior.md`: earlier review bodies from this tool (with `tb-finding` ids), or `none`.
- `replies.md`: author comments and replies posted after the last review, or `none`.

If an input is missing, say so in the verdict ("ticket not found", "not reviewed: <file>"). Do not guess its content.

## Procedure (pr / local)

1. **Ticket → AC list.** Number each acceptance criterion and requirement. Mark each one met, not met or not visible after reading the code.
2. **Claims list.** Extract every behavioral claim from the PR description and test plan (or the plan doc in `local` mode).
3. **Read the change.** Diff first, then the full touched files, then direct callers and callees when a hunk changes a contract. Use `graphify path` / `explain` for blast radius when a graph exists (diff-first budget, `.claude/rules/graphify.md`).
4. **Run the dimension checks** below on every changed path. Follow each fix into every sibling path (create/update/delete/transfer, legacy and new request shapes, every marketplace or handler variant).
5. **Weigh tests as evidence** (see Tests).
6. **Reconcile prior findings** (see Re-review).
7. **Apply the materiality gate** to every candidate, then grade severity.
8. **Write the body** from review-template.md.

## Materiality gate

Keep a finding only if **all** of these hold. Otherwise drop it.

- **Scenario:** a concrete input, state or sequence leads to a wrong outcome (wrong data, lost write, open exploit, outage, misleading approval, real cost). "Could be cleaner" fails this.
- **Location:** a `path:line` or `path:start-end` at the head SHA, or "PR description" / "ticket" for ownership findings.
- **Fix:** the smallest change that closes it. Offer alternatives only when it needs a product decision.
- **Not style:** no naming, formatting, comment wording or import order. No generic "add tests".
- **Not a duplicate:** one finding per root cause. Merge same-location, same-cause candidates and keep the sharpest title.

## Severity

| Severity | Use when | Typical categories |
|---|---|---|
| `critical` | Exploitable now, or a security change does not close what it or its ticket claims | security only |
| `important` | Wrong outcome under normal use: wrong or lost data, an unmet AC that changes data, money, access or what operators act on, a write that fails after commit, or a PR description or test plan that would make an approver sign off on behavior that isn't there | correctness, security, reliability, ownership |
| `consider` | Conditional edge case, an unmet AC whose impact is UX-only (layout, collapse, focus, scroll), perf or cost, deploy ordering, duplication that will drift, or an assumption the author should verify | any |

When unsure between two levels, pick the lower one and say what would raise it. Calibration: NRD Sight rated "matrix does not auto-collapse on drill-down, as the AC require" as `consider` (afod#66), and "Admin manual purchase never persists its own api_cost_currency" as `important` (aap#350).

## Dimension checks

### correctness
- Each ticket AC is met. An unmet AC is a finding: quote the AC, and grade it by impact (see Severity), not by the fact that an AC is unmet.
- Null vs zero vs empty: `0`, `0.0`, `""`, `None`/`null` and missing keys each behave as intended, on both read and write (e.g. currency sent while amount is null).
- No silent coercion, truncation or dropped rows (`int()` on keys, client-side filtering after a server row cap, dedupe keys that merge distinct records).
- Every code path gets the fix: sibling handlers, legacy request shapes, transfer and update paths, GA and seated listings.
- Derived and shared state stays consistent after add, remove, reorder, refetch and collapse (React state keyed by index, snapshots held across refresh).
- SQL and views: every promised filter is applied, joins don't duplicate rows, guards are checked at the right grain (session vs row), and time windows and timezones match the spec.
- Validation removed without a replacement elsewhere.
- The right identifier and unit are shown (listing id vs POS id, count vs tickets).

### security
- Authorization is enforced on the server. A client-only guard is `critical` when the PR or ticket claims to close an exploit.
- Client-supplied roles, ids, `source` or owner fields are never trusted.
- Ownership and IDOR checks are real rules, not "the list endpoint returned it".
- Audit is server-side, persisted, tamper-resistant, and covers every field and request shape.
- New routes or pages have role rows or guards. Read and write permissions are separate.
- Inputs are restricted to the values the product supports (enums, timezones, ranges).
- Parameterized SQL only, with a real source → sink path before calling something injection.

### reliability
- Side-effect order and transaction boundaries: no 500 returned after a committed write; audit and outbox writes are in the same transaction or fail closed.
- Migrations ship with the code that needs them, or deploy order is stated. Note DDL lock impact (`ACCESS EXCLUSIVE`, full-table validation, rewrites).
- Freshness and staleness guards on data the logic depends on (snapshots, comps, caches).
- External calls (Snowflake, partner APIs, SQS) have timeouts, error handling, and bounded executors.
- Races and locks: pollers vs user edits, advisory-lock key scope, upsert vs insert.
- Degraded mode is visible: an empty data set doesn't silently reprice or overwrite, and it raises a metric or alert.

### performance / cost
- Per-row queries in loops, re-fetch after every insert, `FOR UPDATE` over whole sets.
- Full scans on scheduled tasks or every cache miss (Snowflake credit cost counts as `cost`).
- A new lookup with no index.
- Blocking work on the async event loop; unbounded caches.
- Extra network round trips per user action.

### ownership
- The PR description and test plan match the diff. Claims the code doesn't implement are `important`.
- The linked ticket is the right one, and the PR says when it does not fully close the ticket.
- No debug scaffolding, hard-coded local paths, or stray files.

### architecture / pattern_fit
- The defense sits in a layer that can enforce it.
- Readers and writers stay in step after a schema or table change.
- Rules duplicated across files or views that must "be kept in step" should be shared, or the drift risk stated.

## Tests

Tests are evidence, not a category. Do not file "missing tests".

- **Praise** tests that prove behavior (real query on seeded data, the edge case the bug hinges on). Name them in **Done well**.
- **Flag** a test that does not exercise the path it claims to (fixture overlaps itself, mocks the unit under test, asserts strings not behavior).
- **Flag** tests that contradict the PR description (an ownership finding).
- **In a Fix**, name the specific regression test to add ("add a legacy-shape audit test").

## Re-review

When `prior.md` exists:

1. For each prior `tb-finding` id, classify it as **verified fixed** (code changed and the scenario no longer holds), **answered by your replies** (the reply gives a valid reason or evidence), or **still open**.
2. Still-open findings keep their id and title, with `(still open from an earlier revision)` appended to **Where**.
3. If a reply doesn't resolve a finding, add **On your reply:** with the specific evidence it misses.
4. Print the counts on the **Since the last revision** line. Omit buckets that are zero.
5. Never re-raise a still-open finding under a new title.

## Writing rules

- **Verdict:** one sentence, ≤350 chars. Say whether the change does what it and its ticket claim, and name the main open risk. "This version does not fix OPE-307: …" is acceptable when true.
- **Done well:** exactly one item, specific (mechanism, file or test name). Never generic praise.
- **Finding title:** ≤110 chars and states the consequence, e.g. "Audit insert failure returns 500 after the write has committed", not "Missing try/except".
- **Finding paragraph:** ≤370 chars. Inputs → wrong outcome, using code identifiers.
- **Bullets:** `Fix` and `Where` always. `Cost` unless there is no trade-off. `On your reply` only on re-review.
- **Visibility:** list unread or truncated files in the verdict as "not reviewed: …".
- **Order:** severity (critical → consider), then the order in which the code runs.
- **No findings:** use the exact clean sentence from the template.

## Scan mode

Use [scan-template.md](scan-template.md). Scan the whole repo (or the given paths) for exploitable issues, not style. Apply these families:

| Family | Rule ids | Evidence bar |
|---|---|---|
| `secrets.*` | `committed_live`, `in_logs_or_bundle` | The value grants access (key, password, token, signed URL). Account ids, emails and queue URLs are **not** secrets. |
| `infrastructure.*` | `iam_wildcard`, `secrets_in_environment`, `public_resource` | Cite the policy statement and the resources it actually reaches. |
| `injection.*` | `sql`, `command`, `template` | Show the untrusted source → string-built sink path. A bound parameter is **not** injection. |
| `authz.*` | `idor`, `missing_server_check`, `role_bypass` | Show the endpoint and the missing server-side check. |
| `biz.*` | `unauthenticated_webhook`, `race_money`, `no_rate_limit`, `workflow_skip` | Show the reachable entry point and the business effect. |
| `supply.*` | `unpinned_dependency`, `secrets_in_environment` | Cite the manifest or build step. |

Severity in scans is `critical` or `high` only. Set **Exploitability** to `unauthenticated remote`, `authenticated low priv` or `authenticated high priv`, and **Data at risk** to `business data` or `credentials`. Dedupe by location and root cause. Redact secret values (show the first 4 characters and the length), and put ARNs and keys in code spans.

## Checklist

- [ ] Ticket AC listed and each one graded
- [ ] Description and test-plan claims checked against the diff
- [ ] Full touched files read, plus callers when a contract changed
- [ ] Every candidate passed the materiality gate
- [ ] One finding per root cause; prior ids reused
- [ ] Every finding has a scenario, Where and Fix
- [ ] Exactly one Done well; verdict ≤350 chars
- [ ] Unread files disclosed
