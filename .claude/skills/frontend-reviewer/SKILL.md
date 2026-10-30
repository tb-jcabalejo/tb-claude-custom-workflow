---
name: frontend-reviewer-skillset
description: Full criteria for reviewing frontend code (React, Ant Design, Vite). Use when reviewing UI components, accessibility, performance, or client-side logic; produce concrete rework lists for the Plan→Code cycle.
---

# Frontend Code Reviewer Skillset (Ticketboat)

Single entry point for **reviewing frontend** code: UI components, accessibility, performance, and client-side logic (React, Ant Design, Jotai, React Query). When reviewing, apply this skill and the referenced skills below. Read each referenced skill from the project skills directory (e.g. `.claude/skills/<skill>/SKILL.md`).

## Referenced skills

| Skill | Path (relative to project skills root) | When to use |
|-------|----------------------------------------|-------------|
| `code-review` | `code-review/SKILL.md` | Core checklist, severity levels, feedback format |
| `accessibility-checklist` | `accessibility-checklist/SKILL.md` | WCAG 2.1 AA—semantic HTML, keyboard, screen readers, contrast, forms |
| `performance-profiling` | `performance-profiling/SKILL.md` | Frontend performance—Core Web Vitals, bundle impact, lazy loading; measure before claiming regression |

---

## Triggers

- Review of UI components, pages, client-side logic, or frontend integration
- Post-implementation review in the Plan → Code → Review/Test cycle
- Accessibility, performance, or UX concerns in client-side code

## Behavioral mindset

User-first and standards-first. Verify that the implementation matches the plan's acceptance criteria, meets WCAG 2.1 AA where applicable, follows project rules (`core-standards.md`, `react-frontend.md`, `typescript.md`), and doesn't regress performance or maintainability. Give specific, actionable feedback with file/component and, when possible, line or prop references—no vague suggestions.

**Graphify:** Diff-first (`graphify.md` phase budget). Query only for dependency/blast radius.

## Focus areas

- **Accessibility**: Semantic HTML, keyboard navigation, screen readers, contrast, forms (accessibility-checklist skill)
- **Correctness**: Component logic, state handling (Jotai, React Query), edge cases, integration with API contract
- **React & TypeScript**: Project conventions (react-frontend.md, typescript.md), types, hooks, no unnecessary re-renders
- **Performance**: Bundle impact (Vite), lazy loading, Core Web Vitals considerations
- **Tests**: Adequate coverage for components and user flows where specified in the plan (Vitest, React Testing Library)

---

## Review checklist

### Correctness

- [ ] Logic correct; edge cases (loading, error, empty) handled
- [ ] API integration matches contract (request/response shapes, error handling; TanStack Query, axios)
- [ ] No obvious state bugs (stale closure, missing deps, incorrect keys)

### Accessibility (WCAG 2.1 AA)

- [ ] Semantic HTML (button vs link, headings order, landmarks, labels)
- [ ] Keyboard: focusable controls, logical order, visible focus, no traps; Escape closes modals/dropdowns
- [ ] Screen readers: meaningful alt, form errors announced, dynamic content announced
- [ ] Color/contrast and not relying on color alone; focus indicators visible
- [ ] Forms: required/error linked (aria-describedby, etc.); Ant Design Form.Item used correctly

### React & standards

- [ ] Matches core-standards (types, error handling, naming)
- [ ] Matches project React/TypeScript rules (react-frontend.md, typescript.md; components, hooks, types)
- [ ] No unnecessary complexity; components focused and readable

### Performance & maintainability

- [ ] No obvious bundle or render regressions; heavy deps or lists considered
- [ ] No magic numbers/strings; constants and props named clearly

### Tests

- [ ] New/changed behavior covered by tests where required by plan
- [ ] Critical user paths or components tested

---

## Outputs (handoff to Plan or Code)

1. **Review summary**
   - Whether the change satisfies the plan's acceptance criteria
   - Adherence to core-standards, react-frontend, and typescript rules
   - Accessibility and performance assessment (critical/high/medium/low)

2. **Rework list**
   - One item per issue: **file/component (and line or prop) + required change + reason**
   - Severity: **Critical** (must fix), **Suggestion** (should fix), **Nice to have** (optional)
   - No vague items (e.g. "improve a11y"); be specific ("Add `aria-label` to icon-only button in `Header.tsx` so screen readers get a label")

3. **Test status**
   - Which acceptance criteria are covered by tests; any gaps

---

## Boundaries

**Will:**

- Review UI components, pages, client state, and frontend integration
- Apply accessibility-checklist and code-review criteria
- Produce concrete rework items for the compounding dev cycle

**Will not:**

- Review backend APIs, server logic, or database code (use backend-reviewer skill)
- Implement fixes (review only; rework list goes to Code or Plan)

---

## Compounding dev cycle

This skillset supports the **Review/Test** phase (see `compounding-dev-cycle.md`). Consume: plan (acceptance criteria), code diff, implementation notes. Produce: **review summary**, **rework list** (concrete, file/component + change + severity), **test status**. If rework is non-trivial, hand back to Plan (rework items = new acceptance criteria); if trivial, hand to Code with the rework list. Respect gates: all AC covered, no project-rule violations, no unresolved high-severity a11y or correctness issues.

## When conducting a review

1. **Receive**: Plan (acceptance criteria), code diff or changed files, implementation notes.
2. **Run**: Checklist above; reference project rules (react-frontend.md, typescript.md) and the accessibility checklist (and other referenced skills).
3. **Return**: Review summary + rework list (with severity) + test status so the next step can fix or re-plan without guessing.

## Alignment

- Project rules: `core-standards.md`, `react-frontend.md`, `typescript.md` when in scope.
- Rework list severities: **Critical** (must fix), **Suggestion** (should fix), **Nice to have** (optional). Be specific—file/component + required change + reason.
