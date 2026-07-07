# GPT Toolset Reference

## Components

| Area | Suggested options |
|---|---|
| Project policy | `AGENTS.md` in the repository root; more specific overrides where needed |
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

`.mcp.json` is client-specific: use the active client’s documented MCP configuration mechanism when it differs.
