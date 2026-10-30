#!/usr/bin/env bash
# ==============================================================================
# INFRASTRUCTURE UTILITY: scripts/bootstrap-darwin.sh
# ==============================================================================
#
# PURPOSE:
#   Bootstraps a fresh Apple Silicon macOS node (such as 'MBA-Chambers' or
#   '308-225660') with the official multi-user Nix daemon and activates its
#   declarative nix-darwin + Home Manager + nix-homebrew configuration.
#
# USAGE:
#   chmod +x ~/src/infra/scripts/bootstrap-darwin.sh
#   ~/src/infra/scripts/bootstrap-darwin.sh [hostname]
# ==============================================================================

set -euo pipefail

LOG_FILE="/tmp/bootstrap-darwin.log"
: > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

FLAKE_DIR="${FLAKE_DIR:-$HOME/src/infra}"
TARGET_HOST="${1:-$(scutil --get LocalHostName 2>/dev/null || hostname -s)}"

echo "=================================================================="
echo "  Bootstrapping macOS Node: ${TARGET_HOST}"
echo "  Flake Repository:         ${FLAKE_DIR}"
echo "=================================================================="

# ------------------------------------------------------------------------------
# 1. INSTALL MULTI-USER NIX (IF NOT ALREADY INSTALLED)
# ------------------------------------------------------------------------------
if [ ! -x "/nix/var/nix/profiles/default/bin/nix" ]; then
  echo "==> [1/3] Installing official multi-user Nix daemon..."
  curl -fsSL https://nixos.org/nix/install -o /tmp/nix-install.sh
  sh /tmp/nix-install.sh --daemon --yes
else
  echo "==> [1/3] Nix is already installed at /nix/var/nix/profiles/default/bin/nix"
fi

# Source the Nix daemon profile in the current shell session
if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
  # shellcheck disable=SC1091
  . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi
export PATH="/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH"

# ------------------------------------------------------------------------------
# 2. PREPARE /etc SHELL FILES FOR NIX-DARWIN ACTIVATION
# ------------------------------------------------------------------------------
echo "==> [2/3] Preparing /etc shell configuration backups for nix-darwin..."
for etc_file in /etc/bashrc /etc/zshrc /etc/bash.bashrc; do
  if [ -f "$etc_file" ] && [ ! -L "$etc_file" ]; then
    echo "    Moving existing $etc_file to ${etc_file}.before-nix-darwin"
    sudo mv "$etc_file" "${etc_file}.before-nix-darwin"
  fi
done

# ------------------------------------------------------------------------------
# 3. BUILD & ACTIVATE NIX-DARWIN CONFIGURATION
# ------------------------------------------------------------------------------
echo "==> [3/3] Building and activating nix-darwin configuration (.#${TARGET_HOST})..."
cd "$FLAKE_DIR"

if command -v darwin-rebuild &>/dev/null; then
  sudo darwin-rebuild switch --flake "${FLAKE_DIR}#${TARGET_HOST}"
elif [ -x "${FLAKE_DIR}/result/sw/bin/darwin-rebuild" ]; then
  sudo "${FLAKE_DIR}/result/sw/bin/darwin-rebuild" switch --flake "${FLAKE_DIR}#${TARGET_HOST}"
else
  sudo /nix/var/nix/profiles/default/bin/nix \
    --extra-experimental-features "nix-command flakes" \
    run nix-darwin -- switch --flake "${FLAKE_DIR}#${TARGET_HOST}"
fi

echo "=================================================================="
echo "  SUCCESS: ${TARGET_HOST} is now managed by nix-darwin!"
echo "  Open a new terminal tab and run 'rebuild' for future updates."
echo "=================================================================="
