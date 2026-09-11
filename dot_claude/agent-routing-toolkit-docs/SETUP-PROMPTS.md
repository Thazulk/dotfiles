# Setup Prompts

Use these prompts on a new computer after cloning this repository. They are intentionally generic and avoid project-specific paths.

## Codex Prompt

```text
Set up this agent-routing-toolkit repository on this computer for Codex.

Goal:
- Install or wire the helper CLIs from `bin/` onto PATH.
- Configure Codex to use `gpt-5.5` as the everyday model with medium reasoning, workspace-write sandbox, and on-request approvals where supported.
- Verify `gpt-6-astra` is available for premium hard implementation, review, and subagent orchestration; keep it out of cheap/bulk default routes because it is expensive.
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
- Use the Codex CLI route as the baseline. Configure a Codex MCP bridge only if this host already supports one.
- Configure Claude hooks from `hooks/` only where appropriate: routing gate/enforcement and codebase-memory reminders.
- Configure Claude to use the routing rules in `docs/AGENT-ROUTES.md` and `docs/WHOLE-SETUP.md`.
- Keep the setup portable: use `$HOME`, PATH, and environment variables rather than machine-specific absolute paths.
- Keep secrets out of files. Use environment variables or OS keychain storage for API keys.
- Do not copy chat logs, cache folders, route logs, auth files, SQLite state, or project-specific paths.

Steps:
1. Inspect `README.md`, `docs/WHOLE-SETUP.md`, `docs/MODEL-MATRIX.md`, and `docs/AGENT-ROUTES.md`.
2. Add `bin/` to PATH or symlink the scripts into an existing user bin directory.
3. Confirm `codex exec -m gpt-5.5 --sandbox read-only --skip-git-repo-check ok` works.
4. Confirm `codex exec -m gpt-6-astra --sandbox read-only --skip-git-repo-check ok` works if the plan/account should use Astra.
5. Use `agent-ask-codex <prompt-or-file>` for Claude-to-Codex delegation. Keep the default read-only sandbox for advice; use `CODEX_SANDBOX=workspace-write` only when edits are intended. Set `CODEX_MODEL=gpt-6-astra` only for premium hard implementation/review/orchestration.
6. Install Claude hook scripts from `hooks/` into the local Claude Code hook configuration if hooks are supported.
7. Configure Gemini with `GEMINI_API_KEY` or `GEMINI_KEYCHAIN_SERVICE`; do not store the key in this repo.
8. Configure CodeRabbit CLI auth with `coderabbit auth login --agent` if CodeRabbit reviews are needed.
9. Run `agent-quota`, `agent-route code`, `agent-route orchestrate`, `matrix-evidence`, and `agent-health`.
10. Report what works, what is skipped, and what still needs manual login/authorization.
```
