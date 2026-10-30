---
name: graphify-navigation
description: Query Ticketboat product-repo knowledge graphs before Grep/Read exploration. Use when feature-plan, project-manager, apply-ticket, api-new, new-task, or any agent needs codebase orientation and graphify-out/ may exist in a workspace root.
---

# Graphify navigation (Ticketboat)

Graph-first orientation for product repos. Cuts token cost by avoiding full-tree re-reads. Complements the official `/graphify` skill at `.claude/skills/graphify/` (**build/update/wiki/hooks only**—do not load it for routine `query` / `path` / `explain`).

Phase budget authority: `.claude/rules/graphify.md`.

## When to run

| Condition | Action |
|-----------|--------|
| **ASK / PLAN** — architecture, file mapping, technical design | Run graph gate below before Grep/Glob/Read |
| **Code** — plan has concrete **File changes** | Plan-first: Read listed files; query only for gaps / blast radius |
| **Review** — diff + AC + implementation notes available | Diff-first; query only for dependency / blast-radius questions |
| Editing only `.claude/` / `.codex/` / this workflow hub | Skip graph gate |
| User says not to use graphify, or graph is known stale/wrong | Skip graph; use narrow Grep/Read |

## Graph gate (strict order)

1. **Resolve roots** — Identify workspace root(s) in scope (`admin-api-python`, `admin-frontend`, `admin-api-csharp`, …).
2. **Probe** — For each root, check `<root>/graphify-out/graph.json`.
3. **If present** — From that root (or with `--graph <root>/graphify-out/graph.json`):
   - Architecture / “where is X?” → `graphify query "<question>" --budget 1500`
   - A↔B relationship → `graphify path "<A>" "<B>"`
   - One symbol/concept → `graphify explain "<concept>"`
4. **If missing** — Tell the user to build once, then continue with the narrowest search:
   ```bash
   cd <root> && graphify extract . --code-only
   # or in chat: /graphify .
   ```
   Do not recursively Read the tree to orient.
5. **Then edit** — Read/Grep only the files the graph, plan File changes, or diff pointed to.

## Subagent handoff

Every explore/implement/review subagent that touches product code must receive a **phase-appropriate** line:

- **Code:** `Follow graphify.md phase budget: plan-first (File changes); query only for gaps/blast radius. Target root: <root>. After edits: graphify update . when CLI available.`
- **Review:** `Follow graphify.md phase budget: diff-first; query only for dependency/blast radius. Target root: <root>.`

**Orchestrator:** Prefer one scoped query per root; paste a short summary into subagent prompts so agents do not each re-query the same scope.

## After Code phase edits

In each modified product root: `graphify update .` (AST-only). Skip if `graphify` is not on PATH; note it in implementation notes.

## Checklist

- [ ] Target root(s) identified
- [ ] Phase budget applied (PLAN required / Code plan-first / Review diff-first)
- [ ] Graph queried when required (or missing-graph message + narrow search)
- [ ] No broad tree walk before graph/query (when orientation is required)
- [ ] Subagent prompts include phase-appropriate graphify line
- [ ] `graphify update .` after substantive code edits (when CLI available)
- [ ] Official `/graphify` skill not loaded for routine query/path/explain

## Build / full skill

Rebuilds, `--update`, wiki, hooks: use `.claude/skills/graphify/SKILL.md` or `/graphify`. Upstream: https://github.com/Graphify-Labs/graphify
