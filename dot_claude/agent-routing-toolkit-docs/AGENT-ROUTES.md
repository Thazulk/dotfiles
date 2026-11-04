# Agent Routes

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

Fast helpers:

- Health: `agent-health`
- Ask Codex: `agent-ask-codex <prompt-or-file>`
- Ask Claude: `agent-ask-claude <prompt-or-file>`
- Ask Gemini: `agent-ask-gemini <prompt-or-file>` (direct Gemini API, default model: `gemini-3.8-flash`; reads the key from env or macOS Keychain when configured)

Routing defaults:

- Cheap sanity: Claude Haiku first; Gemini Flash or Codex as fallbacks.
- Code implementation: Codex first.
- Claude-to-Codex: use `agent-ask-codex` for fast Codex CLI advice/execution from Claude. Default sandbox is read-only; set `CODEX_SANDBOX=workspace-write` only when edits are intended.
- Independent planning/review: Claude via `agent-ask-claude`.
- Implementation, review, long-running work, and ordinary Codex fallbacks: GPT-6.1 Sol; hard/orchestrate: GPT-6 Astra. Reviews use read-only mode; select with `agent-route review`.
- Claude's installed Codex plugin uses app-server; `agent-ask-codex` is the CLI fallback. Do not configure the removed `codex mcp-server` command. Claude MCP exposes tools, not a live model conversation; use `agent-ask-claude` for an opinion.
- Prefer installed/authenticated CLIs, then available API/MCP connectors; use a browser when these cannot complete the task, login or visual verification requires it, or the user requests it.

Shared memory:

- Store: `$HOME/.agent-memory/memory.json`
- Guarded server: `$HOME/.agent-memory/.server/bin/memory-server.js`
- Status/doctor: `NPM_CONFIG_CACHE=/private/tmp/codex-npm-cache npx -y github:dan-calin/shared-agent-memory status`
- Never call `read_graph` during normal work. Search 1-3 keywords, save one terse observation at task end.

Gemini notes:

- Direct API helper works with `GEMINI_API_KEY` or macOS Keychain via `GEMINI_KEYCHAIN_SERVICE`.
- Use `agent-ask-gemini` for reliable headless Gemini advice from Codex or Claude.
- Repair interactive Gemini CLI separately only if interactive Gemini is needed.
