---
description: Draft my daily report (what I did, what I'll do next working day, blockers) from Linear, local git commits/pushes, and Microsoft Teams. Read-only.
argument-hint: [48h | 3d | since <date time> | next=<YYYY-MM-DD>]
disable-model-invocation: true
---

**Scope:** Read-only. Gather my activity from Linear, local git, and Teams, then print a paste-ready report. Never post to Teams, edit Linear, or run `git fetch`/`push`. If I ask afterward to post it, show the exact text and target chat and wait for my yes.

**Token policy:** `.claude/rules/token-policy.md`. Fetch in parallel, keep only fields you need, no raw dumps in the reply.

## 1. Resolve the window

From `$ARGUMENTS`:

| Input | Window |
|---|---|
| empty | last 24 hours |
| `48h`, `3d` | that many hours/days back |
| `since <date time>` | from that local time to now |
| `next=<YYYY-MM-DD>` | overrides the next working day |

- **Shift date:** today's local date, or yesterday's if it is before 12:00 local (covers shifts that run past midnight).
- **Next working day:** the next Mon–Fri after the shift date.
- If the default window turns up nothing in every source, widen to 72 hours once (covers Monday after a weekend) and say so in the footer.

## 2. Gather (one parallel batch)

Tool prefixes differ per install; match on the tool name.

**Git (local repos):** run `scripts/daily-git-activity.sh --since "<window start>"` from the `.claude/` folder this command was loaded from (`~/.claude/` for a user-level install, else `<workspace root>/.claude/`).
It lists, per repo one level under the workspace root (`~/Documents/TicketBoat` when installed in `$HOME`; override with `DAILY_REPORT_ROOTS`), my commits (all branches, merges included), pushes from the remote-tracking reflog, current branch, uncommitted file count, and unpushed commits. It only sees pushes made from this machine.
If `gh` is on PATH and logged in, also run `gh search prs --author=@me --updated=">=<date>"` and `gh search prs --reviewed-by=@me --updated=">=<date>"`. Otherwise skip; merged PRs still show as `Merge pull request #N` commits.

**Linear MCP** (`whoami` first if you need my user):
- `list_issues` assignee `me`, `updatedAt` = window start (ISO-8601 duration like `-P1D` or a timestamp).
- `list_issues` assignee `me`, `completedAt` = window start.
- `list_issues` assignee `me`, `state` `started` (carries into tomorrow).
- `list_issues` assignee `me`, `state` `unstarted`, limit 25 (candidates for tomorrow).
- Use `fields`: `id, title, status, statusType, priority, dueDate, labels, project, url, updatedAt, completedAt`.
- Then `get_issue` for any key (`[A-Z]+-\d+`) found in commit subjects or branch names that is not already loaded, and `list_comments` on up to 8 issues updated in the window to find blocker or hand-off notes.

**Microsoft 365 MCP** (`get_me` first for my address):
- `chat_message_search` query `*`, `sender` = me, `afterDateTime` = window start. Page once more if `nextOffset` is set.
- `chat_message_search` query `blocked OR blocker OR "waiting on" OR "waiting for" OR stuck OR "need access" OR "can't"`, `afterDateTime` = window start. Keep only messages in my chats that involve me or my tickets.
- `outlook_calendar_search` query `*` between window start and now (meetings I had), and from 12:00 on the next working day to 12:00 the day after (evening shifts cross midnight).
- Messages may be in any language. Summarize in English.

If a source fails or is not connected, continue with the rest and name it in the footer. Do not retry the same failing call.

## 3. Correlate and classify

- Group everything by Linear key. Branch `<user>/ope-464-...` means OPE-464. Work with no key groups under its repo name.
- **What I did:** issues completed or moved to a new status; commits and pushes summarized as outcomes per ticket (not a commit list); merged PRs as `repo#N`; Teams threads where I unblocked, reviewed, or coordinated; notable meetings (skip routine stand-ups).
- **Next working day:** in-progress issues with the remaining step inferred from the latest commit or WIP; branches with uncommitted or unpushed work; PRs awaiting review or merge; top unstarted issues by due date, then priority; meetings on that day; follow-ups I promised in Teams ("I'll check tomorrow").
- **Blockers:** issues with a Blocked status or label, or blocked-by relations; comments or messages saying I am waiting on someone (review, access, deploy, data, decision). Name who or what it waits on. If nothing qualifies, write `None`.
- Every bullet must trace to a source item. Do not invent work, owners, or dates. Mark guesses with `(inferred)`.

## 4. Output

Print only this block, ready to paste into Teams. Max 6 bullets per section, one line each, plain language, no commit hashes:

```markdown
**Daily Report: <Ddd, Mon D, YYYY (shift date)>**

**What I did today**
- OPE-123 <Issue title>: <outcome>. <PR / status, e.g. merged repo#106, moved to In Review>

**What I'll do next working day (<Ddd, Mon D>)**
- OPE-124 <Issue title>: <next step>

**Blockers**
- None
```

Then, below a `---`, one footer line: window used, item counts per source (`Linear n, git n commits / n pushes, Teams n messages / n meetings`), and any source that was unavailable or skipped.
