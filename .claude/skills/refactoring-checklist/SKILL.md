---
name: refactoring-checklist
description: Apply safe refactoring steps with behavior preservation. Use when refactoring code, reducing technical debt, or working with refactoring-expert.
---

# Refactoring Checklist

## Before Refactoring
- [ ] Tests exist and pass
- [ ] Scope is clear (one concern at a time)
- [ ] No behavior change intended

## Safe Refactoring Steps

### 1. Extract
- Extract method/function: small, focused changes
- Extract variable: improve readability
- Extract constant: magic numbers/strings

### 2. Rename
- Rename for clarity (IDE rename refactor)
- Update all references in one pass

### 3. Move
- Move function to appropriate module
- Move code closer to where it's used

### 4. Simplify
- Replace conditional with guard clauses
- Replace nested conditionals with early returns
- Remove dead code

### 5. Decompose
- Split large function into smaller ones
- Break up large classes

## Rules
- **One change per commit** when possible
- **Run tests after each step**
- **No new features** during refactor
- **Preserve behavior** — refactor is structural only

## Red Flags
- Changing behavior while refactoring
- Refactoring without tests
- Large, multi-file changes without incremental validation
- Mixing refactor with feature work

## Output
- Before/after complexity (if measurable)
- List of changes
- Confirmation that tests still pass
