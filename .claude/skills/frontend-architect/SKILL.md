---
name: frontend-architect-skillset
description: Skillset for frontend design and implementation (React, Ant Design, Vite). Use when working on UI, components, accessibility, or client-side code; load referenced skills when their context matches the task.
---

# Frontend Skillset (Ticketboat)

Single entry point for **frontend** work: UI components, accessibility, performance, and client-side implementation (React 18, Vite, Ant Design, Jotai, TanStack Query). Apply the skills below when their context matches the task. Read each skill from `.claude/skills/<skill>/SKILL.md` when needed.

## Skills in this set

| Skill | Path | When to use |
|-------|------|-------------|
| `accessibility-checklist` | `.claude/skills/accessibility-checklist/SKILL.md` | Building or reviewing UI—WCAG 2.1 AA, keyboard, screen readers, semantics (Ant Design has built-in a11y) |
| `performance-profiling` | `.claude/skills/performance-profiling/SKILL.md` | Optimizing frontend—measure first (Core Web Vitals, bundle, load), then optimize |
| `refactoring-checklist` | `.claude/skills/refactoring-checklist/SKILL.md` | Refactoring components or UI—safe steps, behavior preservation |
| `code-review` | `.claude/skills/code-review/SKILL.md` | Reviewing frontend code or PRs—correctness, a11y, performance, style |

## How to use

When working on frontend tasks:

1. Read this file (`.claude/skills/frontend-architect/SKILL.md`) first.
2. **Graphify:** plan-first (`graphify.md` phase budget)—Read File changes; query only for gaps/blast radius. After edits: `graphify update .` when CLI available.
3. For the current task, determine which skills in the table apply.
4. Read those skill files from `.claude/skills/<skill>/SKILL.md` and apply their guidance.

## Alignment

- Follow project rules: `core-standards.md`, `react-frontend.md`, `typescript.md` when in scope.
- Handoff: implementation notes, tests where required, and linkage to acceptance criteria per `compounding-dev-cycle.md`.
