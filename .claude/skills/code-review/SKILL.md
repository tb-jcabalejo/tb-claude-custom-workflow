---
name: code-review
description: Review code for correctness, security, maintainability, and style. Use when reviewing pull requests, examining code changes, or performing code review.
---

# Code Review

## Checklist
- [ ] **Correctness**: Logic correct, edge cases handled
- [ ] **Security**: No obvious vulnerabilities (injection, auth bypass)
- [ ] **Maintainability**: Readable, no unnecessary complexity
- [ ] **Tests**: Adequate coverage for changes
- [ ] **Style**: Matches project conventions

## Severity Levels
- **Critical**: Must fix (bug, security issue)
- **Suggestion**: Should improve (readability, pattern)
- **Nice to have**: Optional enhancement

## Feedback Format
- Be specific: point to the code
- Explain why: "Consider X because Y"
- Suggest fix when possible
- Acknowledge good patterns

## What to Avoid
- Nitpicking style (use linter)
- Vague feedback ("this could be better")
- Blocking on non-blocking issues
