# Setup Prompts

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

Use these prompts on a new computer after cloning this repository. They are intentionally generic and avoid project-specific paths.

## Codex Prompt

```text
Set up this agent-routing-toolkit repository on this computer for Codex.

Goal:
- Install or wire the helper CLIs from `bin/` onto PATH.
- Configure Codex to use `gpt-6.1-sol` as the everyday model with medium reasoning, workspace-write sandbox, and on-request approvals where supported.
- Use `gpt-6.1-sol` for implementation, review, long-running work, and ordinary Codex fallbacks; review uses read-only mode. Keep `gpt-6-astra` for hard work, review escalation, and orchestration. Do not restore retired GPT-5.5 routes.
- Configure the MCP servers described in `docs/WHOLE-SETUP.md`: codebase-memory-mcp, CodeGraph, Repowise, Playwright, node_repl/browser tooling, Homebrew MCP, Sentry, Logfire, Neon, and Computer Use only when available.
- Enable or connect the plugins/connectors described in `docs/WHOLE-SETUP.md`: GitHub, Atlassian, Slack, Google Calendar, Google Drive, Sentry, Documents, Spreadsheets, Presentations, PDF, LaTeX, Sites, Browser/Chrome/Computer Use, Unified Computer Use, Visualize, Template Creator, Superpowers, Ponytail, CodeRabbit, Gmail, Canva, and Plugin Management when available.
- Keep secrets out of files. Use environment variables or OS keychain storage for API keys.
- Do not copy chat logs, local cache folders, SQLite state, auth files, route logs, or project-specific trusted paths.

Steps:
1. Inspect `README.md`, `docs/WHOLE-SETUP.md`, `docs/MODEL-MATRIX.md`, and `docs/AGENT-ROUTES.md`.
2. Add `bin/` to PATH or symlink the scripts into an existing user bin directory.
3. Ensure executable bits are preserved on scripts in `bin/` and `hooks/`.
4. Confirm `agent-ask-codex 'Reply exactly: ok'` works if Claude or another agent should call Codex from the shell.
5. Configure Gemini with `GEMINI_API_KEY` or `GEMINI_KEYCHAIN_SERVICE`; do not store the key in this repo.
6. Configure CodeRabbit CLI auth with `coderabbit auth login --agent` if CodeRabbit reviews are needed.
7. Run the verification checklist from `docs/WHOLE-SETUP.md`.
8. Report exactly what was installed, what was skipped because unavailable, and any manual authentication still required.
```

## Claude Prompt

```text
Set up this agent-routing-toolkit repository on this computer for Claude Code.

Goal:
- Install or wire the helper CLIs from `bin/` onto PATH.
- Copy or reference `docs/MODEL-MATRIX.md` as the shared model routing matrix.
- Ensure Claude can call Codex with `agent-ask-codex`, which wraps `codex exec`.
- Use the installed official Codex plugin (app-server) or the Codex CLI helper. Do not configure the removed `codex mcp-server` command. Codex asks Claude through `agent-ask-claude`; Claude MCP exposes tools, not a live conversation.
- Configure Claude hooks from `hooks/` only where appropriate: routing gate/enforcement and codebase-memory reminders.
- Configure Claude to use the routing rules in `docs/AGENT-ROUTES.md` and `docs/WHOLE-SETUP.md`.
- Keep the setup portable: use `$HOME`, PATH, and environment variables rather than machine-specific absolute paths.
- Keep secrets out of files. Use environment variables or OS keychain storage for API keys.
- Do not copy chat logs, cache folders, route logs, auth files, SQLite state, or project-specific paths.

Steps:
1. Inspect `README.md`, `docs/WHOLE-SETUP.md`, `docs/MODEL-MATRIX.md`, and `docs/AGENT-ROUTES.md`.
2. Add `bin/` to PATH or symlink the scripts into an existing user bin directory.
3. Confirm `codex exec -m gpt-6.1-sol --sandbox read-only --skip-git-repo-check ok` works.
4. Confirm `codex exec -m gpt-6-astra --sandbox read-only --skip-git-repo-check ok` works if the plan/account should use Astra.
5. Use `agent-ask-codex <prompt-or-file>` for Claude-to-Codex delegation. Keep the default read-only sandbox for advice; use `CODEX_SANDBOX=workspace-write` only when edits are intended. Set `CODEX_MODEL=gpt-6-astra` only for premium hard implementation/review/orchestration.
6. Install Claude hook scripts from `hooks/` into the local Claude Code hook configuration if hooks are supported.
7. Configure Gemini with `GEMINI_API_KEY` or `GEMINI_KEYCHAIN_SERVICE`; do not store the key in this repo.
8. Configure CodeRabbit CLI auth with `coderabbit auth login --agent` if CodeRabbit reviews are needed.
9. Run `agent-quota`, `agent-route code`, `agent-route review`, `agent-route hard`, `agent-route orchestrate`, `matrix-evidence`, and `agent-health`.
10. Report what works, what is skipped, and what still needs manual login/authorization.
```
