---
description: Scan a repo (or paths in it) for exploitable security and business-logic issues the way NRD Sight's codebase scan does. Writes docs/scans/<repo>-<date>.md with rule ids, exploitability, blast radius and a paste-ready fix brief. Read-only. Creates Linear tickets only when you confirm.
argument-hint: <repo folder | owner/repo> [paths ...] [--tickets]
disable-model-invocation: true
---

**Scope of this command:** Read-only security scan. Do not change code, config or tests.
- **File you may create:** `docs/scans/<repo>-<YYYY-MM-DD>.md` in the folder you were started from.
- **Linear:** create issues only after the user confirms the finding list in chat, and only when `--tickets` was passed.

## Rules to follow

- **Token policy:** `.claude/rules/token-policy.md`.
- **Graphify:** this is orientation, so the graph gate applies (`.claude/rules/graphify.md`). Query entry points before reading.
- **Skill:** `nrd-review`, the **Scan mode** section (`skills/nrd-review/SKILL.md` in the `.claude/` folder this command was loaded from). Report shape and evidence bar: `scan-template.md` in the same folder.

## Target

$ARGUMENTS

**Interpret the arguments as:**
- A local repo folder, or `owner/repo`.
  - For `owner/repo`, use a sibling folder with that name if one exists.
  - Otherwise run `gh repo clone <owner/repo> "$(mktemp -d)/repo" -- --depth 1` and remove the clone afterwards.
- Optional paths limit the scope.
- `--tickets` offers to create Linear issues after the scan.

If the arguments are empty, ask which repo and stop.

## Steps

1. **Resolve the checkout.** Record its HEAD `sha7` and the `owner/repo` (`git remote get-url origin`).
2. **Write `scope.txt`** in a temp bundle folder: the paths given, or the whole repo minus `node_modules`, `dist`, `build`, `.venv` and lockfiles. List the entry points from the graph or a narrow search:
   - HTTP routes and webhooks;
   - Lambda handlers and SQS consumers;
   - `terraform/`, `.github/workflows/`, `.env*`, `deploy*.sh`.
3. **Spawn `nrd-reviewer`** with this brief:

   ```
   mode: scan
   bundle: <folder>
   checkout: <checkout>
   sha7: <sha7>
   Read the skill's Scan mode and scan-template.md first.
   ```

4. **Validate the report:**
   - Every finding has Issue, Location, Rule, Exploitability, Data at risk, Evidence, Recommended fix.
   - Severity is `critical` or `high`.
   - Secret values are redacted.
   - No finding fails the evidence bar.

   Send one follow-up if anything fails.
5. **Save** the report to `docs/scans/<repo>-<YYYY-MM-DD>.md`.
6. **Reply:**
   - The summary table: severity, rule, location, issue.
   - The saved path.
   - With `--tickets`: the proposed issue titles, followed by a request for confirmation.
7. **On confirmation:** create the issues with the Linear MCP as `scan-template.md` → **Creating tickets** describes, then list their ids.
8. **Clean up** any temp clone.
