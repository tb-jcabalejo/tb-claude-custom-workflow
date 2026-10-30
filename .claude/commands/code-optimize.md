---
description: Analyze and optimize code for performance, memory, and efficiency (measure first)
argument-hint: [file]
disable-model-invocation: true
---

Optimize the following code for performance and efficiency.

## Code to Optimize

$ARGUMENTS

## Agent Definitions

**Apply the agent-selection skill** (`.claude/skills/agent-selection/SKILL.md`): identify relevant agents and apply their perspective.

**Relevant agents:** backend-architect (backend/Python), frontend-architect (frontend/React), backend-reviewer, frontend-reviewer (checklists when backend/frontend touched). Use **performance-profiling** skill: measure first, then optimize. Produce implementation notes (what was done, deferred, before/after metrics). When following a performance rework list from Review/Test, implement only those items and produce summary and metrics for re-verification.

## Optimization strategy

### 1. Profiling first
- Identify actual bottlenecks (measure before changing code)
- Don't optimize prematurely
- Measure before and after
- Focus on high-impact areas

### 2. Backend (Python / FastAPI)
- **Database**: Add indexes for frequently queried fields; batch queries (reduce N+1); use asyncpg/SQLAlchemy efficiently; connection pooling; EXPLAIN (ANALYZE) for slow queries
- **Async**: Avoid blocking calls in async handlers; use httpx/tenacity for external calls with timeouts and retries
- **Caching**: Redis where appropriate; cache frequent queries or responses
- **Profiling**: cProfile, py-spy, memory_profiler; SQLAlchemy echo for query log

### 3. Frontend (React / Vite)
- **React**: Memoization (React.memo, useMemo, useCallback); remove unnecessary re-renders; lazy load routes/components (React.lazy + Suspense)
- **Bundle**: Vite code-splitting; dynamic imports for large libraries; tree-shaking
- **Data**: TanStack React Query for caching; debounce/throttle requests where needed
- **Profiling**: Lighthouse, Chrome DevTools Performance, React Profiler, vite-bundle-visualizer

### 4. Output
- **Analysis** – Bottlenecks identified (or rework items addressed)
- **Optimized code**
- **Explanation** – What changed and why
- **Benchmarks** – Before/after metrics or expected improvement when in scope
- **Implementation notes** (when part of cycle): what was done, deferred, before/after metrics

Never optimize without measuring first. Validate with metrics after each change.
