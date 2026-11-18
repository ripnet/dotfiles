#!/usr/bin/env bash
# install_deps_linux.sh — Install dotfile dependencies on Linux
set -euo pipefail

INFO='\033[0;34m[INFO]\033[0m'
OK='\033[0;32m[OK]\033[0m'
WARN='\033[0;33m[WARN]\033[0m'
ERROR='\033[0;31m[ERROR]\033[0m'

# ---------------------------------------------------------------------------
# Detect package manager
# ---------------------------------------------------------------------------
if command -v apt-get &>/dev/null; then
  PKG_MGR="apt"
elif command -v dnf &>/dev/null; then
  PKG_MGR="dnf"
elif command -v pacman &>/dev/null; then
  PKG_MGR="pacman"
elif command -v zypper &>/dev/null; then
  PKG_MGR="zypper"
else
  echo -e "${ERROR} No supported package manager found (apt, dnf, pacman, zypper)."
  exit 1
fi
echo -e "${INFO} Detected package manager: ${PKG_MGR}"

# ---------------------------------------------------------------------------
# Install packages via detected package manager
# ---------------------------------------------------------------------------
install_pkgs() {
  case "$PKG_MGR" in
    apt)     sudo apt-get install -y "$@" ;;
    dnf)     sudo dnf install -y "$@" ;;
    pacman)  sudo pacman -S --noconfirm "$@" ;;
    zypper)  sudo zypper install -y "$@" ;;
  esac
}

# Update package lists first
echo -e "${INFO} Updating package lists..."
case "$PKG_MGR" in
  apt)    sudo apt-get update -y ;;
  dnf)    sudo dnf check-update -y || true ;;
  pacman) sudo pacman -Sy ;;
  zypper) sudo zypper refresh ;;
esac

# Core packages (names are consistent across major distros).
# fontconfig provides fc-cache for the font install below; minimal installs
# and container templates do not have it.
PACKAGES=(git zsh stow fzf fontconfig)
# Skip the distro neovim when one is already installed (e.g. the pinned
# release from the bootstrap script) - Debian's is too old anyway.
if command -v nvim &>/dev/null; then
  echo -e "${OK} nvim already installed: $(command -v nvim)"
else
  PACKAGES+=(neovim)
fi
echo -e "${INFO} Installing core packages: ${PACKAGES[*]}"
install_pkgs "${PACKAGES[@]}"

# ---------------------------------------------------------------------------
# zoxide — try package manager first, fall back to upstream install script
# ---------------------------------------------------------------------------
if command -v zoxide &>/dev/null; then
  echo -e "${OK} zoxide already installed"
else
  echo -e "${INFO} Attempting to install zoxide via package manager..."
  if install_pkgs zoxide 2>/dev/null; then
    echo -e "${OK} zoxide installed via package manager"
  else
    echo -e "${WARN} zoxide not in package repos — installing via upstream script..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    echo -e "${OK} zoxide installed to ~/.local/bin"
    echo -e "${WARN} Ensure ~/.local/bin is in your PATH."
  fi
fi

# ---------------------------------------------------------------------------
# JetBrainsMono Nerd Font
# ---------------------------------------------------------------------------
# Unpacked to a temp dir and moved into place only once that succeeded, and
# only counted as installed once fontconfig can see it - so a failed run is
# retried next time instead of being skipped.
FONT_DIR="${HOME}/.local/share/fonts/JetBrainsMono"
if [[ -d "$FONT_DIR" && -n "$(fc-list "JetBrainsMono Nerd Font" family 2>/dev/null)" ]]; then
  echo -e "${OK} JetBrainsMono Nerd Font already installed at ${FONT_DIR}"
else
  echo -e "${INFO} Downloading JetBrainsMono Nerd Font..."
  TMPDIR_FONT="$(mktemp -d)"
  trap 'rm -rf "$TMPDIR_FONT"' EXIT
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
  curl -fsSL "$FONT_URL" -o "${TMPDIR_FONT}/JetBrainsMono.tar.xz"
  mkdir -p "${TMPDIR_FONT}/JetBrainsMono"
  tar -xJf "${TMPDIR_FONT}/JetBrainsMono.tar.xz" -C "${TMPDIR_FONT}/JetBrainsMono"
  mkdir -p "$(dirname "$FONT_DIR")"
  rm -rf "$FONT_DIR"
  mv "${TMPDIR_FONT}/JetBrainsMono" "$FONT_DIR"
  echo -e "${INFO} Refreshing font cache..."
  fc-cache -f "$FONT_DIR"
  echo -e "${OK} JetBrainsMono Nerd Font installed"
fi

echo -e "${OK} Linux dependencies done."
