---
description: Manually test a feature in a real browser with Playwright. Opens the exact pages that changed, walks every acceptance criterion, compares with the plan's mockup, and writes docs/qa/<slug>-qa-N.md with screenshots. Runs automatically as Phase D of /project-manager.
argument-hint: [plan-path] [AC-n ...] | --login [role] | --logout
disable-model-invocation: true
---

**Scope of this command:** **AGENT (QA)**. Verify; do not fix. Do not change application code, config, tests, or the plan. The only files you create are `docs/qa/<slug>-qa-N.md` and screenshots under `docs/qa/<slug>/run-N/`. All browser work goes to the `qa-tester` subagent.

## Rules to follow

- **Token policy:** `.claude/rules/token-policy.md`. Refine the plan into a test brief, then hand off.
- **Cycle:** Manual QA phase in `.claude/rules/compounding-dev-cycle.md`; mode map in `.claude/rules/claude-code.md`.
- **Graphify:** Diff-first. The plan's File changes and the diff name the page; query only if the route is still unclear.
- **Skill:** `.claude/skills/manual-qa/SKILL.md` (case rules, verdicts, safety). Report shape: `.claude/skills/manual-qa/report-template.md`.

## Target

$ARGUMENTS

**Interpret the arguments as:** a plan path or slug (`ope-467-show-session-pagination` → `docs/plans/ope-467-show-session-pagination.md`), optionally followed by AC ids to re-run only those (`AC-2 AC-4`). Empty or missing plan → ask for the plan path and stop. `--login [role]` or `--logout` → run **Sign-in modes** and stop.

## Sign-in modes

Rules: **Authentication** in `.claude/skills/manual-qa/SKILL.md`. The user signs in; the tester only reuses the session.

- **`--login [role]`:** run the Node, base URL, dev-server, and production checks from Step 1.5. Tell the user: "Chrome will open on the login page. Complete the Microsoft sign-in in the popup (use the QA account for <role> if you have one). I'll wait up to 5 minutes." Spawn `qa-tester` with mode `login`, auth `attended`, base URL, and role. Reply with the probe result and that later runs reuse this session until the admin API session expires.
- **`--logout`:** spawn `qa-tester` with mode `logout`. To wipe everything, the user deletes this workspace's `mcp-chrome-*` folder under `~/Library/Caches/ms-playwright/`.

## Step 1: Preflight (you, before spawning)

1. **Load the plan:** Acceptance criteria, Frontend tasks, File changes, Design reference, Manual QA. Include AC from `docs/plans/<slug>-rework-*.md`.
2. **Applicability:** no Frontend tasks and no UI-observable AC → reply `Manual QA: N/A — <reason>` and stop. Write nothing.
3. **Cases:** use the plan's Manual QA table. If it is missing, derive at least one case per UI-observable AC from the AC text, File changes, and the router file. Each case cites its AC. No case without an AC.
4. **Changed files:** `git status --short` and `git diff --stat` against the base branch in the product root that holds the frontend File changes. Pass the list to the tester.
5. **Environment:**
   - **Node:** `command -v npx`. Missing → stop: "Install Node.js 18+ (`brew install node`) so qa-tester can start Playwright."
   - **Base URL:** from Manual QA, else the port in the repo's `dev` script (`admin-frontend`: `http://localhost:5173`). Must be `localhost` or `127.0.0.1`.
   - **Dev server:** `curl -s -o /dev/null -w '%{http_code}' <base>`. Down → start it in the background with the repo's package manager (`bun.lock` → `bun run dev`, `pnpm-lock.yaml` → `pnpm dev`, `yarn.lock` → `yarn dev`, else `npm run dev`) and poll up to 60 s. No runtime or still down → stop and ask the user to start it.
   - **Production guard:** compare `VITE_API_URL` in the active env file (`.env.local`, else `.env`) with `.env.prod`. Equal → stop. Never test against production. Print only "local", "staging", or "other", not the URL.
   - **Backend scope:** plan has Backend or C# Backend tasks and the API is not local → backend-dependent cases go in as BLOCKED (env), not FAIL.
6. **Mockup:** if `docs/plans/mockups/<slug>.html` exists, serve it: `python3 -m http.server 8765 --bind 127.0.0.1 --directory <plan dir>/mockups` in the background. Pass `http://127.0.0.1:8765/<slug>.html`. Otherwise pass the design link or "none".
7. **Run number:** next free N for `docs/qa/<slug>-qa-N.md`. Create `docs/qa/<slug>/run-N/`.
8. **Auth mode:** standalone runs are `attended`; tell the user (one line): "Chrome will open. If it asks you to sign in, complete the Microsoft popup; the tester waits up to 3 minutes." Runs from `/project-manager` are `unattended`: no wait.

## Step 2: Spawn `qa-tester` — AGENT (QA)

One tester at a time; the Playwright profile is shared.

- **Pass:** plan path; AC verbatim; cases (AC, route, steps, expected, mockup state); base URL; mockup URL or design link; changed files; absolute screenshot directory; mutation policy (from Manual QA, default "none"); backend availability; mode `test`; auth mode; required role and its role check (from Manual QA).
- **Instruct:** "Mode: AGENT (QA). Follow `.claude/skills/manual-qa/SKILL.md`. Run only these cases, in AC order, on the exact routes. Graphify diff-first. Do not edit code. Return the report body in `.claude/skills/manual-qa/report-template.md` structure and the list of screenshot paths."

## Step 3: Write the report

- Write `docs/qa/<slug>-qa-N.md` from the tester's return and the template header (commit `git rev-parse --short HEAD`, dirty flag, date UTC, API env label).
- Check every evidence path exists (`ls`). A PASS without its screenshot becomes BLOCKED (no evidence).
- Stop the mockup server if you started it. Leave the dev server running and say so.

## Step 4: Verdict and handoff

- **PASS:** every UI-observable case PASS, the rest N/A.
- **FAIL:** any FAIL or Critical item. From `/project-manager`: return to its rework loop. Standalone: tell the user to run `/project-manager docs/plans/<slug>.md`; it resumes from this report.
- **BLOCKED:** list each blocker with the exact user action. No rework plan; blocked cases are not code failures. `AUTH_REQUIRED` or auth-expired → "run `/manual-test --login`, then re-run". auth-role → "sign in as <role> with `/manual-test --login <role>`, then re-run those AC".

**Reply (≤15 lines):** verdict, the Results table (AC | verdict | screenshot), Critical items, blockers, report path.
