# Agent Routes

Fast helpers:

- Health: `agent-health`
- Ask Codex: `agent-ask-codex <prompt-or-file>`
- Ask Claude: `agent-ask-claude <prompt-or-file>`
- Ask Gemini: `agent-ask-gemini <prompt-or-file>` (direct Gemini API, default model: `gemini-3.8-flash`; reads the key from env or macOS Keychain when configured)

Routing defaults:

- Cheap sanity: Claude Haiku first; Ollama/opencode only as a manual low-trust local fallback.
- Code implementation: Codex first.
- Claude-to-Codex: use `agent-ask-codex` for fast Codex CLI advice/execution from Claude. Default sandbox is read-only; set `CODEX_SANDBOX=workspace-write` only when edits are intended.
- Independent planning/review: Claude via `agent-ask-claude`.
- Long/context-heavy work: Claude Sonnet first; Gemini Flash via `agent-ask-gemini` only as fallback/third opinion.

Shared memory:

- Store: `$HOME/.agent-memory/memory.json`
- Guarded server: `$HOME/.agent-memory/.server/bin/memory-server.js`
- Status/doctor: `NPM_CONFIG_CACHE=/private/tmp/codex-npm-cache npx -y github:dan-calin/shared-agent-memory status`
- Never call `read_graph` during normal work. Search 1-3 keywords, save one terse observation at task end.

Gemini notes:

- Direct API helper works with `GEMINI_API_KEY` or macOS Keychain via `GEMINI_KEYCHAIN_SERVICE`.
- Use `agent-ask-gemini` for reliable headless Gemini advice from Codex or Claude.
- Repair interactive Gemini CLI separately only if interactive Gemini is needed.
