# GPT Toolset Reference

## Components

| Area | Suggested options |
|---|---|
| Project policy | `AGENTS.md` / `CLAUDE.md` in the repository root; more specific overrides where needed |
| Reusable guidance | Version-controlled shared skills and a registry/configuration file |
| Skill synchronization | A script that copies shared and repository-specific skills into runtime locations |
| Code intelligence | Codegraph; Codebase-Memory-MCP |
| Search | FFF-MCP; DDGS |
| Library documentation | Context7 |
| Task-output management | RTK or an equivalent wrapper |
| Optional workflow runtime | OpenCode |
| Optional repository/context helpers | Repowise, Headroom, Codeburn |

## Adoption principles

- Use portable paths in committed files.
- Do not commit credentials or `.env` content.
- Check versions, licenses, authentication, and maintenance status from official sources before installing external tools.
- Pin or periodically review external dependency versions.
- Confirm installed commands with `command -v`.
- Refresh indexes after major structural or API-contract changes.
- Keep model selection in runtime configuration, not project policy.
- Document rollback, permissions, and write scope for the project.

## Typical project files

```text
AGENTS.md
.mcp.json
skills.config
scripts/install-skills.sh
scripts/bootstrap-context-stack-unix.sh
.agents/skills/
```

`.mcp.json` is client-specific: use the active client's documented MCP configuration mechanism when it differs. Codex wires servers imperatively via `codex mcp add` (unversioned `~/.codex/config.toml`); Claude Code wires servers declaratively via the `mcpServers` block in this dotfiles repo's `dot_claude/private_settings.json.tmpl`.

## Status in this dotfiles repo (2026-07-20)

- Installed and wired for both Codex and Claude Code: Codegraph, DDGS, Repowise, Context7, Codebase-Memory-MCP.
- CodeBurn is installed through mise as `npm:codeburn`.
- FFF MCP is optional: set `TOOLSTACK_ENABLE_FFF=1`, then run `bootstrap-ai-toolstack`.
- Clockify MCP is optional and credential-gated: set `CLOCKIFY_API_KEY`, then run `bootstrap-ai-toolstack`. The API key is written only to machine-local client config, never to this repo.
- Headroom installs via `uv tool` behind `TOOLSTACK_ENABLE_HEADROOM=1`, but the integration is not confirmed client-specific; verify it actually affects Claude Code before assuming parity with Codex.
