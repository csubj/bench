#!/usr/bin/env bash
#
# bootstrap.sh - blank-machine entrypoint for the bench dotfiles repo.
#
# Brings a fresh macOS machine to a converged state:
#   Xcode Command Line Tools -> Homebrew -> chezmoi + 1password-cli -> chezmoi apply
#
# Usage (from a clone):
#   ./bootstrap.sh
#
# Usage (remote, without a prior clone):
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/<owner>/bench/main/bootstrap.sh)"
#   # or simply: chezmoi init --apply <owner>/bench
#
set -euo pipefail

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }

if [[ "$(uname -s)" != "Darwin" ]]; then
  warn "This bootstrap targets macOS. Detected $(uname -s); continuing anyway."
fi

# 1. Xcode Command Line Tools (provides git, compilers).
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools..."
  xcode-select --install || true
  log "Complete the CLT installer dialog, then re-run this script."
  # Wait for the tools to appear so an interactive run can continue.
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
fi

# 2. Homebrew.
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is on PATH for the rest of this script (Apple Silicon vs Intel).
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. chezmoi + 1Password CLI (needed for apply + secret injection).
log "Installing chezmoi and 1password-cli..."
brew install chezmoi 1password-cli

# 4. Apply this repo.
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log "Applying dotfiles from ${SOURCE_DIR}..."
chezmoi init --apply --source "${SOURCE_DIR}"

log "Done. Open a new Ghostty window (or 'exec zsh') to load your shell."
