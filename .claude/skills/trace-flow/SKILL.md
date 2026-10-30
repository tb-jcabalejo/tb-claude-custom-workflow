---
name: trace-flow
description: >-
  Reverse-engineer a user-facing flow from page load through the API client,
  backend functions, database, and UI render. Use when running the trace-flow
  command, or when the user asks how a page, route, or action loads data,
  which APIs and functions it calls, or for a flowchart of that process.
---

# Trace flow

Read-only. Reconstruct one entry point as an ordered hop list and a simplified flowchart. Name every API and function on the path. Cite code. Do not invent missing layers.

## Refine first

Turn the argument into:

- **Entry:** page name, route path, or action (one).
- **Scope:** `load` (default) or `load + named actions`.
- **Slug:** kebab-case file stem for `docs/traces/<slug>.md`.

If the entry is ambiguous (several pages match), list the candidates and ask. Do not trace all of them.

## Roots

1. Workspace that contains the UI (this repo unless the user names another).
2. Sibling product repos if they exist next to the workspace (`admin-api-python`, `admin-api-csharp`, and any path the user gives). Probe `graphify-out/graph.json` in each root before searching that root.
3. If a backend root is absent, stop that side at the HTTP contract and mark later hops **unverified**. Do not guess the handler, SQL, or tables.

## Graph gate

Per `.claude/skills/graphify-navigation/SKILL.md`, for each in-scope root:

- `graphify query "<page or action> route component API"` for the entry.
- `graphify path "<page symbol>" "<api function>"` once both names are known.
- `graphify explain "<handler or repository>"` when the backend root has a graph.

Then Read or Grep only the files the graph (or a single narrow search) names.

## Layers (follow in order)

Record a hop only when a file shows the call. Skip a layer that the code does not have, and say so.

| # | Layer | What to capture |
|---|--------|-----------------|
| 1 | Route | Path, router file, page component that mounts |
| 2 | Page | Mount effects, Jotai atoms read, TanStack Query keys, child components that fetch |
| 3 | Client | Function in `src/api` (or equivalent): HTTP method, path, query/body type |
| 4 | Transport | `apiClient` interceptor behavior that affects this call (auth header, base URL, error path). One hop, not a line-by-line dump |
| 5 | API | Backend route: method, path, handler function, auth dependency |
| 6 | Functions | Service and domain functions in call order |
| 7 | Data access | Repository, query builder, or SQL function |
| 8 | Database | Engine (Postgres or Snowflake), tables or views, filters that match this request. Cite the query or migration that names them |
| 9 | Render | Mapper or column/render function that places response fields on screen |

Parallel fetches on mount are sibling branches, not a single merged hop.

## Evidence

- Prefer the symbol the UI calls, then the callee, until the query or the workspace boundary.
- Quote method + path exactly as written. Note env base URL (`VITE_API_URL` or equivalent) without printing secrets.
- Database claims require a query, ORM call, or migration that names the relation. If only the handler is visible, stop at the handler.
- When graph and source disagree, source wins. Note the disagreement in **Gaps**.
- Do not paste large SQL. Name the statement's tables, joins, and predicates, and cite `file:line`.

## Flowchart

Build the chart from the hop list after the list is complete. Rules and the trace file shape are in [output-template.md](output-template.md).

- One `flowchart TD` for the load path. Add a second chart only for a named action.
- Every API and every function on the path is its own node. Collapse a hop only when it forwards arguments with no branch, no mapping, and no I/O — and list collapsed symbols under the chart.
- Node label: `` `symbol` `` plus method and path for HTTP, or `` `table` `` for database.
- Group with `subgraph` per layer: Page, Client, API, Functions, Database, Render.

## Finish

1. Write `docs/traces/<slug>.md` from the output template.
2. Chat reply: mermaid chart, then one line per hop, then gaps. Link the file path.
3. Do not edit application code. Do not run `graphify update` (no code change).

## Checklist

- [ ] Single entry and scope
- [ ] Graph queried (or missing-graph note) before broad search
- [ ] Each hop has file and symbol, or is marked unverified
- [ ] Flowchart node labels include every API and function kept on the path
- [ ] Database engine and relations cited, or explicitly unverified
- [ ] No invented symbols
