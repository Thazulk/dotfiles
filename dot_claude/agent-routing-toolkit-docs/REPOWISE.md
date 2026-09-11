# Repowise

Use Repowise MCP before generic shell search when it is available and the task is about understanding a codebase.

Global setup rule: do not hardcode one specific repo or workspace into global Codex config.

Project setup rule:
- for a single repo, run `repowise init .` at the repo root
- for a multi-repo workspace, run `repowise init .` at the workspace root
- let Repowise write the project `.mcp.json` so the MCP server follows that project instead of one globally pinned path

If you later want one truly global Repowise endpoint across many projects, prefer a hosted/global Repowise MCP endpoint over a locally hardcoded repo path.

Prefer workspace-level Repowise targets over single-repo targets when a multi-repo workspace is already configured.

Preferred uses:
- repo overview and architecture map
- semantic search for concepts, files, and symbols
- context for files or symbols before editing
- why a design exists before architectural changes
- risk and blast-radius checks before modifying important files

Before relying on Repowise output, check whether the index appears current for the repo in question.

Signals that the index may be stale:
- cited files or symbols do not exist locally
- recent local changes are missing from Repowise answers
- answers conflict with direct file reads
- file paths, module names, or architecture summaries look outdated
- `repowise status` shows new commits, stale repos, or missing docs

Use this maintenance flow:
- `repowise status <path>` to inspect freshness
- `repowise doctor <path>` to validate setup health
- `repowise update <path>` or `repowise update --workspace <path>` to refresh stale indexes
- `repowise reindex <path>` if search/index drift is suspected
- `repowise hook install <path>` or `repowise hook install --workspace <path>` to keep indexes current after commits

If the index appears stale and you cannot refresh it yourself, say so clearly and ask a human to refresh or rebuild the Repowise index before treating it as authoritative. Fall back to direct local inspection in the meantime.

If `repowise status` shows generated docs are missing or skipped, do not treat Repowise wiki summaries as authoritative. Use graph and git signals carefully, prefer direct file reads, and ask a human to run a docs-generating refresh if wiki-level answers are needed.

Repowise is a preference rule, not a hard requirement. Fall back to normal file inspection when Repowise is unavailable or the task is simpler with direct local reads.
