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

The portable definitions are in this repository: mise runtimes, the shared
`~/.agents/skills/` directory (including Caveman), and the Codex
`gpt-toolset` skill. Install the executable tools explicitly after applying
dotfiles; this keeps `chezmoi apply` deterministic and avoids unexpected
package downloads or assistant-config changes.

```bash
# macOS, Linux, or WSL
bootstrap-ai-toolstack
check-ai-toolstack

# opt-in integrations that modify the local client/proxy setup
TOOLSTACK_ENABLE_RTK=1 bootstrap-ai-toolstack
TOOLSTACK_ENABLE_HEADROOM=1 bootstrap-ai-toolstack
```

On native Windows PowerShell:

```powershell
& "$HOME/.local/scripts/bootstrap-ai-toolstack.ps1"
```

The bootstrap adds missing Codex MCP servers using the commands found on that
machine. It intentionally does not version `~/.codex/config.toml`: it can hold
machine-specific paths and locally added servers. If an existing MCP command
path changes, remove that one entry with `codex mcp remove NAME`, then rerun the
bootstrap.

`repowise init` and indexing remain project-level actions. Put project-specific
instructions in that repository's `AGENTS.md`; do not add generated indexes,
tokens, or API credentials to this dotfiles repository.

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
