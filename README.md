# dotfiles

Personal environment via [chezmoi](https://www.chezmoi.io/) + [mise](https://mise.jdx.dev/).  
macOS, Linux, WSL, and Windows (Git Bash / WSL).

---

## 1. System dependencies

Install these **before** mise/chezmoi:

| All platforms | Linux / WSL (Debian/Ubuntu)                  | macOS                                               |
| ------------- | -------------------------------------------- | --------------------------------------------------- |
| `git`, `curl` | `build-essential`, `unzip`, `zsh` (optional) | Xcode Command Line Tools (`xcode-select --install`) |
|               | `xclip` (tmux clipboard)                     |                                                     |

**Windows:** use **WSL2** (recommended) or Git Bash. Native Windows is best-effort for shell dotfiles; Cursor settings apply via `AppData/Roaming/Cursor/`.

**Optional (not in mise):** [Cursor](https://cursor.com), Docker / Rancher Desktop, `kubectl`, Android SDK (macOS block in `.zshrc`).

---

## 2. Install mise, then chezmoi

```bash
# mise (official installer — pick one)
curl https://mise.jdx.dev/install.sh | sh
# or: brew install mise

# reload shell, then:
mise install chezmoi
```

Add mise to your shell (if the installer did not): `eval "$(mise activate zsh)"` (or `bash`).

---

## 3. Clone and apply dotfiles

```bash
chezmoi init git@github.com:Thazulk/dotfiles.git
chezmoi apply
```

Or one-liner on a fresh machine:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:Thazulk/dotfiles.git
```

(`./setup` in this repo is the same idea if `chezmoi` is not on PATH yet.)

---

## 4. mise tools

Tool versions live in `~/.config/mise/config.toml` (from chezmoi).

### Required mise plugins (manual once per machine)

`neovim` (nightly) and `tmux` are **not** core mise tools — install plugins **before** `mise install`:

```bash
mise plugin install neovim https://github.com/richin13/asdf-neovim.git
mise plugin install tmux  https://github.com/mise-plugins/mise-tmux.git
mise install
```

Everything else in `config.toml` (go, node, python, rust, java/temurin, fzf, chezmoi, …) uses built-in backends.

Verify: `mise plugins ls` should list `neovim` and `tmux`.

---

## 5. After `chezmoi apply` / `mise install`

### Runs automatically on `chezmoi apply` (when content changes)

| Script                                                  | When               | What                                                                                    |
| ------------------------------------------------------- | ------------------ | --------------------------------------------------------------------------------------- |
| `run_onchange_after_sync-cursor-settings-to-windows.sh` | WSL only           | Copies Cursor `settings.json`, keybindings, snippets → Windows `%APPDATA%\Cursor\User\` |
| `run_onchange_after_install-cursor-extensions.sh`       | Cursor CLI on PATH | Installs extensions from `extensions.txt`; **skips** if Cursor not installed            |

`chezmoi apply --dry-run` does **not** run these.

### Manual once per machine

```bash
# new shell so mise + zshrc load
exec zsh   # or open a new terminal

# Neovim: LazyVim plugins on first launch
nvim

# Cursor: install the app, sign in, open a WSL folder once (WSL CLI on PATH)
# then re-apply if extensions did not install:
chezmoi apply
# or:
install-cursor-extensions
```

### WSL + Windows Cursor (optional `~/.config/chezmoi/chezmoi.toml`)

If auto-detect fails:

```toml
[data]
    windowsAppDataRoaming = "/mnt/c/Users/YOUR_USER/AppData/Roaming"
    windowsCursorCli = "/mnt/c/Users/YOUR_USER/AppData/Local/Programs/cursor/resources/app/bin/cursor.cmd"
```

### AI toolstack (manual once per machine)

Global policy is rendered from `.chezmoitemplates/global-agent-policy.md` into
both `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md`. Both clients load their
user-wide file even without project instructions. Project files add local rules;
Codex loads its global file automatically, while Claude project files can import
other project guidance as needed. No project AGENTS.md changes are required here.

```bash
bootstrap-ai-toolstack
check-ai-toolstack
# Skip reinstalling unrelated mise runtimes on an already provisioned machine:
TOOLSTACK_SKIP_MISE=1 bootstrap-ai-toolstack
# Runtime routing:
agent-quota
agent-route code
agent-route hard
agent-ask-claude /absolute/prompt.md
agent-ask-codex /absolute/prompt.md
agent-ask-gemini /absolute/prompt.md
```

The AI CLI/MCP tools are declared in `~/.config/mise/config.toml` (tracked here
as `dot_config/mise/config.toml`): ast-grep, RTK, Context7, codebase-memory-mcp,
CodeGraph, DDGS, Repowise, Headroom, and pnpm. The npm and pipx backends cover the
packages; the Python tools use Python 3.13, including DDGS MCP and Headroom extras.
DDGS 9.x pins MCP below 2 because it imports the SDK 1.x FastMCP API.
No Brewfile is needed for this set. Homebrew Bundle supports a Brewfile if future
system dependencies need it: https://docs.brew.sh/Brew-Bundle-and-Brewfile.

`mise install` installs the declared tools. `bootstrap-ai-toolstack` runs that
installation and registers local MCP servers globally for Codex and Claude
(`claude mcp add --scope user`). `TOOLSTACK_SKIP_MISE=1` only refreshes the client
configuration. Executable paths are resolved from mise on each machine; restart
clients after setup. The CodeGraph launcher calls its mise-installed native binary
directly because the npm 0.2.1 launcher recurses through its global symlink. Its
npm installer downloads the current native release, so only the wrapper is pinned.
Old npm/uv/Homebrew copies are not uninstalled automatically.

Native Windows uses `~/.local/scripts/bootstrap-ai-toolstack.ps1`; the Bash
health/review helpers require Git Bash or WSL. PowerShell path mismatches are
reported for explicit removal and re-registration.

`~/.config/agents/codex-defaults.json` persists the PDF's `gpt-5.5`, `medium`,
`workspace-write`, and `on-request` defaults. `~/.claude/MODEL-MATRIX.md`
persists the colleague toolkit's routing matrix. `configure-agent-defaults`
merges the Codex defaults into the local Codex configuration, preserving other
settings and saving the first previous version as `config.toml.before-global-setup`
with mode 0600. The bootstrap applies it; run it again after changing tracked
defaults. App/task-specific overrides and organization policies can take precedence.
Neither the auth-bearing `~/.claude.json` nor the machine-local Codex config is
committed.

Sign in separately with `codex login`, `claude auth login`, and any Gemini/Ollama
setup you actually use. The routing flow is the colleague toolkit model:
`agent-quota`, then `agent-route cheap|code|hard|long|orchestrate`, then a scoped
helper call only when delegation is useful. `agent-health` is a live smoke test
and can call Codex/Gemini/shared-memory; use `check-ai-toolstack` for a cheaper
installed-file/command check. Peer output is advice and still needs local
verification.

The PDF's SaaS connectors, Clockify helper, and extra skills are optional
role-specific integrations, not prerequisites for the portable Codex/Claude/Gemini
tooling. No unverified skill names, private Clockify implementation, OAuth
credentials, Docker daemon, or local model downloads are fabricated by the bootstrap.
Existing artifact/browser plugins and bundled runtimes remain client-managed.
Connect service accounts through their clients when needed; never commit tokens.

`repowise init` and indexing remain project-level decisions. The global policy
falls back to normal tools if an index is missing. RTK and Headroom integration
are opt-in with `TOOLSTACK_ENABLE_RTK=1` / `TOOLSTACK_ENABLE_HEADROOM=1`.

Verification: `python3 tests/check_agent_setup.py`, `agent-route code`, and
`matrix-evidence` when the local model caches are available. Rollback: revert
these source changes and apply the affected files;
restore the local Codex backup if needed, and remove only the added MCP entries
with `codex mcp remove NAME` / `claude mcp remove --scope user NAME`.

Sources: [Codex global instructions](https://learn.chatgpt.com/docs/agent-configuration/agents-md),
[Claude memory](https://code.claude.com/docs/en/memory),
[Claude MCP scopes](https://code.claude.com/docs/en/mcp).

---

## Daily use

```bash
chezmoi update              # git pull + apply (+ run_onchange hooks)
chezmoi diff
chezmoi edit ~/.zshrc       # edits source in ~/.local/share/chezmoi
chezmoi re-add ~/.foo       # copy live file back into repo
```

**Cursor changes → repo:** edit in Cursor, then `sync-cursor`, commit, push. On other machines: `chezmoi update`.

---

## Caveats

- **Hardcoded paths** in `.zshrc` (fnm, Rancher Desktop, mise) — adjust on a new username/machine or templatize later.
- **Linux `.zshrc`** still references **fnm** alongside mise node; you can drop fnm if you only use mise.
- **envman** (`~/.config/envman/load.sh`) — only if you use envman; safe to ignore if the file is missing.
- **Hyprland / Waybar / Mako** — Linux desktop only; harmless on other OSes.
- **`sync-cursor`** overwrites `.chezmoitemplates/cursor-settings.json` with raw JSON — OS `{{ if }}` blocks in that template must be re-added by hand if you rely on them.

---

## Troubleshooting

| Problem                              | Fix                                                                   |
| ------------------------------------ | --------------------------------------------------------------------- |
| `mise install` fails on neovim/tmux  | Install plugins (section 4) then `mise install` again                 |
| Cursor extensions missing            | `cursor` / `cursor.cmd` on PATH? `install-cursor-extensions`          |
| WSL: Windows Cursor has old settings | `chezmoi apply` in WSL; set `windowsAppDataRoaming` in `chezmoi.toml` |
| Template / apply error               | `chezmoi doctor`, `chezmoi diff`                                      |

---

## License

See [LICENSE](LICENSE).
