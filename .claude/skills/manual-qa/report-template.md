# Manual QA: <feature> — run <N>

- **Plan:** `docs/plans/<slug>.md` (+ rework plans in scope)
- **Date (UTC):** <YYYY-MM-DD HH:MM>
- **Commit:** <short sha> (uncommitted changes: yes / no)
- **Base URL / API:** <http://localhost:5173> / <local branch API | staging> (never production)
- **Browser / viewport:** Chrome via Playwright MCP, 1440×900
- **Auth:** role <label> (verified: yes / no) · mode attended / unattended · session warning: none / ending soon (never an email)
- **Design reference:** `docs/plans/mockups/<slug>.html` | <link> | none
- **Verdict:** PASS | FAIL | BLOCKED

## Results

| AC | Case | Verdict | Evidence | Note |
|---|---|---|---|---|
| AC-1 | <short name> | PASS | `run-<N>/AC-1-<case>-<state>.png` | |

## Cases

### AC-1 — <AC text, verbatim>

- **Route:** <path>
- **Preconditions / data:** <what had to be true>
- **Steps:** <numbered, as performed>
- **Expected (from AC):** <observable outcome>
- **Actual:** <what the page showed>
- **Evidence:** `run-<N>/<file>.png`
- **Console / network:** <none | errors and failing requests during this case>

## Mockup comparison

| Element (AC) | Mockup | Actual | Result |
|---|---|---|---|

## Rework items

| Severity | AC | Suspected file | Required change | Evidence |
|---|---|---|---|---|

## Blocked

| Case | Blocker | User action needed |
|---|---|---|

## Observations (not graded)

- <AC ambiguities, AC/mockup conflicts, issues outside the changed pages>
