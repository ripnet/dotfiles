#!/usr/bin/env bash
# install_deps_mac.sh — Install dotfile dependencies on macOS via Homebrew
set -euo pipefail

INFO='\033[0;34m[INFO]\033[0m'
OK='\033[0;32m[OK]\033[0m'
WARN='\033[0;33m[WARN]\033[0m'

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
  echo -e "${INFO} Homebrew not found — installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo -e "${OK} Homebrew already installed"
fi

# ---------------------------------------------------------------------------
# CLI packages
# ---------------------------------------------------------------------------
PACKAGES=(git zsh stow neovim fzf zoxide)

for pkg in "${PACKAGES[@]}"; do
  if brew list --formula "$pkg" &>/dev/null; then
    echo -e "${OK} $pkg already installed"
  else
    echo -e "${INFO} Installing $pkg..."
    brew install "$pkg"
  fi
done

# ---------------------------------------------------------------------------
# JetBrainsMono Nerd Font
# ---------------------------------------------------------------------------
FONT_CASK="font-jetbrains-mono-nerd-font"
if brew list --cask "$FONT_CASK" &>/dev/null; then
  echo -e "${OK} JetBrainsMono Nerd Font already installed"
else
  echo -e "${INFO} Installing JetBrainsMono Nerd Font..."
  brew install --cask "$FONT_CASK"
fi

echo -e "${OK} macOS dependencies done."
