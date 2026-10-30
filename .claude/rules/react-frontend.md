---
paths:
  - "**/*.tsx"
---

# React Frontend (Ticketboat)

**Stack:** React 18, Vite 6, TypeScript 5, Ant Design 5, Jotai (global state), TanStack React Query (server state), axios, styled-components, zod. Package manager: pnpm. Testing: Vitest, React Testing Library.

*Also applies:* `token-policy.md` (answer shape, diffs, tools). This file is stack-only; both apply.

## Component Structure
- Use functional components and hooks; avoid class components for new code.
- Keep components under ~100 lines; extract subcomponents or custom hooks when larger.
- Colocate related logic (state, effects) with the component; extract to hooks when reused.

## UI and Layout
- Use Ant Design components (Form, Table, Modal, Button, etc.) for consistency; follow Ant Design patterns and theming.
- Use styled-components for component-specific styling when Ant Design theming is insufficient.
- Responsive: use Ant Design Grid (Row/Col) and breakpoints; mobile-first where applicable.

## State & Data
- **Local UI state:** `useState`; lift state only when necessary.
- **Global/client state:** Jotai atoms; keep atoms small and focused.
- **Server state:** TanStack React Query (useQuery, useMutation); use axios for HTTP. Avoid prop drilling—use context or composition beyond 2–3 levels.

## Data Fetching and API
- Use TanStack React Query for fetching and caching; define query keys consistently.
- Validate API responses with zod where appropriate; handle loading and error states in UI.

## Accessibility
- Ensure every form input has an associated `<label>` (Ant Design Form.Item provides this; use for custom inputs).
- Use semantic HTML: `<button>` for actions, `<a>` for navigation; headings in order.
- Add `data-testid` for elements that need stable test selectors when role/label are insufficient.
- Support keyboard navigation; avoid `tabIndex` except to fix focus order. Ant Design components have built-in a11y; preserve it.

## Performance
- Memoize expensive computations with `useMemo`; memoize callbacks with `useCallback` when passing to memoized children.
- Use Vite dynamic `import()` and `React.lazy` + `Suspense` for code-splitting large routes or remotes (e.g. module federation).
- Avoid inline object/array creation in JSX props (causes unnecessary re-renders).

## Patterns
- Extract reusable UI into small, composable components; align with Ant Design design tokens where possible.
- Prefer composition over prop drilling; use compound components or render props for flexible APIs when needed.
