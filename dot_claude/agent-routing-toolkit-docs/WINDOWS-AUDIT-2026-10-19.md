# Windows audit — 2026-10-19

Local snapshot, Europe/Budapest. About 8 GB RAM. No secrets, auth stores, or raw
transcripts were copied into either repository. This is evidence for the checks
listed, not a guarantee that every plugin action or remote model is operational.

| Area | Result | Evidence / remaining work |
|---|---|---|
| Repositories | Cloned | Both repos under `C:/Users/adami/Projects`; authenticated HTTPS access checked with the existing account |
| Codex CLI | Ready for tested checks | `codex-cli 0.153.4`; `codex login status`: ChatGPT login |
| Claude CLI | Ready for tested checks | Claude Code `2.1.263`; `claude auth status`: logged in |
| Codex defaults | Pass | `gpt-6.1-sol`, medium reasoning; one child per session; no legacy Codex MCP server |
| Deterministic helper health | Pass | Installed and repository Windows `agent-health` pass config/routes, read-only/plan defaults, stdin prompt transport, hook privacy, and peer/heavy locks |
| Review routing | Pass | PowerShell and Git Bash `agent-route review` choose Sol, then Astra, then Claude Opus |
| Claude plugins | Enabled and installed | Caveman, Ponytail, Superpowers, official Codex plugin `1.0.6`, CodeRabbit plugin `1.1.1`; actual review/delegation operations not exercised |
| Claude local MCP | Connected | Playwright, CodeGraph, codebase-memory, Repowise, shared memory |
| Claude configured remote MCP | Connected | Sentry, Logfire, Neon, Atlassian |
| Claude cloud connectors | Mixed | Claude Docs and Slack connect; duplicate cloud Sentry and Atlassian Rovo need authentication |
| Codex MCP | Partial | Sentry, Logfire, Neon enabled but CLI reports `not_logged_in`; stdio `unsupported` auth status alone is not failure |
| Codex optional servers | Disabled in global config | Playwright, Repowise, codebase-memory; do not globally enable/index everything on this host |
| Shared memory | Pass for this session | Scoped `search_nodes` request succeeded |
| Local tools | Present | Git, gh, Python, Node, rtk, Repowise/augment/rewrite, CodeGraph, Codeburn, CodeRabbit executable |
| Gemini | Intentionally gated | Target credential exists; `GEMINI_MODEL_VERIFIED` unset; no inference made |
| Usage reporter | Fixed and checked | Native PATH separator; Claude Windows project-log keys; three regression tests pass |
| Codeburn | Partial | Status reports usage but emits a stale macOS Warp database / Full Disk Access warning; that instruction is inapplicable on Windows |

## Changes captured

- Native Windows Python runtime, `.cmd` and Git Bash adapters under `windows/bin/`.
- Windows routing and on-demand CodeGraph hooks under `windows/hooks/`.
- [Windows operating guide](WINDOWS.md), platform pointers in general setup docs.
- Companion `agent-toolkit-setup`: Windows guide, platform pointers, usage-report
  path fixes and stdlib regression checks. The Mac installer remains Mac-only.

## Follow-up checks

1. If needed, run `codex mcp login sentry`, `codex mcp login logfire`, and
   `codex mcp login Neon`, complete the interactive OAuth flow, then test a read-only
   tool from a fresh Codex session. Claude authorization does not prove Codex authorization.
2. Reconnect the duplicate cloud Sentry/Atlassian connectors only if those surfaces
   are needed; the explicit Claude MCP endpoints already connect.
3. Model inference, CodeRabbit review execution, plugin workflows, browser/desktop
   UI, and every remote tool were not smoke-tested. Do these only when needed.
4. Treat Codeburn's Mac Warp warning as an optional reporting limitation, not an
   instruction to change Windows permissions. No source-machine auth was imported.

Health checks are offline. No paid inference probes, broad repo indexing,
package installation, or authentication changes were performed in this audit.

## Follow-up authentication repair

The initial snapshot above predates these user-requested repairs:

- Codex Sentry and Logfire: OAuth login completed; separate read-only project
  requests succeeded through both live MCP connections.
- Claude cloud Sentry: `claude mcp get 'claude.ai Sentry'` reports Connected.
- Gemini: an actual `gemini-3.8-flash` response completed (98 total tokens).
  `GEMINI_MODEL_VERIFIED=1` was then saved to the Windows user environment;
  routing now includes Gemini. Existing apps/terminals must restart to inherit it.
- Offline `agent-health` passes again. A transient Repowise startup timeout did
  not reproduce in a focused `claude mcp get repowise` recheck, which connected.
- Final verification at 11:22 Europe/Budapest: Codex Neon reports OAuth login,
  and a real read-only project request succeeded after selecting an organization.
  Sentry and Logfire also report OAuth login. Both Claude cloud Sentry and
  Atlassian Rovo report Connected after final browser consent.
- Neon initially returned `invalid_request` for an expired authorization request.
  A fresh request completed. The first project read then requested an explicit
  `org_id` because the account has multiple organizations; the scoped retry passed.
  These errors did not require copying credentials or weakening security.

Neon consent defaults on this host were all projects, Database owner, and
read/write access. The user must choose the intended scope and approve it;
never approve a broad default merely to make a health check green. Atlassian
requires the intended site to be selected before its final Accept step.
The recovery commands are in [WINDOWS.md](WINDOWS.md).
No credentials or OAuth callback URLs are included here.

## Supporting-tool installation follow-up

CodeGraph was already installed (1.5.0): native CLI and Claude MCP connection pass;
its existing Codex MCP launcher remains enabled. Installed missing Headroom 0.41.0
and ast-grep 0.51.0 using a core-only isolated uv tool environment. Verified native
AST matching and `headroom sg`, plus command discovery in PowerShell and Git Bash.
Installed a Windows `matrix-evidence` helper and adapters; both platform regression
checks pass. The checker correctly reports an old full matrix audit (38 days),
which remains a data-review item rather than a missing-tool or login issue.
No paid model calls, repo indexing, background proxy, or credential changes were
needed for these supporting-tool installations. See [WINDOWS.md](WINDOWS.md).
