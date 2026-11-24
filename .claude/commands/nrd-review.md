---
description: Review a PR (or the current branch before a PR exists) the way NRD Sight does. Material findings only, graded critical / important / consider with Fix / Where / Cost, checked against the linked Linear ticket. Saves docs/reviews/<repo>-<N>-<sha7>.md; posts to GitHub only with --post.
argument-hint: <owner/repo#N | PR URL | N> [--sha <commit>] [--compare] [--post] | --local [base-ref]
disable-model-invocation: true
---

**Scope of this command:** **AGENT (Review)**, read-only. Do not change application code, config, tests or plans.
- **Files you may create:** `docs/reviews/<repo>-<N>-<sha7>.md` (local mode: `docs/reviews/<repo>-<branch>-<sha7>.md`) in the folder you were started from.
- **Posting:** you post to GitHub only when the arguments include `--post`. When you do, the review is always a `COMMENT`, never `APPROVE` or `REQUEST_CHANGES`.

## Rules to follow

- **Token policy:** `.claude/rules/token-policy.md`. Build the bundle, hand it off, and validate what comes back. Do not re-review the code yourself.
- **Graphify:** Diff-first (`.claude/rules/graphify.md`). The reviewer queries only for blast radius.
- **Skill:** `nrd-review` (`SKILL.md` and `review-template.md` in `skills/nrd-review/` of the same `.claude/` folder).

## Target

$ARGUMENTS

**Interpret the arguments as:**
- `owner/repo#N` or `https://github.com/owner/repo/pull/N` → PR mode.
- A bare `N` → PR mode in the repo of the current folder (`gh repo view --json nameWithOwner`).
- `--local [base-ref]` → review the current branch against `base-ref` (default `origin/<default branch>`), before a PR exists.
- `--sha <commit>` → review the PR at an earlier commit (calibration).
- `--compare` → after the review, compare it with NRD Sight's review of the same commit.
- `--post` → post the review to the PR.

If the arguments are empty, ask for the PR and stop.

## Phase A — Bundle

1. Run `scripts/nrd-review-bundle.sh` from the `.claude/` folder this command was loaded from: `~/.claude/` for a user-level install, otherwise `<workspace root>/.claude/`. Call it as `"$HOME/.claude/scripts/nrd-review-bundle.sh"` (or the workspace path) from the folder you were started from, with the PR arguments: `<owner/repo> <N> [--sha …] [--workspace <folder you were started from>]`, or `--local [base]`. Keep the `KEY=value` lines it prints.
   - The script needs `gh` (signed in), `git` and `jq`.
   - If it fails, show its error and stop.
2. **Ticket.** For each key in `TICKET_KEYS`, call the Linear MCP `get_issue` with fields `title, description, url`. Write the first one that resolves to `<BUNDLE>/ticket.md` as `# <KEY>: <title>` followed by the description. If none resolve, leave `none` and note "no linked ticket".
3. **Size check.** If `DIFF_LINES` is over 6,000, tell the user, list the largest files from `pr.json`, and continue. The reviewer will disclose any files it could not read.

## Phase B — Review

Spawn **`nrd-reviewer`** with the Agent tool and this brief. Pass paths, not file contents:

```
mode: <pr|local>
bundle: <BUNDLE>
checkout: <CHECKOUT>
review_id: <REVIEW_ID>
sha7: <SHA7>
Load the nrd-review skill (SKILL.md and review-template.md) first. Diff-first graphify budget.
Return the review body, then the json block.
```

Never pass `<COMPARE>` or its contents to the reviewer.

## Phase C — Validate and save

1. **Check the body** against these rules:
   - It starts with `## Claude review`.
   - It has one verdict sentence and exactly one `**Done well:**`.
   - Every finding line matches `^\*\*\d+\. \[(critical|important|consider) · (correctness|security|reliability|performance|cost|architecture|pattern_fit|ownership)\] .+\*\*$`.
   - Every finding has `- Fix:` and `- Where:` and is followed by `<!-- tb-finding:… -->`.
   - It ends with the `tb-review` marker.
   - If there are no findings, the clean sentence is present.
2. **If a rule fails**, send the reviewer one follow-up via SendMessage naming the failures. Accept the second answer whatever it is, and note any remaining issue in the reply.
3. **Save** the body to `docs/reviews/<repo>-<N>-<sha7>.md`. Create `docs/reviews/` if needed. Put the json block under a `<details><summary>findings.json</summary>` at the end of the file. That block is not posted.

## Phase D — Compare (only with `--compare`)

1. Read `<COMPARE>`. If it is `none`, say NRD Sight has not reviewed this PR and skip this phase. If `same_sha: false`, say which commit NRD reviewed.
2. Match findings by root cause: the same file and the same failure, with lines within about 20 of each other or the same symbol.
3. Append this to the saved file. It is never posted.

```markdown
## Comparison with NRD Sight (<nrd sha7>)

| NRD finding | Ours | Match | Severity |
|---|---|---|---|
| [important · correctness] … | #2 … | yes / partial / missed | same / higher / lower |
| — | #3 … | extra | — |

Recall: <matched>/<NRD total> · Extra: <n> · Severity agreement: <same>/<matched>
```

## Phase E — Post (only with `--post`)

1. **Pick inline comments.** For each finding with `"new": true` whose `path:line` is listed in `<RIGHT_LINES>`, build one inline comment from the template.
2. **Post one review:**

```bash
jq -n --arg sha "$SHA" --rawfile body <saved-body-without-details-or-comparison> --argjson comments '<[{path,line,side:"RIGHT",body}]>' \
  '{commit_id:$sha, event:"COMMENT", body:$body, comments:$comments}' \
| gh api -X POST "repos/$REPO/pulls/$N/reviews" --input -
```

3. **If GitHub rejects an inline line (422)**, post again without that comment and say so.
4. **Local mode has no PR**, so never post. Say: run again with the PR number after you open it.

## Phase F — Clean up and reply

1. Run the same `nrd-review-bundle.sh` with `--cleanup <ROOT>`.
2. Reply in this order:
   1. The verdict sentence.
   2. One line per finding: `severity · category — title (path:line)`.
   3. Prior findings: fixed / answered / open counts.
   4. The comparison summary line, if `--compare` was used.
   5. The saved path, and "posted" or "not posted".

When `/project-manager` or a rework plan consumes the result, map **critical** and **important** to **Critical**, and **consider** to **Suggestion**.
