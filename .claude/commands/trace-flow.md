---
description: Reverse-engineer a page or user action from route load through API calls, functions, database, and UI. Writes a trace with a simplified flowchart that names every hop.
---

**Scope of this command:** Read-only reverse engineering. Do not change application code, config, or tests. The only file you may create or update is the trace at `docs/traces/<slug>.md`.

## Rules to follow

- **Token policy:** Apply `.claude/rules/token-policy.md` first. Refine the argument into one entry point (page, route, or action), then trace. No filler in the trace or the chat reply.
- **Graph-first:** Before Grep, Glob, or Read on product code, apply `.claude/rules/graphify.md` and `.claude/skills/graphify-navigation/SKILL.md`. Query each product root in scope (`graphify query` / `path` / `explain`). Do not walk the tree to orient.
- **Trace skill:** Apply `.claude/skills/trace-flow/SKILL.md` for the layer order, evidence rules, and flowchart. Write the artifact with `.claude/skills/trace-flow/output-template.md`.

## Target

$ARGUMENTS

**Interpret the arguments as:** a page, route, or user action (for example `opening the sales order page`, or `/sales-orders`). Derive `<slug>` in kebab-case (for example `sales-order-page`). If the user gives a path under `docs/traces/`, update that file. If arguments are empty, ask for the entry point and stop.

**Default scope:** the initial load — route match through the first successful data render, including every request that fires on mount. Expand click, submit, or filter handlers only when the user names that action or asks for the whole page including actions.

## Agent definitions (read-only perspective)

**Apply the agent-selection skill** (`.claude/skills/agent-selection/SKILL.md`): read the relevant definitions and use them to decide what to look for. Do not spawn them to implement or review a diff.

**Relevant agents:** frontend-architect (route, hooks, query, render), backend-architect (handler, service, SQL, tables), technical-writer (trace doc shape).

## Output

1. **Write** `docs/traces/<slug>.md` using every section in the output template. Every API and function on the traced path appears in the flowchart node label and in the hop table. Cite `file:symbol` for each hop. Mark hops you could not open as **unverified**. Do not invent handler names, SQL, or table names.
2. **Reply** with the mermaid flowchart first, then the ordered process (one line per hop), then unverified hops. Point at the trace path.

Do not implement or modify application code.
