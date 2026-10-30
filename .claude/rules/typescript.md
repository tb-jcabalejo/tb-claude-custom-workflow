---
paths:
  - "**/*.ts"
---

# TypeScript

**Context:** Ticketboat frontend uses ESM modules, pnpm, and Vitest. Prefer strict typing; validate runtime data with zod where needed.

*Also applies:* `token-policy.md` (answer shape, diffs, tools). This file is language-only; both apply.

## Types
- Avoid `any`; use `unknown` for truly unknown values, then narrow with type guards
- Prefer `interface` for object shapes; `type` for unions, intersections, and mapped types
- Use `strictNullChecks`; handle `null` and `undefined` explicitly
- Export types alongside the code that uses them; avoid separate type-only files unless shared

## Declarations
- Use `const` by default; `let` only when reassignment is needed
- Prefer `const` assertions for literal types: `as const`
- Use `readonly` for arrays/objects that should not be mutated

## Functions
- Always type function parameters and return types for public APIs
- Use optional params (`?`) or overloads for flexibility; avoid `any` in signatures
- Prefer `void` for functions that return nothing; avoid implicit `undefined` returns

## Imports
- Use `import type` for type-only imports to enable better tree-shaking
- Prefer named imports over default when exporting multiple items
- Avoid circular dependencies; extract shared types to a separate module if needed

## Examples
```typescript
// Good: explicit, narrow types
function parseUserId(input: unknown): string {
  if (typeof input !== 'string') throw new Error('Expected string');
  return input;
}

// Avoid: any bypasses type safety
function parseUserId(input: any): string { ... }
```
