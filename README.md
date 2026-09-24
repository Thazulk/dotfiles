# dotfiles

Personal workstation configuration managed with [chezmoi](https://www.chezmoi.io/) and [mise](https://mise.jdx.dev/): shell, terminal, editor, and a portable AI agent toolstack.

Targets macOS and Linux/WSL. Native Windows is best-effort (PowerShell profiles and Cursor settings only).

## Install on a clean machine

### 1. System prerequisites

| Platform | Install first |
| --- | --- |
| All | `git`, `curl` |
| macOS | Xcode Command Line Tools: `xcode-select --install` |
| Debian/Ubuntu/WSL | `build-essential`, `unzip`, `zsh`, `tmux`, `xclip` |
| Windows | WSL2 recommended; native setup covers PowerShell profiles only |

`tmux` is not managed by mise here — install it from your system package manager (`brew install tmux`, `apt install tmux`).

Optional, only needed by parts of the config: Cursor or VS Code, Docker or Rancher Desktop, `kubectl`, Android SDK.

### 2. Clone and apply

If you have no tooling at all, the chezmoi installer does everything in one step:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/Thazulk/dotfiles.git
```

Use the `git@github.com:Thazulk/dotfiles.git` URL instead if an SSH key is already set up on the machine. The `setup` script in this repo is the same one-liner, for bootstrapping from an existing checkout.

To install mise first and take chezmoi from it:

```bash
curl https://mise.jdx.dev/install.sh | sh
exec $SHELL -l
mise install chezmoi
chezmoi init --apply https://github.com/Thazulk/dotfiles.git
```

### 3. Install runtimes and CLIs

Neovim needs an external mise plugin once per machine:

```bash
mise plugin install neovim https://github.com/richin13/asdf-neovim.git
mise install
```

`mise install` reads `~/.config/mise/config.toml` and installs every pinned runtime and CLI listed under [Tools](#tools). Open a new shell afterwards so `.zshrc` and mise activation pick up the new binaries.

### 4. Bootstrap the AI toolstack

Not run by `chezmoi apply`; it downloads packages and edits assistant configuration:

```bash
bootstrap-ai-toolstack
check-ai-toolstack
```

It installs mise tools, registers MCP servers with Codex and Claude, installs agent plugins, and merges shared defaults and routing hooks into `~/.codex/`. In Codex, trust the hooks once via `/hooks`.

Claude Desktop starts its shared MCP pool without a project directory, so project-scoped servers (`codegraph`, `fff`, `nx-mcp`, `repowise`) are registered for Claude Code and Codex only, and stale Desktop entries are removed.

Sign in to the assistants separately:

```bash
codex login
claude auth login
```

Verify the result:

```bash
python3 ~/.local/share/chezmoi/tests/check_agent_setup.py
agent-health
agent-route code
```

Optional integrations are off by default and enabled through environment variables:

| Variable | Effect |
| --- | --- |
| `TOOLSTACK_SKIP_MISE=1` | Refresh client config without reinstalling mise tools |
| `TOOLSTACK_ENABLE_FFF=1` | Install and register the `fff` file-finder MCP |
| `TOOLSTACK_ENABLE_RTK=1` | Run `rtk init --global --codex` |
| `TOOLSTACK_ENABLE_HEADROOM=1` | Run `headroom install apply` |
| `TOOLSTACK_NX_WORKSPACE=<path>` | Pin the `nx-mcp` server to a workspace |
| `CLOCKIFY_API_KEY=<key>` | Register the Clockify MCP server |
| `GEMINI_API_KEY=<key>` | Enable `agent-ask-gemini` (also read from the keychain) |

On macOS, `~/Library/LaunchAgents/com.thazulk.ai-toolstack-update.plist` runs the refresh every morning at 08:30.

### 5. First launches

```bash
nvim   # LazyVim installs editor plugins on first start
tmux
```

## Daily use

```bash
chezmoi update          # pull the repo and apply
chezmoi diff            # preview what apply would change
chezmoi edit ~/.zshrc   # edit through the source state
chezmoi re-add ~/.foo   # pull a locally changed file back into the repo
```

After changing tracked agent defaults:

```bash
chezmoi apply
TOOLSTACK_SKIP_MISE=1 bootstrap-ai-toolstack
```

## Tools

### Dotfile management

| Tool | Why it is here |
| --- | --- |
| `chezmoi` | Applies and templates the dotfiles; handles per-OS differences |
| `mise` | Single source of pinned runtimes and CLIs, so machines match |
| `setup` | Fallback bootstrap when chezmoi is not installed yet |

### Shell and navigation

| Tool | Why it is here |
| --- | --- |
| `zsh` + Pure prompt | Main shell: aliases, vi mode, completion, autosuggestions |
| `tmux` | Terminal workspace, TokyoNight theme, project sessions |
| `fzf-dir` | Shared project picker used by all sessionizer scripts |
| `tmux-sessionizer` | `Ctrl-t`: jump to a tmux session for any project |
| `tmux-windowizer` | Create or reuse a tmux window per branch/task |
| `tmux-cd` | Send `cd <picked-dir>` into a pane |
| `herdr-sessionizer` | `Ctrl-h`: open or focus a Herdr workspace |
| `vscode-sessionizer` | `Alt-f`: open a picked project in VS Code/Cursor plus tmux |
| `tmux-cht.sh` | Query `cht.sh` cheatsheets from inside tmux |

### Editor and terminal

| Tool | Why it is here |
| --- | --- |
| `nvim` / LazyVim | Main editor; plugin set pinned by `lazy-lock.json` |
| `lazygit` | Terminal git UI, themed to match |
| `ghostty` | Terminal emulator config |
| `superfile`, `mc` | File managers |
| `hypr`, `waybar`, `mako` | Wayland desktop config on Linux |

### CLI utilities

| Tool | Why it is here |
| --- | --- |
| `ripgrep`, `fd`, `fzf` | Search and fuzzy selection; back the sessionizers |
| `bat`, `lsd`, `delta` | Readable previews, listings, and git diffs |
| `gh` | GitHub workflow from the terminal |
| `ast-grep` | Syntax-aware search and mechanical rewrites |
| `rtk` | Filtered shell output for agent sessions |

### Language and build tooling

| Tool | Why it is here |
| --- | --- |
| `node`, `python`, `go`, `rust`, `java`, `zig` | Pinned language runtimes |
| `npm`, `pnpm`, `corepack`, `uv`, `maven` | Package managers used across projects |
| `nx` | Monorepo task runner |
| `postgres` | Local database runtime |
| `herdr` | Local workspace runtime driven by `herdr-sessionizer` |

### AI agent toolstack

| Tool | Why it is here |
| --- | --- |
| `bootstrap-ai-toolstack` | Installs and refreshes AI CLIs, MCP servers, plugins, defaults, hooks |
| `bootstrap-ai-toolstack.ps1` | Native Windows equivalent |
| `update-ai-toolstack` | Refreshes Codex/Claude plugin marketplaces and client config |
| `check-ai-toolstack` | Read-only check of installed files, commands, and MCP entries |
| `agent-health` | Live smoke test of routing, Codex, Gemini, Claude MCP, and hooks |
| `agent-quota` | Shows Codex/Claude/Gemini quota and token-burn signals before a paid run |
| `agent-route` | Picks the agent/model class: `cheap`, `code`, `hard`, `long`, `orchestrate` |
| `agent-ask-codex` | Scoped headless Codex call for fast, focused implementation |
| `agent-ask-claude` | Scoped Claude call in plan mode for planning and review |
| `agent-ask-gemini` | Scoped Gemini call for large-context reads |
| `matrix-evidence` | Offline freshness check for `~/.claude/MODEL-MATRIX.md` |
| `configure-agent-defaults` | Merges tracked Codex defaults into local config |
| `configure-agent-hooks` | Registers shared hooks in Codex without dropping unrelated ones |
| `route-gate.sh`, `route_enforce.py`, `cbm-*` | Hooks that force a routing decision and code-discovery order |

### MCP servers

| Server | Why it is here |
| --- | --- |
| `context7` | Current library and framework documentation |
| `codebase-memory` | Indexed project graph: symbols, call paths, architecture |
| `codegraph` | AST and code-graph analysis across languages |
| `repowise` | Repo docs, architecture, impact, and health context |
| `playwright` | Browser automation and UI testing |
| `nx-mcp` | Nx workspace graph, tasks, and docs |
| `ddgs` | Web, news, and image search |
| `homebrew` | Homebrew queries and installs on macOS |
| `codeburn` | Codebase analysis helper |
| `headroom-ai` | Context/headroom accounting |
| `fff` | Optional fast, frecency-ranked file finder |
| `clockify` | Optional time tracking; needs `CLOCKIFY_API_KEY` |
