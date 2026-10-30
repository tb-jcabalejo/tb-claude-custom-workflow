# TokenPolicy

**Authoritative** for how the agent spends context in this repo. `core-standards.md` and `compounding-dev-cycle.md` point here; stack rules are additive.

**Goal:** Spend context on actions and decisions. Avoid noise, repeated reads, and oversized replies.

## Session entry flow: refine, then hand off

Use this **before** invoking **commands** (e.g. `feature-plan`, `project-manager`), loading **skills**, or delegating to **agents** for implementation. The first hop turns a raw user message into a **tight spec** so later steps do not waste context rediscovering scope.

1. **Ingest** the user message and any attached context (`@` files, selections).
2. **Refine** per this file: one clear **objective**, in/out **scope**, **constraints** and **forbidden** where it matters; for complex, ambiguous, or high-stakes work, add a short **internal XML blueprint** (see [Complex work: internal XML blueprint](#complex-work-internal-xml-blueprint)). *Skip* heavy refinement only for trivial, fully specified one-liners.
3. **Hand off** that refined spec—**not** a meandering restatement—to the right **command**, **skill**, or **agent**. Downstream work should start from a **prompt-shaped** brief so tokens go to **custom implementation** in the product repos, not to re-clarification or filler.

`compounding-dev-cycle` (ASK → PLAN → AGENT, …) layers on top: **refine** is the **default gate** at session start; mode switching still follows the plan cycle for features.

## Responses and shape

- **Concise, complete** sentences; depth matches task size (a one-line fix: no recap or essay).
- **No filler** (thanking, hedging, “happy to help”), **no engagement bait**, **no restating** the ask unless disambiguation needs it. Open with **substance**, not preamble; drop hedged first lines.
- **One structured answer** when possible. Headings only if they add scan value.

## Code and repo context

- **Graph-first (product repos):** Follow `.claude/rules/graphify.md` **phase budget** (PLAN required; Code plan-first; Review diff-first). Details: `.claude/skills/graphify-navigation/SKILL.md`. Escape hatch: graph missing, user opted out, or editing only this workflow hub.
- **Chat split:** After PLAN (`feature-plan` / `apply-ticket`), run `/clear`, then `/project-manager <plan-path>`, so plan-authoring context does not stack into Code.
- **Smallest diff** that proves the change; use `...` in code citations to skip noise.
- Prefer **code citations** (`start:end:path`) over pasting files; no large dumps unless the user needs them.
- **Batch** related reads/searches; read surrounding code **once** before edit; don’t re-read unchanged files.
- **Search** (symbol, error, route) before full-file read when the needle is narrow — and only after the graph gate when a graph exists.
- No **exploratory** commands the task did not require.

## When to go long

- Step-by-step, tradeoffs, debugging, or teaching **when the user asked**—still skip repetition and irrelevant edge cases.

## Complex work: internal XML blueprint

Use a **tight internal blueprint** (XML tags for the contract—not JSON) only when: multi-step reasoning, unclear scope, many sources, high correctness risk, or the user asked for prompt refinement. **Skip** for obvious one-file/one-symbol tasks (still: no filler, clear output). *Why use XML over a single prose block?* See **README** → [Why XML beats a single prose prompt](#why-xml-beats-a-single-prose-prompt) (this repo’s `README.md`).

**Order:** finish **`<analysis>`** (plan, risks, file touch list) before user-facing prose. **`<output_format>`** must be surgical: section titles, per-section limits, citation rules—not “write a summary.”

**Tags (pick what applies; keep the blueprint short):**

- `<role>` — **Job-style** title, stack, tools, measurable priorities—not “you are an expert.”
- `<task>` — Single clear deliverable. `<constraints>` / `<forbidden>` — **Hard** limits and **negative** rules (jargon, extra asks, banned paths); boundaries shape quality.
- `<documents>` — `<document index="n" path="…">` per source; cite by index+path when multiple.
- `<error_handling>` — Missing data, ambiguity, conflict: state limits, **don’t** invent facts.
- `<output_format>` — Headers, max bullets/lines, confidence where needed, citation form.
- `<example>` (few-shot) — **input → analysis chain → output**, not just input → output.
- Reusable prompt assets: **versioned** in-repo, tagged by use case, sanity-checked on a baseline when stakes are high.

**Check (complex only):** specific `<role>`, at least one real `<forbidden>`, concrete `<output_format>`, multi-source + `<documents>` if needed, `<error_handling>` for unknowns, one short blueprint (not a parallel essay).

**Minimal pattern:**

```xml
<role>[Title]; [stack]; priorities: [metric], [quality], [security/perf].</role>
<task>[Outcome]</task>
<forbidden>[No X, no Y]</forbidden>
<documents><document index="1" path="[path]">[excerpt or pointer]</document></documents>
<error_handling>If [gap]: [action]. If [conflict]: [action].</error_handling>
<analysis>1) … 2) … 3) …</analysis>
<output_format>## [Section] (max N) … Cite: doc n + path</output_format>
```

## Precedence

- Extends project Core Standards. If anything conflicts, the **stricter** boundary wins (secrets, PII, safety, repo policy).
