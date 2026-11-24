#!/bin/bash
# SessionStart: short reminder. Full policy is in .claude/rules and CLAUDE.md.
CONTEXT='Ticketboat (Claude Code): refine then hand off (token-policy); Plan → Code → Review → Manual QA (compounding); graphify phase budget; /feature-plan or /apply-ticket writes the plan (and a mockup when the UI has no design), then /clear and /project-manager runs Code, Review, and browser QA. Modes: .claude/rules/claude-code.md.'

python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":sys.argv[1]}}))' "$CONTEXT"
exit 0
