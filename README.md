# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/) and tracked in git.  
Goal: the same environment on macOS, Linux, and Windows from a single repo — shell, editor, tmux, Cursor, and dev tools.

---

## Quick start

### First-time setup (new machine)

```bash
# Install chezmoi, clone the repo, and apply
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:Thazulk/dotfiles.git
```

Or use the `setup` script in this repo:

```bash
./setup
```

### Updating (already configured machine)

```bash
chezmoi update    # git pull + chezmoi apply
```

### Pushing local changes back to the repo

```bash
chezmoi re-add ~/.zshrc          # a single file
chezmoi re-add --recursive ~/.config/nvim
sync-cursor                      # Cursor settings (see below)
cd ~/.local/share/chezmoi && git add -A && git commit -m "..." && git push
```

---

## Essential chezmoi commands

| Command | What it does |
|---------|--------------|
| `chezmoi apply` | Sync source → home directory; runs `run_onchange_*` scripts |
| `chezmoi apply --dry-run --verbose` | Preview only — scripts **do not** run |
| `chezmoi diff` | Diff between source and live files |
| `chezmoi re-add <path>` | Copy a live file back into the source repo |
| `chezmoi update` | `git pull` + `apply` |
| `chezmoi managed` | List of managed files |
| `chezmoi edit <path>` | Edit a file in the source |
| `chezmoi git -- <git args>` | Run git commands in the source repo |

### Source directory

Default: `~/.local/share/chezmoi`

### Filename conventions

| Source prefix | Target |
|---------------|--------|
| `dot_` | Dot-prefix in home (e.g. `dot_zshrc` → `~/.zshrc`) |
| `dot_config/` | `~/.config/` |
| `private_` | Mode 600 (e.g. `private_mc` → `~/.config/mc`) |
| `executable_` | Executable script |
| `run_onchange_` | Runs only when its rendered content changes |
| `*.tmpl` | Go template — rendered based on OS, env, etc. |
| `Library/Application Support/...` | macOS-specific path |
| `AppData/Roaming/...` | Windows-specific path |

---

## Repo structure

```
.
├── .chezmoiignore.tmpl          # Paths excluded per platform
├── .chezmoitemplates/           # Shared templates (not installed directly)
│   ├── cursor-settings.json
│   └── cursor-keybindings.json
├── setup                        # First-time installer script
├── dot_zshrc.tmpl               # Zsh config (OS-dependent)
├── dot_bashrc                   # Bash config
├── dot_tmux.conf                # Tmux
├── dot_tmux-cht-command         # cheat.sh commands (tmux-cht)
├── dot_tmux-cht-languages
├── dot_zsh/pure/                # Pure prompt (submodule-like)
├── dot_config/
│   ├── nvim/                    # LazyVim-based Neovim
│   ├── mise/config.toml         # mise tool versions
│   ├── ghostty/config           # Ghostty terminal (macOS)
│   ├── hypr/                    # Hyprland (Linux)
│   ├── waybar/                  # Waybar status bar (Linux)
│   ├── mako/                    # Notifications (Linux)
│   ├── superfile/               # Superfile file manager
│   ├── environment.d/           # systemd user env (Linux)
│   ├── private_mc/              # Midnight Commander (private mode)
│   └── Cursor/User/             # Cursor settings (Linux)
├── Library/Application Support/Cursor/User/   # Cursor settings (macOS)
├── AppData/Roaming/Cursor/User/               # Cursor settings (Windows)
├── dot_cursor/                  # ~/.cursor (skills, mcp)
├── dot_agents/                  # ~/.agents/skills
├── dot_local/
│   ├── scripts/                 # ~/.local/scripts
│   └── share/cursor/extensions.txt
├── run_onchange_after_install-cursor-extensions.sh.tmpl
└── run_onchange_after_sync-cursor-settings-to-windows.sh.tmpl  # WSL → Windows Cursor
```

---

## Cursor sync

Cursor settings aim to replicate the VS Code Settings Sync experience via chezmoi, cross-platform.

### What gets synced?

| Component | Live location | Repo location |
|-----------|---------------|---------------|
| Editor settings | See platform paths below | `.chezmoitemplates/cursor-settings.json` |
| Keybindings | Same as above | `.chezmoitemplates/cursor-keybindings.json` |
| Snippets | `.../Cursor/User/snippets/` | `chezmoi re-add` (if any) |
| Extension list | — | `dot_local/share/cursor/extensions.txt` |
| Custom skills | `~/.cursor/skills/` | `dot_cursor/skills/` |
| Agent skills | `~/.agents/skills/` | `dot_agents/skills/` |
| MCP config | `~/.cursor/mcp.json` | `dot_cursor/mcp.json` |

### Cursor paths per platform

| Platform | Settings / keybindings |
|----------|------------------------|
| **macOS** | `~/Library/Application Support/Cursor/User/` |
| **Linux** | `~/.config/Cursor/User/` |
| **Windows** | `%APPDATA%\Cursor\User\` |

The `~/.cursor/` directory works the same on all platforms (`dot_cursor/` prefix).

### How it works

1. **`.chezmoitemplates/cursor-settings.json`** — actual settings content with OS conditionals (`{{ if eq .chezmoi.os "darwin" }}` etc.)
2. **Platform wrappers** — a short `.tmpl` at each of the three paths that includes the shared template:
   ```
   {{ template "cursor-settings.json" . }}
   ```
3. **`.chezmoiignore.tmpl`** — only the current platform's path is applied:
   - macOS: `Library/Application Support/Cursor/...`
   - Linux: `.config/Cursor/...`
   - Windows: `AppData/Roaming/Cursor/...`

### Extension install (`run_onchange`)

`run_onchange_after_install-cursor-extensions.sh.tmpl` uses chezmoi's built-in mechanism:

- **`chezmoi apply`** (and `chezmoi update`) renders the template
- If the rendered script **content changed** (first apply, or `extensions.txt` modified → SHA line changes), it **runs**
- Calls `cursor --install-extension` for each line in `extensions.txt`

> **Note:** `chezmoi apply --dry-run` does **not** execute `run_onchange` scripts.

### `sync-cursor` script

Push Cursor changes made in the UI back into the repo:

```bash
sync-cursor
cd ~/.local/share/chezmoi && git add -A && git commit -m "sync cursor settings" && git push
```

What it does:
1. Live `settings.json` → `.chezmoitemplates/cursor-settings.json` (overwrites!)
2. Keybindings → template (macOS `cmd+i` / others `ctrl+i`)
3. Snippets via `chezmoi re-add`
4. Refreshes extension list → `extensions.txt`
5. Skills and `mcp.json` via `chezmoi re-add`

**Warning:** After `sync-cursor`, OS-specific `{{ if }}` blocks are **removed** from the settings template because the live file is raw JSON. Re-add them manually, or edit `.chezmoitemplates/cursor-settings.json` directly.

### OS-specific settings blocks

| Block | Platform |
|-------|----------|
| `terminal.external.windowsExec`, `eslint.nodePath` | Windows |
| `vs-kubernetes` tool paths | Linux |
| `terminal.integrated.env.osx`, `yaml.schemas` (Users path) | macOS |

### What we do **not** sync

- `~/.cursor/extensions/` — binary extension files (use `extensions.txt` instead)
- `~/.cursor/projects/` — project cache, terminal output, transcripts
- `~/.cursor/plans/` — AI plan files
- `~/.cursor/skills-cursor/` — Cursor built-in skills
- `globalStorage/`, `workspaceStorage/`, `History/` — IDE cache

### Cursor workflow summary

```
[Machine A] Edit in Cursor
    → sync-cursor
    → git commit + push

[Machine B / other OS] chezmoi update
    → settings, keybindings, skills are applied
    → extensions install automatically (run_onchange)
```

### WSL + Windows Cursor (important)

If you run **chezmoi inside WSL** but use the **native Windows Cursor app**, there are two separate config locations:

| Where chezmoi runs | Where settings land on `apply` | Where Windows Cursor reads |
|--------------------|--------------------------------|----------------------------|
| WSL (Linux) | `~/.config/Cursor/User/` | `%APPDATA%\Cursor\User\` |

Windows Cursor does **not** read the WSL Linux path. This repo handles that with two `run_onchange` scripts:

1. **`run_onchange_after_sync-cursor-settings-to-windows.sh`** — detects WSL and copies `settings.json`, `keybindings.json`, and `snippets/` from `~/.config/Cursor/User/` to the Windows AppData path (`/mnt/c/Users/.../AppData/Roaming/Cursor/User/`).
2. **`run_onchange_after_install-cursor-extensions.sh`** — on WSL, installs extensions via the **Windows** `cursor.cmd`, not the Linux CLI.

After `chezmoi apply` in WSL, both scripts run automatically.

**`sync-cursor` in WSL** reads from the **Windows** Cursor config path (not `~/.config/Cursor/User/`), so changes made in the Windows app are captured correctly.

If auto-detection fails, set overrides in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    windowsAppDataRoaming = "/mnt/c/Users/YourWindowsUser/AppData/Roaming"
    windowsCursorCli = "/mnt/c/Users/YourWindowsUser/AppData/Local/Programs/cursor/resources/app/bin/cursor.cmd"
```

**WSL workflow:**

```bash
chezmoi update          # apply + sync to Windows Cursor + install extensions
# or after editing settings in Windows Cursor:
sync-cursor && git commit ... && git push
chezmoi apply           # re-sync to Windows if needed
```

---

## Shell and environment

### Zsh (`dot_zshrc.tmpl`)

- **Pure prompt** (`~/.zsh/pure`)
- Git aliases, docker aliases, kubectl alias
- **Vi mode** for tmux and zsh
- **mise** activation (tool version manager)
- **fzf** integration
- Keybindings:
  - `Ctrl+F` → `tmux-sessionizer`
  - `Alt+F` → `vscode-sessionizer`

OS-specific sections:
- **macOS:** Amazon Q shell blocks, Android SDK/JAVA_HOME, mise path (`/Users/.../mise`)
- **Linux:** zsh-completions, yay alias, fnm, Rancher Desktop PATH, kubectl completion

> **Platform note:** `.zshrc` contains hardcoded user paths (`/home/thazulk/...`, `/Users/szedmakpeter/...`). Update these on a new machine or make them dynamic via templates.

### Bash (`dot_bashrc`)

Simpler bash config: mise, envman, kiro-cli (macOS).

### mise (`dot_config/mise/config.toml`)

Central tool versions: go, node, python, rust, neovim (nightly), ripgrep, fzf, tmux, java, zig, maven, etc.

```bash
mise install    # install all tools from config
```

---

## Tmux

| File | Description |
|------|-------------|
| `dot_tmux.conf` | Main config: vi mode, mouse, pane split, plugins |
| `dot_tmux-cht-command` | cheat.sh command list |
| `dot_tmux-cht-languages` | cheat.sh language list |

### Sessionizer scripts (`~/.local/scripts/`)

| Script | Key / usage | What it does |
|--------|-------------|--------------|
| `tmux-sessionizer` | `Ctrl+F` (zsh) | Pick a project with fzf → tmux session |
| `tmux-windowizer` | — | New tmux window with project |
| `vscode-sessionizer` | `Alt+F` (zsh) | Pick a project with fzf → open in `code` |
| `tmux-cht.sh` | tmux keybind | cheat.sh query in a new window |

Project root directories: `dot_local/scripts/sessionizer-paths.conf` — edit for your own folders.

---

## Neovim

LazyVim-based config: `dot_config/nvim/`

- Plugins: copilot, copilot-chat, dap, neotree, noice, vitest, wakatime, etc.
- `lazy-lock.json` — pinned plugin versions
- LazyVim downloads plugins on first launch

```bash
nvim .    # alias: v
```

---

## Linux desktop environment

> These files are applied by chezmoi on every platform but are only relevant on Linux.

| Component | Path | Description |
|-----------|------|-------------|
| **Hyprland** | `~/.config/hypr/` | Wayland compositor; `hyprland.conf` sources a machine-specific config |
| **Waybar** | `~/.config/waybar/` | Status bar |
| **Mako** | `~/.config/mako/` | Notifications |
| **Superfile** | `~/.config/superfile/` | TUI file manager, themes |
| **Midnight Commander** | `~/.config/mc/` | `private_` — mode 600 |

Hyprland machine configs:
- `thinkpad-E590.conf` — active (default in `hyprland.conf`)
- `nvidia-desktop.conf` — commented out; switch for NVIDIA desktop

---

## macOS-specific

| Component | Path |
|-----------|------|
| Ghostty terminal | `~/.config/ghostty/config` |
| Cursor settings | `~/Library/Application Support/Cursor/User/` |
| Android SDK | In `.zshrc`: `~/Library/Android/sdk` |

---

## Windows-specific

| Component | Path |
|-----------|------|
| Cursor settings | `%APPDATA%\Cursor\User\` |
| Cursor CLI | `cursor` or `cursor.cmd` (extension installer tries both) |
| Keybindings | `ctrl+i` (`cmd+i` on macOS) |

### Windows notes

- Hyprland/Waybar/Mako/Superfile configs are applied but unused — can be added to `.chezmoiignore.tmpl` later
- `.zshrc` is Linux/macOS-oriented; Git Bash or WSL recommended on Windows
- `tmux.conf` uses `xclip` — WSL/Linux clipboard; won't work with native Windows tmux

---

## Cross-platform notes

### General

1. **Hardcoded paths** — several files contain fixed usernames/paths (e.g. `/home/thazulk`, `/Users/szedmakpeter`). Check `.zshrc` and Cursor settings OS blocks on a new machine.
2. **`chezmoi apply` overwrites** managed files — local edits made outside chezmoi are lost on apply.
3. **`chezmoi re-add` overwrites** the source — be careful with template files.
4. **Private files** (`private_mc`) — mode 600; don't commit secrets in plain text.

### macOS

- Cursor settings: `Library/Application Support/...` — space in path; chezmoi handles it
- `mise activate` hardcoded path: `/Users/szedmakpeter/.local/bin/mise`

### Linux

- Cursor settings: `~/.config/Cursor/User/`
- `tmux.conf`: requires `xclip` for clipboard
- Hyprland: source the correct machine config in `hyprland.conf`
- Rancher Desktop and fnm paths are user-specific in `.zshrc`

### Windows

- Cursor: `AppData/Roaming/Cursor/User/`
- Extension installer: `cursor.cmd` fallback
- Most Linux desktop configs are irrelevant

### WSL + Windows Cursor

- Run `chezmoi apply` in WSL — settings are copied to Windows AppData automatically
- `sync-cursor` reads from Windows Cursor paths when run in WSL
- If paths differ (non-default Windows username), configure `windowsAppDataRoaming` in `chezmoi.toml`
- Restart Windows Cursor after apply if settings don't appear immediately

---

## Adding new files to chezmoi

```bash
# Simple dotfile
chezmoi add ~/.myconfig

# Recursive directory
chezmoi add --recursive ~/.config/myapp

# Convert to template (.tmpl suffix added in source)
chezmoi add --template ~/.zshrc

# Secrets / false-positive secret scan
chezmoi add --secrets ignore ~/.cursor/skills
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `chezmoi apply` doesn't install Cursor settings | Check OS and `.chezmoiignore.tmpl` |
| Extensions don't install | Is `cursor` CLI on PATH? Run: `chezmoi apply --verbose` |
| Template error | `chezmoi execute-template < file.tmpl` |
| Diff between live and source | `chezmoi diff` — then `chezmoi apply` or `chezmoi re-add` |
| OS blocks missing after `sync-cursor` | Manually restore `{{ if eq .chezmoi.os ... }}` sections |
| WSL: Windows Cursor has no settings | Run `chezmoi apply` in WSL; check `windowsAppDataRoaming` in `chezmoi.toml` |
| WSL: extensions not installed | Verify Windows `cursor.cmd` path; set `windowsCursorCli` in `chezmoi.toml` |
| Secret scan error on `chezmoi add` | Use `--secrets ignore` flag |

---

## License

See [LICENSE](LICENSE). Some embedded projects (e.g. zsh pure, nvim, skills) have their own licenses.
