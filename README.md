# dotfiles

Personal macOS dotfiles managed with symlinks.

## Setup

```sh
./link.sh
```

Creates symlinks for all configs into their expected locations.

## Tools

| Tool | Purpose |
|------|---------|
| [Neovim](./nvim/) | Primary editor, Lazy plugin manager |
| [Zsh](./zsh/) | Shell, oh-my-zsh, fzf |
| [Wezterm](./wezterm/) | Terminal emulator, Catppuccin Mocha, JetBrains Mono |
| [Tmux](./tmux/) | Session management + tms sessionizer |
| [Aerospace](./aerospace/) | Tiling window manager |
| [Hammerspoon](./hammerspoon/) | Ctrl→Cmd remapping when outside WezTerm |
| [Git](./git/) | Dual config: personal/work via `includeIf` |
| [Claude](./claude/) | Claude Code commands & skills |
| [SSH](./ssh/) | Multi-host key config |

## Structure

```
dotfiles/
├── aerospace/     # window manager
├── claude/        # claude code config
├── git/           # gitconfig (personal + work)
├── hammerspoon/   # macos automation
├── nvim/          # neovim config
├── opencode/      # opencode config
├── ssh/           # ssh config
├── tmux/          # tmux + tms config
├── wezterm/       # terminal config
├── yt-dlp/        # yt-dlp config
├── zsh/           # zshrc + custom scripts
└── link.sh        # symlink installer
```

## Key bindings

**Wezterm:** leader = `Ctrl-A`

**Tmux:** `Ctrl-F` opens tms session picker

**Aerospace:** `Alt+hjkl` focus, `Alt+Shift+hjkl` move, `Alt+[number]` switch workspace

**Neovim:** see `nvim/lua/mappings.lua`

## Git

Separate identities via `includeIf gitdir`:
- `~/dev/personal/` → `luuklelifeld@gmail.com`
- `~/dev/publitas/` → `luuk@publitas.com`
