---
description: Fetch a Linear issue, refine its spec per token-policy (tight brief + optional XML), ask or suggest when ambiguous, update the ticket when unblocked; no product code.
argument-hint: [linear-issue]
disable-model-invocation: true
---

**Scope:** Refine a **Linear ticket** into a **prompt-shaped spec** so developers and implementation agents do not burn context re-deriving scope. This is the **planning** step where missing requirements, acceptance criteria, constraints, and out-of-scope boundaries belong.

## Claude Code: spec only

Do not change application code, add implementation files, refactor, or run builds, tests, or installs. Updating the Linear issue (description, optional title) via MCP is allowed. PLAN behavior: `.claude/rules/claude-code.md`.

If the user asks you to implement or edit code, decline and point them to **project-manager** / feature agents after the ticket spec is complete.

## Token policy (mandatory)

Apply **`.claude/rules/token-policy.md`** before you write the final spec:

1. **Ingest** the issue: title, description, relations, and comments.
2. **Refine** into: one clear **objective**; **in / out of scope**; **constraints** and **forbidden** (negative rules) where they matter; testable **acceptance criteria**; **assumptions** only when you must ship a draft and ambiguity remains.
3. For **complex, ambiguous, or high-stakes** work, add a short **internal XML blueprint** (per token-policy: `<role>`, `<task>`, `<forbidden>`, `<error_handling>`, `<output_format>`, optional `<analysis>`) — see **“Issue body structure”** below. Skip the XML block only for trivial, fully specified one-line tickets.
4. **Hand off** in the issue body: the refined spec must be **scannable** (headings, lists) and **copy-pastable** into **linear/apply-ticket**, **feature-plan**, or **project-manager** without a second clarification round.

**Responses in chat:** concise, no filler, no engagement bait. Match effort to ticket size; one-line tickets get a light touch.

## Linear MCP (mandatory)

Use the **Linear** MCP; do not invent ticket content from memory.

1. **Before the first MCP call:** read the tool descriptor(s) under the workspace MCP folder (e.g. `mcps/plugin-linear-linear/tools/<tool>.json`).
2. **String rules:** pass markdown with **real newlines** — not literal `\n` escape sequences.

### Required calls (in order)

1. **`get_issue`** — `id`: Linear issue key or id from arguments (e.g. `TB-42`). Set `includeRelations`: **true**. Set `includeCustomerNeeds`: **true** when the tool supports it and product context helps.
2. **`list_comments`** — `issueId`: same identifier. Use `limit` and pagination if needed so no substantive comment is missed.

If **`get_issue`** fails: stop, report the error, and ask once for a valid **issue id or key**.

## Ticket ID (mandatory)

**Arguments:** `$ARGUMENTS`

- A **single** Linear issue identifier (team key + number, or UUID if pasted).
- If **empty** or not plausible: do **not** call MCP with a guess. Ask once: _“Provide the Linear ticket id (e.g. TB-123).”_

## When the ticket is ambiguous

**Goal:** make the work legible, not to stall forever.

- If **blocking** information is missing (e.g. no success criteria, no user/system boundary, no repro for a bug, conflicting comments), do **not** call **`save_issue`** to replace the description yet. Output **3–6 concrete questions** (numbered) or **suggested options** the team can pick from. You may still output a **draft** refined structure with an **“Open questions”** section so the next run is fast.
- If the ticket is only **mildly** thin, add an **Assumptions** subsection (short, labeled bullets) and proceed to update; note in chat that those assumptions can be revisited.
- If **relations** (blocks, related) change scope, call them out in **In scope** / **Out of scope** and in **Dependencies**.

## Refined spec content (what “good” includes)

The updated description (and your chat summary) should cover, as applicable:

- **Objective** — one sentence.
- **Problem / goal** — plain language.
- **In scope / out of scope** — explicit.
- **Constraints** — time, performance, security, feature flags, backwards compatibility, locales, etc.
- **Forbidden** — what not to do (per token-policy negative rules) when it reduces implementation drift.
- **User / system impact** — who is affected.
- **Acceptance criteria** — numbered, testable (AC-1, AC-2, …; Given/When/Then or checklist as fits).
- **Definition of done** — observable outcomes.
- **Technical notes** — API touchpoints, data, migrations, feature areas (high level only; no product code in this command).
- **Risks / open questions** — only what still matters after refinement.

## Issue body structure (markdown for `description`)

Use this order so humans and **AI** can parse the ticket reliably:

1. **Summary** — 1–2 sentences.
2. **Refined spec** — sections from “Refined spec content” above, as apply.
3. **Implementation brief (for agents)** — for non-trivial work, a **fenced** block ` ```xml ` … ` ``` ` (or a clearly labeled `### XML blueprint` section) containing the **token-policy** internal blueprint. Keep it **short**; the checklist in token-policy applies. Include `<error_handling>` for “if data is missing, do not invent” when relevant.
4. **Source** — one line: “Refined from: original title/description & N comments; relations: …” if useful for audit (optional, brief).

**Title:** if the current title is vague, propose a **clearer, action-oriented** title. Call **`save_issue`** with `id` + `title` + `description` when you update, only if the new title is strictly better and not a scope change the team did not ask for; otherwise only update `description`.

## Persisting to Linear

- If **no blocking open questions** (or the user has explicitly asked in chat to **apply the draft** including assumptions), call **`save_issue`** with:
  - **`id`**: the issue id/key
  - **`description`**: full refined markdown
  - **`title`**: optional, per above
- If **blocking questions** remain, **do not** overwrite the team’s description: output questions and the draft; optionally use **`save_comment`** with a short note + questions **only** if the team wants a record in Linear before answers (use sparingly).

## Handoff (chat, closing lines)

- Tell the user the ticket is ready for **linear/apply-ticket** (read ticket → plan → code → review) or **feature-plan** / **project-manager** when a repo plan file is also needed without fetching from Linear again.
- If an XML block was added, state that it is for **downstream agent prompts** and matches **token-policy**.

## Cross-command relationship

- **create-ticket** — file new work.
- **refine-ticket** (this) — **spec quality gate**; align description with token-policy before heavy planning.
- **linear/apply-ticket** — read ticket, author repo plan, run Code → Review/Test (Linear unchanged).
