---
description: Create a Linear issue with a crystal-clear description; clarify vague input first; uses Linear MCP.
argument-hint: [title]
disable-model-invocation: true
---

**Scope:** Create **one new Linear issue** with a description anyone can follow (clear structure, no jargon without explanation). Use the **Linear** MCP — do not claim a ticket was created without a successful MCP response.

## Linear MCP (mandatory)

1. **Read tool descriptors** in the workspace MCP folder (e.g. `mcps/plugin-linear-linear/tools/save_issue.json`, `list_teams.json`) before calling.
2. **String rules:** For `save_issue`, pass `description` as real markdown with real newlines — not literal `\n` sequences.

### Workflow

1. **Understand the ask** — `$ARGUMENTS` is the user’s raw intent (title idea, paragraph, or half-baked note).
2. **If anything critical is missing or ambiguous**, ask **short, concrete follow-ups** before creating. Minimum clarity bar:
   - **What** is wrong or what we are building?
   - **Who** is affected (user role / system)?
   - **Done means** what (1–3 observable outcomes)?
   - For bugs: **steps to reproduce**, **expected vs actual**, **environment** (if known).
   - **Team** (if the workspace has multiple teams and the user did not say).
3. **Resolve team** — Creating requires **`team`** (and **`title`**). If unknown, call **`list_teams`** and either pick from user preference or list 3–5 sensible options and ask.
4. **Create** — Call **`save_issue`** with:
   - **`title`**: specific, action-oriented (no vague “Fix stuff”).
   - **`team`**: name or ID from `list_teams` / user.
   - **`description`**: use the template below (markdown).
   - Optional when user asked or MCP allows: **`priority`** (0–4 per tool schema), **`project`**, **`labels`**, **`assignee`** (`"me"` if they said assign to me), **`dueDate`**, **`links`**.

Do **not** pass **`id`** on create (that parameter is for updates only).

## Description template (use in `description`)

Structure the body so it is skimmable and unambiguous:

```markdown
## Summary
[One or two sentences: what this ticket is about.]

## Why it matters
[Business or user impact in plain language.]

## Context
[Any background, links, related tickets — use `links` in MCP when adding URLs.]

## What to do
Numbered steps or bullet list of work (implementation-level hints welcome).

## Acceptance criteria
- [ ] ...
- [ ] ...

## Out of scope
- ...

## Notes
[Optional: risks, rollbacks, data considerations.]
```

After **`save_issue`** succeeds, echo back the **issue identifier**, **title**, and **URL** if the API returns them, and a **one-sentence** confirmation of what was filed.

If creation fails, report the error and what you tried; do not pretend the ticket exists.
