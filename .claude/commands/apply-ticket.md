---
description: Fetch a Linear issue (read-only) and author a repo plan. Default stops after PLAN; Code/Review via /project-manager after /clear. Does not mutate Linear.
argument-hint: [linear-issue]
disable-model-invocation: true
---

You are the **linear/apply-ticket** orchestrator. Fetch **one Linear issue**, refine it, and write a repo plan. Follow **`.claude/rules/token-policy.md`**, **`.claude/rules/graphify.md`** (phase budget), and **`.claude/rules/compounding-dev-cycle.md`**.

**Default scope:** Read ticket → ASK if blocked → **PLAN only** → hand off. **Do not** load `project-manager` or `agent-selection` skills unless the user explicitly opts into in-chat Code (see below).

**Forbidden:** any write to Linear. **Allowed:** `docs/plans/*.md` (and Code/Review only when user opts in).

## Ticket ID (mandatory)

**Arguments:** `$ARGUMENTS`

- A **single** Linear issue identifier (e.g. `TB-42` or UUID).
- If empty or not plausible: ask once for the id. Do not guess MCP calls.

## Linear MCP — lean read (mandatory)

1. Discover tool schemas before the first call; do not invent tool names.
2. **Allowed:** read tools only (`get_issue`, `list_comments`, …). **Forbidden:** `save_issue`, `save_comment`, `update_*`, or any mutation.
3. **Fetch order:**
   1. **`get_issue`** — `includeRelations`: **true**. Set `includeCustomerNeeds`: **false** unless the ticket is clearly customer/need-driven.
   2. **`list_comments`** — only if description is thin, conflicting, or missing AC; otherwise skip. If used, stop after the first page unless a comment clearly continues the thread.
4. If `get_issue` fails: stop, report error, ask once for a valid id.

**After fetch:** Refine once. Do **not** re-paste Linear body/comments into later turns—plan path + AC only.

## Token policy

1. Ingest title, description, relations, (comments if fetched).
2. Refine: objective; in/out scope; constraints/forbidden; AC-1…; Assumptions only when thin but unblocking.
3. Complex/ambiguous: short internal XML blueprint in the plan. Skip for trivial tickets.
4. Vague tickets: prefer **linear/refine-spec** first, then re-run apply-ticket.

## Graphify

Follow `graphify.md` phase budget (PLAN = required `query --budget 1500` / path / explain before explore; write **File changes**). CLI only—do not load the full `/graphify` skill.

## Phase 0: ASK (only when blocked)

If blocking info missing: 3–6 questions or options; optional draft outline with Open questions; **stop**. Mildly thin → Assumptions in plan and continue.

## Phase 1: PLAN (always)

**Mode:** PLAN. No application code.

1. Slug: lowercase hyphenated, ticket-prefixed when helpful → **`docs/plans/<feature-slug>.md`**.
2. Graphify orient, then write the plan with these sections (inline—do **not** open `feature-plan.md` / `feature-planning` skill unless a section is unclear):
   - Scope / Metadata (`Linear: <KEY>`, title, link)
   - Feature Overview
   - Acceptance criteria (AC-1…)
   - Technical design
   - Backend tasks and/or C# Backend tasks and/or Frontend tasks (only what applies)
   - Integration & testing, File changes, Dependencies / env
3. Agent scope note in plan: which of backend-architect / frontend-architect / reviewers apply.
4. **Gate:** another agent can implement without guessing.

## Default exit (mandatory)

After the plan file is written and the gate passes:

1. **Stop.** Do not spawn Code or Review agents.
2. Tell the user: run **`/project-manager docs/plans/<feature-slug>.md` after `/clear`** for Code → Review.
3. Summarize: ticket key, plan path, AC count, domains in scope.

**In-chat Code (opt-in only):** Continue to Code/Review in this thread **only if** the user explicitly says so (e.g. “continue in this chat”, “implement now”). Then follow `.claude/commands/project-manager.md`: pass **plan path + domain sections** (not Linear dumps); graphify plan-first / diff-first; spawn only agents the plan needs.

## Handoff discipline

- State mode (ASK / PLAN / AGENT) when delegating.
- Prefer plan path over pasting plan body into prompts.
- Cross-command: **refine-spec** (mutates Linear) before apply when vague; **project-manager** for Code/Review after PLAN.
