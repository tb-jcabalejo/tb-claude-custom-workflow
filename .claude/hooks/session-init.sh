#!/bin/bash
# SessionStart: short reminder. Full policy is in .claude/rules and CLAUDE.md.
CONTEXT='Ticketboat (Claude Code): refine then hand off (token-policy); Plan → Code → Review (compounding); graphify phase budget; /feature-plan or /apply-ticket writes the plan, then /clear and /project-manager runs Code. Modes: .claude/rules/claude-code.md.'

python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":sys.argv[1]}}))' "$CONTEXT"
exit 0
