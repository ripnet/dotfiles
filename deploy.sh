#!/usr/bin/env bash
# deploy.sh — Install dependencies and stow dotfiles
set -euo pipefail

# ---------------------------------------------------------------------------
# Colours
# ---------------------------------------------------------------------------
INFO='\033[0;34m[INFO]\033[0m'
OK='\033[0;32m[OK]\033[0m'
WARN='\033[0;33m[WARN]\033[0m'
ERROR='\033[0;31m[ERROR]\033[0m'

# ---------------------------------------------------------------------------
# Resolve the dotfiles directory (wherever this script lives)
# ---------------------------------------------------------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# OS detection
# ---------------------------------------------------------------------------
case "$(uname -s)" in
  Darwin) OS="mac" ;;
  Linux)  OS="linux" ;;
  *)
    echo -e "${ERROR} Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac
echo -e "${INFO} Detected OS: ${OS}"

# ---------------------------------------------------------------------------
# Install dependencies
# ---------------------------------------------------------------------------
INSTALLER="${DOTFILES_DIR}/install_deps_${OS}.sh"
if [[ ! -f "$INSTALLER" ]]; then
  echo -e "${ERROR} Installer script not found: ${INSTALLER}"
  exit 1
fi

echo -e "${INFO} Running dependency installer: ${INSTALLER}"
bash "$INSTALLER"

# ---------------------------------------------------------------------------
# Verify required tools are available
# ---------------------------------------------------------------------------
echo -e "${INFO} Verifying installed tools..."
REQUIRED=(git zsh stow nvim fzf zoxide)
ALL_OK=true
for tool in "${REQUIRED[@]}"; do
  if command -v "$tool" &>/dev/null; then
    echo -e "${OK} ${tool} → $(command -v "$tool")"
  else
    echo -e "${ERROR} ${tool} not found in PATH after installation."
    ALL_OK=false
  fi
done

if [[ "$ALL_OK" == false ]]; then
  echo -e "${ERROR} One or more required tools are missing. Aborting stow step."
  exit 1
fi

# ---------------------------------------------------------------------------
# Note: vim alias
# ---------------------------------------------------------------------------
echo -e "${INFO} Note: 'vim' is aliased to 'nvim' in .zshrc — no binary symlink needed."

# ---------------------------------------------------------------------------
# Stow packages
# ---------------------------------------------------------------------------
cd "$DOTFILES_DIR"

# Always stow on both platforms
PACKAGES=(zsh nvim)

if [[ "$OS" == "mac" ]]; then
  PACKAGES+=(alacritty karabiner)
else
  # Linux: alacritty is optional (desktop systems only)
  printf "${INFO} Stow alacritty config? (desktop Linux only) [y/N] "
  read -r stow_alacritty </dev/tty
  if [[ "$stow_alacritty" =~ ^[Yy]$ ]]; then
    PACKAGES+=(alacritty)
  else
    echo -e "${INFO} Skipping alacritty."
  fi
  echo -e "${INFO} Skipping karabiner (macOS only)."
fi

echo -e "${INFO} Stowing packages: ${PACKAGES[*]}"
for pkg in "${PACKAGES[@]}"; do
  echo -e "${INFO} stow --restow ${pkg}"
  stow --restow --dir="$DOTFILES_DIR" --target="$HOME" "$pkg"
  echo -e "${OK} ${pkg} stowed"
done

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
echo -e "${OK} ============================================"
echo -e "${OK}  Dotfiles deployed successfully!"
echo -e "${OK}  Packages stowed: ${PACKAGES[*]}"
echo -e "${OK} ============================================"
echo ""
echo -e "${INFO} Start a new zsh session to load your config."
