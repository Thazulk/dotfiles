# Windows setup

Native Windows ports of the installed routing helpers live in `windows/bin/`;
the original `bin/` and `hooks/` remain the macOS implementations.
Python 3.11+ is required (`tomllib`); this host was checked with Python 3.12.

## Shells and installation

Use PowerShell for Windows configuration and Git Bash for POSIX project scripts.
Do not run the zsh helpers on Windows or apply Homebrew, Keychain, launchctl,
`/private/tmp`, or macOS-only hooks. Repositories on this host live under
`C:/Users/adami/Projects` on NTFS. Never infer the operating system from copied Mac instructions.

From this repo in PowerShell, first test without installing:

```powershell
py -3 --version
.\windows\bin\agent-health.cmd
.\windows\bin\agent-route.cmd review
```

`agent-health` validates this personal installation, not a fresh machine. It expects
existing Codex config, Claude plugin settings, and hooks under the current user profile.
It checks routes, safe prompt transport, hook fixtures/privacy, executable discovery,
and cross-process locks without inference, downloads, or indexing.

To update an existing installation, back up only the affected helper files, then copy:

```powershell
$bin = Join-Path $env:USERPROFILE '.codex/bin'
$hooks = Join-Path $env:USERPROFILE '.claude/hooks'
New-Item -ItemType Directory -Force $bin, $hooks | Out-Null
Copy-Item ./windows/bin/* $bin -Force
Copy-Item ./windows/hooks/*.py $hooks -Force
```

Add `$bin` to the user PATH if absent; reopen terminals afterward. The `.cmd` files
use the installed Python launcher and sibling Python sources, so no username or
Python-version directory is baked in. Extensionless adapters use `py.exe` from Git Bash.
This copies helpers only: it does not merge config, register MCP servers, enable
plugins, or install Python. Never overwrite a whole working config with a Mac copy.

## Routing and resources

- Keep at most two active agents across apps/chats: one primary and one helper.
- Codex config uses `[agents] max_concurrent_threads_per_session = 1` for one child;
  that is not a machine-wide process limit. Helpers disable nested delegation.
- Run one heavy local job with `agent-run-heavy <program> <args...>`.
  Locks cover cooperating helper launches only; other apps and direct commands bypass them.
- Index only an explicitly requested repository. No startup workspace indexing,
  background Ollama, or concurrent builds on the 8 GB host.
- `agent-ask-codex` sends stdin to a read-only Codex session with multi-agent disabled.
  This Windows port deliberately has no write-mode override.
- `agent-ask-claude` uses plan mode. Prompts go through stdin, never shell evaluation.
- `agent-route` checks existing login plus bounded cached quota. Unknown is not zero.
  `--probe` explicitly makes a model call; it can consume paid allowance.
- `agent-run-heavy` supports native executables and npm/npx directly; for PowerShell
  scripts pass `powershell.exe -File script.ps1`. It rejects arbitrary cmd/bat adapters.

## Authentication

Use existing Windows credential storage and current local login. Never print tokens,
copy source-machine credentials, commit auth files, or place secret values in docs.
Passphrase-protected migrated SSH keys remain protected; use configured HTTPS access
when a key needs unlocking. Do not globally switch GitHub users while another chat runs.
Use process-scoped credentials for the required account (`adamita` for personal work,
`adammatis` for Oktatron); clear the process override afterward.

Claude desktop login and Claude CLI login are separate checks. Use:

```powershell
codex login status
claude auth status
claude plugin list --json
claude mcp list
codex mcp list
```

Claude calls Codex through `codex@openai-codex` (app-server) or `agent-ask-codex`.
Do not re-add the removed `codex mcp-server` connection. The Claude MCP server
provides tools; it is not a live conversation with Claude.

Gemini accepts existing `GEMINI_API_KEY` / `GOOGLE_API_KEY` or the Windows Credential
Manager entry `codex-gemini-api-key`. A key alone does not verify model access.
Leave `GEMINI_MODEL_VERIFIED` unset until a real target-machine access check passes.
Only `gemini-3.8-flash` is routed; no Pro fallback or copied credentials.

## Hooks and MCP

Register the Python hooks through the full installed `python.exe` path and quoted
script paths in Claude settings: `route-gate.py` for UserPromptSubmit,
`route_enforce.py` for Stop, and `codegraph-on-demand.py` for UserPromptSubmit.
Merge entries with existing hooks instead of replacing settings. The CodeGraph hook
runs only when the current repository already contains `.codegraph/`.

For stdio MCP servers prefer full native executable paths. For npm tools use
`node.exe` with the installed JS entry point, not a macOS shim or a PowerShell `.ps1`
passed as an executable. fnm version changes can invalidate stored Node paths;
recheck them after a Node upgrade. Keep project indexing scoped and on demand.

MCP configuration, connection, OAuth login, and a successful tool invocation are
separate evidence. Codex/Claude CLI, desktop, and duplicate cloud connectors may
have separate authorization state. An `unsupported` auth status on stdio is not
proof of failure; `not_logged_in` on remote OAuth needs attention.

## Verified snapshot

See [WINDOWS-AUDIT-2026-10-19.md](WINDOWS-AUDIT-2026-10-19.md) for measured results
and remaining checks. [WHOLE-SETUP.md](WHOLE-SETUP.md) remains the general map;
this file overrides its Mac-specific commands and broad always-enabled assumptions
for Windows. Official reference: [Codex on Windows](https://developers.openai.com/codex/windows).

## Reauthorize existing connections

These commands open the default browser. Complete consent while the Codex login
process is still waiting; if it times out, rerun the command and use the newest
authorization page. Do not save OAuth callback URLs or tokens in repository files.

```powershell
codex mcp login sentry
codex mcp login logfire
codex mcp login Neon
claude mcp login 'claude.ai Sentry'
claude mcp login 'claude.ai Atlassian Rovo'
```

The `claude.ai` connectors have separate authorization from manually configured
MCP endpoints. A successful launch of the Claude browser flow is not proof of a
connection. Verify each with `claude mcp get 'claude.ai Sentry'` and
`claude mcp get 'claude.ai Atlassian Rovo'`; check Codex with `codex mcp list`.
Use a read-only tool request to confirm service access after login.

After a real `gemini-3.8-flash` request returns a visible response using the existing
Windows credential, persist the verification flag (never set it in advance):

```powershell
[Environment]::SetEnvironmentVariable('GEMINI_MODEL_VERIFIED', '1', 'User')
```

Restart existing Codex/Claude apps and terminals to inherit the new user environment.
A shell already running can set `$env:GEMINI_MODEL_VERIFIED='1'` after that same
verified access check. The flag records verification, not an API key or quota promise.
Use enough output allowance for the model's reasoning plus a visible answer; a
32-token probe on this host stopped without text, while 256 tokens completed.

Browser sign-in is only an intermediate step. Claude may first show a
"Finish connecting a connector?" interstitial; verify its destination and continue
only for the connection you initiated. Atlassian then requires site selection
and final consent. Neon requires choosing the intended projects, role, and access
level, then clicking Approve before the CLI callback expires. Leave legally
binding acceptance and materially broader access approval to the user.

If Neon lists multiple organizations instead of projects, pass the exact returned
`org_id` to `list_projects`; this is an account-scope choice, not a failed login.
After a browser `invalid_request` error, check the CLI's saved OAuth status before
starting another flow: an expired or duplicate tab does not prove login failed.

## Supporting tools on Windows

Verified on 2026-10-19: CodeGraph 1.5.0 was already installed and its Claude MCP
connection passed. Its Codex MCP launcher is enabled too. Repowise 0.45.0,
codebase-memory, RTK, Codeburn, CodeRabbit, Git/gh, jq, uv, Node/npm/pnpm,
Go, and Docker CLI were already present; their presence does not imply every
optional background service is running.

The missing Headroom and ast-grep commands were installed together in one isolated
uv tool environment, using the existing Python 3.12. The core install avoids
optional ML/proxy extras and does not redirect agent API traffic or start a daemon:

```powershell
agent-run-heavy uv.exe tool install --python (Get-Command python.exe).Source --with-executables-from ast-grep-cli 'headroom-ai==0.41.0'
ast-grep --version
headroom --version
codegraph --version
```

This exposes native `headroom`, `ast-grep`, and `sg` executables in the existing
user tool bin directory. Headroom 0.41.0 and ast-grep 0.51.0 passed command checks
from PowerShell and Git Bash; native structural search and `headroom sg` were
also exercised on a synthetic Python file. A local SDK compression check reduced
10,558 synthetic tokens to 5,062 while preserving the failure marker; it used
Headroom's default safe pure-Python detector on Windows. `repowise distill <command>` already
provides output distillation; a standalone `distill` executable is not required.
Use Headroom's core SDK for local compression, or opt into a proxy separately
when deliberately required; installing the CLI does not route all agent traffic.

The companion routing toolkit now includes `windows/bin/matrix_evidence.py` and
PowerShell/Git Bash `matrix-evidence` adapters. Copy these into `.codex/bin` with
the other Windows helpers. The checker reads local model-cache and matrix data;
it does not require the source Mac's Antigravity CLI on Windows or spend tokens.
Its two regression tests cover both the Windows skip and preserved Mac inventory:

```powershell
# From agent-routing-toolkit:
python -m unittest discover -s windows/tests -v
matrix-evidence
```

An exit status of 1 means evidence needs review, not a failed installation. On this
host it correctly flags the matrix's full reliability/pricing audit as 38 days old;
no verification date was fabricated or model routing changed to suppress that warning.

No repository was indexed during this setup. CodeGraph indexing remains explicit
and on demand. Repowise, codebase-memory, and Playwright remain installed with their
optional global Codex MCP entries disabled to avoid extra startup work on the
8 GB host; use their CLIs or enable them for the task that needs them.

Install/reference sources: [Headroom core installation](https://headroomlabs-ai.github.io/headroom/quickstart/#installation)
and [ast-grep installation](https://ast-grep.github.io/guide/quick-start.html).
