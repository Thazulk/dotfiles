# Whole Agent Setup

## Local policy: equal Codex and Claude entry points

Codex and Claude are equal primary agents. Continue implementation in the current
session with its selected model. Use the other agent for independent advice; never
self-delegate. The upstream routing tables below describe model choices and peer
fallbacks, not a requirement to switch from Claude to Codex.
Use `agent-route <class> --agent codex|claude` (or `AGENT_ROUTING_AGENT`);
session environment is detected when available. Claude helper calls use plan mode;
Codex helper calls default to read-only. Keep local Bash/Linux portability.
Upstream verification dates describe source evidence, not tests on this machine.



> Windows: follow [WINDOWS.md](WINDOWS.md) before using the Mac commands below.

This document describes a global Codex / Claude / Gemini setup. It is intended as a practical map: what each layer is for, which connectors and MCP servers are required, which skills matter, and how routing should work.

## Setup Shape

| Layer | Purpose | Main pieces |
|---|---|---|
| Codex | Default local implementer and premium orchestrator | Codex app/CLI, `gpt-6.1-sol`, `gpt-6-astra`, workspace-write sandbox, MCP servers, plugins |
| Claude | Planning/review peer | Claude CLI, routing hooks, model matrix, `agent-ask-claude`, `agent-ask-codex` |
| Gemini / Antigravity | Large-context and UI/product peer | Gemini API helper, Antigravity model slugs, `agent-ask-gemini` |
| Shell tools | Fast local evidence | `rg`, `git`, `gh`, `python3`, `node`, `npx`, `docker`, `pnpm`, `go`, `curl` |
| Graph/code tools | Codebase understanding | codebase-memory MCP, CodeGraph, Repowise |

## Core Defaults

- Codex model: `gpt-6.1-sol` for implementation, review, long-running work, and ordinary fallbacks; `gpt-6-astra` for hard work, review escalation, and orchestration
- Reasoning: `medium`
- Service tier: `default`
- Sandbox: `workspace-write`
- Approval policy: `on-request`
- Personality/work style: pragmatic, efficiency-first, small diffs, verify with one runnable check for non-trivial logic
- Multi-agent feature: enabled

## Routing Flow

1. Default to Codex for focused coding work, local edits, verification, and commit/push tasks.
2. Before expensive or broad delegation, run `agent-quota`.
3. Pick a class with `agent-route <cheap|code|review|hard|long|orchestrate>`.
4. Delegate only when another agent is likely to reduce total time, context, or risk.
5. Send a scoped brief: goal, repo/path, relevant files, known failure/output, exact question, and expected answer format.
6. Treat peer-agent output as advice. Verify locally before editing, committing, or reporting.

## Routing Classes

| Class | Use for | Typical first pick |
|---|---|---|
| `cheap` | renames, formatting, boilerplate, log triage, simple doc drafts | Claude Haiku or Gemini Flash depending on quota |
| `code` | normal features, bugfixes, refactors | Codex `gpt-6.1-sol`, with Astra escalation for high-value implementation/review |
| `review` | code/PR review, final review, regression checks | Codex `gpt-6.1-sol`, read-only; Astra escalation |
| `hard` | architecture, complex security analysis, tricky debugging | Codex `gpt-6-astra`, then Claude Opus |
| `long` | long-running implementation, whole-repo sweeps, long-context reads | Codex `gpt-6.1-sol`, then Claude Sonnet |
| `orchestrate` | subagent coordination, multi-agent implementation/review loops | Codex `gpt-6-astra` |

See `docs/MODEL-MATRIX.md` for the current exact chain, cost notes, pinned models, and banned models.

## Claude-to-Codex Path

Claude calls Codex through its installed official Codex plugin (app-server) or the CLI helper below. The old `codex mcp-server` command was removed and must not be configured. Codex asks Claude with `agent-ask-claude`; Claude MCP exposes tools rather than a live Claude conversation. The portable helper is:

```bash
agent-ask-codex "<prompt>"
agent-ask-codex prompt-file.md
```

Defaults:

- `CODEX_MODEL=gpt-6.1-sol`
- `CODEX_SANDBOX=read-only`

Use the default read-only sandbox for advice, second opinions, quick local checks, or review of a proposed patch. Use write access only when implementation by Codex is intended:

```bash
CODEX_SANDBOX=workspace-write agent-ask-codex prompt-file.md
```

Use `CODEX_MODEL=gpt-6-astra` only for the premium path: hard implementation, high-stakes review, or orchestration where better agent control is worth the higher allowance burn/top-up cost.

The prompt should be self-contained: goal, repo/path, relevant files, known failure/output, exact question, and expected answer format. Claude should treat Codex output as advice or delegated work that still needs local verification.

## Required Helper CLIs

| CLI | Required for | Notes |
|---|---|---|
| `agent-route` | Choosing the agent/model chain | Reads `~/.claude/MODEL-MATRIX.md` |
| `agent-quota` | Checking current Codex/Claude/Gemini usage evidence | Uses local session/transcript records |
| `matrix-evidence` | Offline freshness check for model matrix | Run before spending tokens on model-matrix research |
| `agent-ask-codex` | Asking Codex from Claude or another shell agent | Wraps `codex exec`; defaults to read-only |
| `agent-ask-claude` | Asking Claude for scoped advice | Uses plan mode; set `CLAUDE_MAX_BUDGET_USD` only when an explicit API-equivalent budget is intended |
| `agent-ask-gemini` | Asking Gemini for scoped advice | Uses Gemini API key from Keychain or env |
| `agent-health` | Quick system health check | Runs quota/router/shared-memory/Gemini/Claude checks |

## Required MCP Servers

| MCP server | Use it for | Required when |
|---|---|---|
| `codebase-memory-mcp` | Indexed code search, snippets, architecture lookup | Code discovery in repos with an index |
| `codegraph` | Code structure exploration | Repos with `.codegraph/` or CodeGraph support |
| `repowise` | Architecture docs, semantic search, blast radius, code-health context | Broad repo exploration and risk assessment |
| `playwright` | Browser automation and UI verification | Frontend/browser testing |
| `node_repl` | JavaScript runtime for browser/computer-use workflows | Browser, app, document, or UI automation paths |
| `homebrew-mcp` | macOS package/tool inspection | Homebrew/package manager tasks |
| `sentry` | Production issue inspection | Sentry debugging or error review |
| `logfire` | Observability SQL, traces, dashboards, alerts | Logfire telemetry work |
| `Neon` | Postgres/cloud backend tooling | Neon database/backend work |
| `computer-use` | Desktop UI control MCP | Only when enabled and native desktop interaction is needed |

## Required Connectors / Plugins

These are the active or locally installed connector/plugin surfaces relevant to this setup. `config.toml` is the source of truth for enabled Codex plugins; the plugin cache can also contain installed/on-demand skill plugins such as CodeRabbit.

| Connector/plugin | Use it for |
|---|---|
| GitHub | PRs, issues, checks, reviews, repo operations |
| Atlassian Rovo | Jira and Confluence work |
| Slack | Workspace messages and context |
| Google Calendar | Calendar, availability, workday evidence |
| Google Drive | Drive files, Google Docs, Sheets, Slides |
| Sentry | Production issue/event context |
| Documents | DOCX/Word-style document creation and editing |
| Spreadsheets | XLSX/CSV/Sheets-ready workbook creation and analysis |
| Presentations | PPTX and slide deck creation/editing |
| PDF | PDF creation, reading, rendering, and verification |
| LaTeX | TeX compile/check workflows |
| Sites | Website building, saving, hosting, deployment |
| Browser | In-app browser workflows |
| Chrome | Existing Chrome/browser-session workflows |
| Computer Use | Native app/desktop UI workflows |
| Unified Computer Use | Unified browser/native UI control |
| Visualize | In-conversation visualizations and interactive explanations |
| Template Creator | Reusable artifact-template creation |
| Superpowers | Process skills for brainstorming, TDD, debugging, planning, review, verification |
| CodeRabbit | AI-powered code review through the `coderabbit` CLI and `coderabbit-review` skill |
| Ponytail | Simplification lens and over-engineering review |
| Gmail | Email search/read/draft/send workflows when the connector is authorized |
| Canva | Design review/editing/presentation workflows when the connector is authorized |
| Plugin Management | Discover, inspect, install, connect, or remove plugins |

## Global Skills

These are the main skill surfaces used by the setup. Personal skills live under the local skills folders; plugin/bundled skills come from installed Codex plugins.

| Skill group | Skills | Use when |
|---|---|---|
| Review / quality | `code-review`, `coderabbit-review`, `autofix`, `review-animations`, `fixing-motion-performance` | Reviews, PR feedback, CodeRabbit review runs, animation performance |
| Simplicity / brevity | `ponytail`, `caveman`, `caveman-review`, `caveman-commit`, `caveman-compress`, `caveman-stats` | Keep output or designs smaller, remove over-engineering |
| Planning / exploration | `adhd`, `cavecrew`, `visual-plan`, `find-skills` | Divergent ideation, subagent routing, visual plans, skill discovery |
| Frontend / motion | `animate`, `improve-animations`, `threejs-fundamentals`, `threejs-animation`, `threejs-shaders` | Motion, Three.js, frontend animation work |
| Ops / platforms | `doppler-cli`, `macos-cleaner`, `microsoft-foundry`, `neon`, `neon-postgres` | Secrets/config workflows, macOS cleanup, Azure/OpenAI/Neon work |
| Media / docs | `image-generation`, `pdf`, `codex-ppt` | Images, PDFs, generated slide decks |
| Workflows | `fill-weekly-clockify` | Clockify planning/filling workflows |

## Plugin and Bundled Skill Families

| Skill family | Skills / examples | Use when |
|---|---|---|
| OpenAI/Codex docs | `openai-docs` | Codex setup, automations, skills, OpenAI API/product questions |
| Superpowers | `using-superpowers`, `brainstorming`, `systematic-debugging`, `test-driven-development`, `writing-plans`, `executing-plans`, `verification-before-completion`, `requesting-code-review`, `receiving-code-review`, `subagent-driven-development`, `dispatching-parallel-agents`, `using-git-worktrees`, `finishing-a-development-branch`, `writing-skills` | Process discipline for skill selection, planning, debugging, TDD, review, worktrees, subagents, and finishing work |
| CodeRabbit | `coderabbit-review` / `code-review` | Run CodeRabbit AI review on committed/uncommitted diffs, PR feedback, code quality, security issues, and fix-review cycles |
| Google Drive | `google-drive`, `google-docs`, `google-sheets`, `google-slides`, `google-drive-comments` | Connected Drive, Docs, Sheets, Slides, and comments |
| Canva | `canva-design-feedback`, `canva-edit-design`, `canva-branded-presentation`, `canva-translate-design`, `canva-resize-for-social-media`, `canva-bulk-create`, `canva-brand-check` | Canva design review/editing/presentation workflows when the connector is enabled |
| Documents/spreadsheets/presentations | `documents`, `spreadsheets`, `excel-live-control`, `presentations` | Local DOCX/XLSX/PPTX artifacts and live Excel control |
| PDF/LaTeX | `pdf`, `latex-compile`, `latex-doctor`, `texlive-runtime-installer` | PDF and TeX creation, inspection, rendering, and compile workflows |
| Sites/visualization | `sites-building`, `sites-hosting`, `visualize` | Website/app building, hosting, and interactive visual explanations |
| Template creation | `template-creator` | Reusable personal artifact templates |
| Observability/backend | `sentry`, `neon`, `neon-postgres`, Logfire MCP tools | Error triage, database/backend work, telemetry querying |

## CodeRabbit Setup

CodeRabbit is installed as a Codex plugin in the local plugin cache and provides the `coderabbit-review` skill. Use it when the user asks for code review, PR feedback, code quality checks, security issues, or a review/fix cycle.

Expected command flow:

```bash
coderabbit --version
coderabbit auth status --agent
coderabbit review --agent
```

Common scoped reviews:

```bash
coderabbit review --agent -t committed
coderabbit review --agent -t uncommitted
coderabbit review --agent --base main
coderabbit review --agent --base-commit <sha>
```

Do not present a manual review as CodeRabbit output. If CodeRabbit is missing, unauthenticated, unavailable, or times out, report that exact blocker.

## Superpowers Setup

Superpowers is installed as a Codex plugin and provides process skills. It is a workflow layer, not a model. It tells the agent how to approach common development situations before editing.

Installed Superpowers skills:

| Skill | Use when |
|---|---|
| `using-superpowers` | Start-of-task skill selection and skill invocation discipline |
| `brainstorming` | Creative/product/feature work before implementation |
| `systematic-debugging` | Bugs, failing tests, unexpected behavior, root-cause work |
| `test-driven-development` | Feature or bugfix implementation where tests can drive behavior |
| `writing-plans` | Multi-step implementation plans |
| `executing-plans` | Execute an already-written plan with checkpoints |
| `verification-before-completion` | Before claiming work is complete or passing |
| `requesting-code-review` | Request review after meaningful implementation |
| `receiving-code-review` | Triage review feedback rigorously before applying it |
| `subagent-driven-development` | Execute independent implementation tasks with subagents |
| `dispatching-parallel-agents` | Split independent work across agents |
| `using-git-worktrees` | Isolate feature work in git worktrees |
| `finishing-a-development-branch` | Finish, verify, and prepare integration of a branch |
| `writing-skills` | Create or modify Codex skills |

## Local Tools

Prefer installed, authenticated CLIs when they support the task efficiently, then existing API/MCP connectors. Use browser automation when these cannot complete the task, login or visual verification needs it, or the user requests it. Check unknown CLI availability/auth once and avoid repeated failed attempts.

On Apple Silicon, verify RTK and Git resolve to runnable binaries. An old Intel Git can cause `rtk git` to fail with "Bad CPU type"; point the stale Git link to a working native/system Git after preserving it as a backup. A shell alias alone does not repair RTK's subprocess resolution.

| Tool | Use it for |
|---|---|
| `rg` | Fast text/file search; first choice for literals and configs |
| `ast-grep` | Structural code search and safe mechanical rewrites |
| `git` | Diffs, branches, commits, worktrees, rebases, pushes |
| `gh` | GitHub API, PR checks, PR diffs/views, comments |
| `docker` / `docker compose` | Local service stacks, images, containers, DB inspection |
| `pnpm`, `npm`, `node`, `npx` | JS/TS installs, scripts, typechecks, browser tooling |
| `go test` | Go verification |
| `curl` | HTTP/API smoke checks |
| `rtk` | Compact shell output when context is expensive |
| `headroom` / `distill` | Summarizing noisy command output when available |
| `codeburn` | Token/waste measurement for long or looping sessions |
| `repowise` | Repo docs, architecture, blast-radius, semantic search |

## Hooks

| Hook | Purpose |
|---|---|
| `hooks/route-gate.sh` | Detects prompts that look delegatable and asks for an explicit route decision |
| `hooks/route_enforce.py` | Stop-hook verifier for the `route:` decision line |
| `hooks/route-enforce.sh` | Shell wrapper for route enforcement |
| `hooks/cbm-code-discovery-gate` | Nudges code discovery toward codebase-memory/graph tools first |
| `hooks/cbm-session-reminder` | Reminds sessions about codebase-memory usage |

## Verification Checklist

Run these after changing the setup:

```bash
agent-quota
agent-route code
agent-route review
agent-route hard
agent-route orchestrate
matrix-evidence
agent-health
```

For this repository specifically:

```bash
python3 -m py_compile bin/agent-route bin/agent-quota bin/matrix-evidence hooks/route_enforce.py
zsh -n bin/agent-ask-codex
zsh -n bin/agent-ask-claude
zsh -n bin/agent-ask-gemini
zsh -n bin/agent-health
bash -n hooks/route-gate.sh
bash -n hooks/route-enforce.sh
```

## What Not To Commit

- `.env` files
- auth files
- token-bearing logs
- Codex/Claude/Gemini full histories
- route logs
- cache folders
- local SQLite state databases
- API keys, OAuth tokens, cookies, private keys, or credential-bearing URLs
