# Review body templates (pr / local)

Copy the shape exactly. Replace `<…>`. Leave out lines marked *optional* when they don't apply.

## Finding ids

- The id is `<sha7>-<n>`: the short head SHA of the revision where the finding was **first** raised, plus its number in that review. Example: `c240f44-2`.
- A still-open finding keeps its original id on every later revision.
- The review marker is `tb-review:<owner/repo>#<N>:<full head sha>`. In `local` mode use `tb-review:<owner/repo>@<branch>:<full head sha>`.

## Review with findings

```markdown
## Claude review

<Verdict: one sentence, ≤350 chars. Does the change do what it and its ticket claim; the main open risk; "not reviewed: <files>" if any.>

**Done well:** <one specific strength: mechanism, file or test name>

**Since the last revision:** <N earlier finding(s) verified fixed>, <N answered by your replies>, <N still open>.

**1. [<critical|important|consider> · <correctness|security|reliability|performance|cost|architecture|pattern_fit|ownership>] <Consequence title, ≤110 chars>**
<One paragraph, ≤370 chars: inputs or state → wrong outcome, with code identifiers.>
- Fix: <smallest change that closes it; name the regression test to add when one is needed>
- Where: `<path>:<line or start-end>`[; `<context path>:<line>`][ (still open from an earlier revision)]
- Cost: <what the fix costs or trades off>
- On your reply: <why the reply does not resolve it, with evidence>
<!-- tb-finding:<sha7>-<n> -->

**2. …**

_Disagree with a finding? Reply on it or in a PR comment; replies are read on the next run._

_Reviewed with Claude Code (`/nrd-review`). Findings weigh tradeoffs, not style — an empty review means nothing material was found._

<!-- tb-review:<owner/repo>#<N>:<head sha> -->
```

Optional lines:
- **Since the last revision:** only on re-review, and only the buckets that are non-zero.
- `- Cost:` leave it out when there is no trade-off.
- `- On your reply:` only when a reply exists and does not resolve the finding.

## Clean review

```markdown
## Claude review

<Verdict sentence.>

**Done well:** <one specific strength>

**Since the last revision:** <counts>.

No material findings. Architecture, security, performance, cost, reliability and correctness all look sound for this change.

_Reviewed with Claude Code (`/nrd-review`). Findings weigh tradeoffs, not style — an empty review means nothing material was found._

<!-- tb-review:<owner/repo>#<N>:<head sha> -->
```

The **Since the last revision** line appears only on re-review.

## Inline comment (posted only with `--post`)

Post one inline comment per **new** finding whose `Where` line is an added or changed line on the RIGHT side of the diff. Carried-over findings get no second inline comment.

```markdown
**[<severity> · <category>] <Title>**
<Two or three sentences: the failure scenario.>
- Fix: <…>
- Cost: <…>

<!-- tb-finding:<sha7>-<n> -->
```

## Mapping into the Plan → Code → Review cycle

When `/project-manager` or a reviewer handoff consumes this output:

| NRD severity | Rework severity |
|---|---|
| critical, important | **Critical**: triggers `docs/plans/<feature>-rework-N.md` |
| consider | **Suggestion** |
