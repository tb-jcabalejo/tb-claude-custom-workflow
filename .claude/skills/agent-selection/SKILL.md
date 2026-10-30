---
name: agent-selection
description: Select and load relevant agent definitions before a task. Use when a command or workflow needs to apply specialized agent perspectives (backend, frontend, etc.) without duplicating the full agent list in every command.
---

# Agent Selection and Definition Loading (Ticketboat)

Use this skill whenever a command instructs you to "apply the agent-selection skill" or "follow agent-selection": identify which agents are relevant, load their definitions, and apply their perspective to the task.

## 1. Identify Relevant Agents

Discover available agents from **`.claude/agents/`**. For each task, pick the agent(s) whose domain matches. The command may override with a **Relevant agents for this command** list; use that when provided.

| Domain | Agent | When to use |
|--------|--------|-------------|
| Backend / API (Python or C#) | backend-architect | APIs, server-side code, databases; **auto-selects** Python (FastAPI) or C# (ASP.NET Core) from plan or project |
| Backend review | backend-reviewer | Review backend code; **auto-selects** Python or C# from files under review; produce rework lists |
| Frontend / UI (React, Ant Design, Vite) | frontend-architect | UI, components, accessibility, Jotai, React Query |
| Frontend review | frontend-reviewer | Review UI, a11y, performance; produce rework lists |
| Technology choices | tech-stack-researcher | New features, tech comparisons, implementation options (Ticketboat stack) |
| Documentation | technical-writer | APIs, guides, README, docs structure (multi-project) |

Spawn Ticketboat subagents with the Agent tool by `name` from `.claude/agents/` (`backend-architect`, `frontend-architect`, `backend-reviewer`, `frontend-reviewer`, `tech-stack-researcher`, `technical-writer`). Reviewers are read-only. Include the **graphify phase budget** (`graphify.md` / `graphify-navigation`): PLAN required query; Code plan-first; Review diff-first.

## 2. Read Agent Definitions

- Load the relevant agent definition files from `.claude/agents/<agent-name>.md`.
- Read frontmatter (name, description), triggers, behavioral mindset, focus areas, key actions, and boundaries.

## 3. Apply Agent Perspective

- Use each agent's behavioral mindset when analyzing or executing the task.
- Apply the agent's focus areas to the work (e.g. security checks, performance considerations).
- Follow the agent's key actions and respect boundaries (what the agent will/will not do).

## 4. Multi-Agent Tasks

If the task spans multiple domains:

- Identify all relevant agents and read each definition.
- Plan how their perspectives integrate and separate concerns in the output (e.g. Backend Tasks vs Frontend Tasks).

## Single Source of Truth

- **Agent definitions:** `.claude/agents/` — one `.md` file per agent (backend-architect, frontend-architect, backend-reviewer, frontend-reviewer, tech-stack-researcher, technical-writer). Backend-architect and backend-reviewer each auto-select Python or C# when invoked.
- Commands that use this skill may list only the **subset** of agents relevant to that command (e.g. feature-plan, project-manager).
