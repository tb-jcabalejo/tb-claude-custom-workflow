# Graphify (Ticketboat)

Each product repo in the multi-root workspace (`admin-frontend`, `admin-api-python`, `admin-api-csharp`, …) may have its own `graphify-out/graph.json`. Prefer that graph over re-reading or grepping the tree.

**Authoritative phase budget** for compounding Plan → Code → Review is below. Details: `.claude/skills/graphify-navigation/SKILL.md`. Use the **CLI** (`graphify query` / `path` / `explain`) for orientation; load the official `/graphify` skill **only** for build, `--update`, wiki, or hooks—not for routine questions.

## Phase budget (compounding cycle)

| Phase | Graphify |
|-------|----------|
| **ASK / PLAN** (`feature-plan`, `apply-ticket` plan, discovery) | **Required** before Grep/Read exploration. Prefer `graphify query "…" --budget 1500` (or `path` / `explain`). Write concrete paths into plan **File changes**. |
| **Code** | **Plan-first.** Read files listed in the plan. Query only for gaps, neighbors, or unclear blast radius—not a full re-orient when File changes are concrete. |
| **Review/Test** | **Diff-first.** Use plan AC + diff + implementation notes. Query only for dependency / blast-radius questions. |
| **Rework Code** | Prefer rework-plan paths; query only if unclear. |
| **After substantive edits** | `graphify update .` in each modified product root (AST-only, no LLM). |
| **Workflow hub** (`.claude/` / `.codex/`) | Skip graph gate. |

**Orchestrator tip:** `project-manager` / `apply-ticket` may run **one** scoped query per root and pass a short subgraph summary into subagent prompts so agents do not each re-query the same scope.

## Graph gate (when the phase requires orientation)

1. Resolve the target workspace root(s) for the task.
2. If `<root>/graphify-out/graph.json` exists, from that root (or `--graph <root>/graphify-out/graph.json`):
   - Architecture / “where is X?” → `graphify query "<question>" --budget 1500`
   - A↔B relationship → `graphify path "<A>" "<B>"`
   - One symbol/concept → `graphify explain "<concept>"`
3. If missing — tell the user to build once (`cd <root> && graphify extract . --code-only` or `/graphify .`), then use the narrowest Grep/Glob. Do not recursively Read the tree to orient.
4. Then Read/Grep only files the graph (or plan File changes / diff) pointed to.

Include a short graphify reminder in every subagent prompt that explores product code (phase-appropriate: plan-first / diff-first as above).

Also:
- If `<root>/graphify-out/wiki/index.md` exists, navigate it instead of raw files for broad orientation.
- Read `<root>/graphify-out/GRAPH_REPORT.md` only when query/path/explain are insufficient.
- User opted out or graph known stale/wrong → skip graph; use narrow Grep/Read.

**Commands:** Before `feature-plan`, `project-manager`, `apply-ticket`, `api-new`, `new-task`, or any Plan/Code exploration of product repos, follow `.claude/skills/graphify-navigation/SKILL.md`.
