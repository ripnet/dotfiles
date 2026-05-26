# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package     | Manages                          | macOS | Linux         |
|-------------|----------------------------------|-------|---------------|
| `zsh`       | `~/.zshrc`                       | ✅    | ✅            |
| `nvim`      | `~/.config/nvim/`                | ✅    | ✅            |
| `alacritty` | `~/.config/alacritty/`           | ✅    | prompt (y/N)  |
| `karabiner` | `~/.config/karabiner/`           | ✅    | ❌            |

## Quick Start

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
bash deploy.sh
```

This will:
1. Detect your OS (macOS or Linux)
2. Install required dependencies (see below)
3. Stow the appropriate config packages

## Dependencies installed

- `git`, `zsh`, `stow`, `neovim`, `fzf`, `zoxide`
- **JetBrainsMono Nerd Font** (required by the Alacritty config)
- On macOS: via [Homebrew](https://brew.sh) (installed automatically if missing)
- On Linux: via your distro's package manager (`apt`, `dnf`, `pacman`, or `zypper`)

## Manual stowing

To stow or re-stow a single package:

```bash
cd ~/dotfiles
stow --restow nvim
```

To unstow a package:

```bash
stow --delete nvim
```

## Local overrides

Put any machine-specific shell config in `~/.zshrc.local` — it is sourced automatically at the end of `.zshrc` if it exists.
