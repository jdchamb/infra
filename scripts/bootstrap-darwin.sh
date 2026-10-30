#!/usr/bin/env bash
# ==============================================================================
# INFRASTRUCTURE UTILITY: scripts/bootstrap-darwin.sh
# ==============================================================================
#
# PURPOSE & ARCHITECTURE:
#   Bootstraps a fresh Apple Silicon or Intel macOS machine (such as 'MBA-Chambers'
#   or '308-225660') with the official multi-user Nix daemon and activates its
#   declarative nix-darwin + Home Manager + nix-homebrew configuration.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   On a brand new Mac, Nix is not installed, and macOS manages '/etc/zshrc' and
#   '/etc/bashrc' with its own factory templates.
#   - Step 1 installs the official multi-user Nix daemon, creating build users
#     ('_nixbld1' .. '_nixbld32') and mounting the dedicated APFS '/nix' volume.
#   - Step 2 backs up macOS default '/etc' shell files so nix-darwin can safely link
#     its own managed shell initialization files without throwing collision errors.
#   - Step 3 compiles and activates the nix-darwin system generation, managing
#     Homebrew packages, macOS system defaults, and fonts declaratively.
#
# USAGE:
#   chmod +x ~/src/infra/scripts/bootstrap-darwin.sh
#   ~/src/infra/scripts/bootstrap-darwin.sh [hostname]
#   Example: ~/src/infra/scripts/bootstrap-darwin.sh MBA-Chambers
# ==============================================================================

# Bash strict mode:
#   -e: Exit immediately if any command fails
#   -u: Treat unset variables as an error
#   -o pipefail: Pipeline return status is the value of the last non-zero exit command
set -euo pipefail

# Prevent running directly with 'sudo':
# nix-darwin must run in the user's login environment so that Home Manager
# targets $HOME (/Users/jchambers) rather than root (/var/root).
# nix-darwin will automatically prompt for sudo when writing system files.
if [ "$(id -u)" -eq 0 ]; then
  echo "=================================================================="
  echo "  ERROR: Do not run this script as root (e.g. 'sudo $0')."
  echo "  Run it as your standard user. nix-darwin will prompt for sudo"
  echo "  internally when escalating to write system files."
  echo "=================================================================="
  exit 1
fi

# Pre-authenticate sudo timestamp to avoid silent timeouts
sudo -v

# Redirect both standard output (stdout) and standard error (stderr) to /tmp/bootstrap-darwin.log
# while simultaneously echoing output live to the terminal console (using 'tee')
LOG_FILE="/tmp/bootstrap-darwin.log"
: > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

# Resolve repository directory (defaults to ~/src/infra if FLAKE_DIR is not set)
FLAKE_DIR="${FLAKE_DIR:-$HOME/src/infra}"

# Detect macOS LocalHostName dynamically via scutil, or fallback to hostname -s
TARGET_HOST="${1:-$(scutil --get LocalHostName 2>/dev/null || hostname -s)}"

echo "=================================================================="
echo "  Bootstrapping macOS Node: ${TARGET_HOST}"
echo "  Flake Repository:         ${FLAKE_DIR}"
echo "=================================================================="

# ------------------------------------------------------------------------------
# 1. INSTALL MULTI-USER NIX (IF NOT ALREADY INSTALLED)
# ------------------------------------------------------------------------------
# Check if the Nix binary exists at its standard multi-user location
if [ ! -x "/nix/var/nix/profiles/default/bin/nix" ]; then
  echo "==> [1/3] Installing official multi-user Nix daemon..."
  # Download official installation script directly from nixos.org
  curl -fsSL https://nixos.org/nix/install -o /tmp/nix-install.sh
  # Run non-interactive daemon installation (creates /nix APFS volume and system users)
  sh /tmp/nix-install.sh --daemon --yes
else
  echo "==> [1/3] Nix is already installed at /nix/var/nix/profiles/default/bin/nix"
fi

# Source the Nix daemon shell profile to put 'nix' on PATH in the current session
if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
  # shellcheck disable=SC1091
  . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi

# Ensure Nix binaries are present in PATH for subsequent commands in this script
export PATH="/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH"

# Enable Nix Flakes & nix-command via environment variable
# This ensures Nix commands succeed even while /etc/nix/nix.conf is in transition
export NIX_CONFIG="experimental-features = nix-command flakes"

# ------------------------------------------------------------------------------
# 2. PREPARE /etc CONFIGURATION FILES FOR NIX-DARWIN ACTIVATION
# ------------------------------------------------------------------------------
# nix-darwin links its own version of system files (/etc/bashrc, /etc/zshrc,
# /etc/nix/nix.conf, /etc/pam.d/sudo_local). If Apple's original files or previous
# unmanaged configs exist as regular files, nix-darwin aborts with a collision error.
# We safely rename any non-symlink file with a '.before-nix-darwin' suffix.
echo "==> [2/3] Preparing /etc configuration backups for nix-darwin..."
for etc_file in /etc/bashrc /etc/zshrc /etc/bash.bashrc /etc/nix/nix.conf /etc/pam.d/sudo_local; do
  if [ -e "$etc_file" ] && [ ! -L "$etc_file" ]; then
    echo "    Moving existing $etc_file to ${etc_file}.before-nix-darwin"
    sudo mv "$etc_file" "${etc_file}.before-nix-darwin"
  fi
done

# ------------------------------------------------------------------------------
# 3. BUILD & ACTIVATE NIX-DARWIN CONFIGURATION
# ------------------------------------------------------------------------------
echo "==> [3/3] Building and activating nix-darwin configuration (.#${TARGET_HOST})..."
cd "$FLAKE_DIR"

# IMPORTANT: Do NOT invoke these commands with 'sudo'!
# Running as standard user preserves $HOME for Home Manager.
# darwin-rebuild / nix-darwin will prompt for sudo when activating system files.

# Case A: darwin-rebuild is already installed on the system PATH
if command -v darwin-rebuild &>/dev/null; then
  darwin-rebuild switch --flake "${FLAKE_DIR}#${TARGET_HOST}"
# Case B: darwin-rebuild was pre-compiled into the Flake result build folder
elif [ -x "${FLAKE_DIR}/result/sw/bin/darwin-rebuild" ]; then
  "${FLAKE_DIR}/result/sw/bin/darwin-rebuild" switch --flake "${FLAKE_DIR}#${TARGET_HOST}"
# Case C: First run: bootstrap using 'nix run nix-darwin'
else
  nix \
    --extra-experimental-features "nix-command flakes" \
    run nix-darwin -- switch --flake "${FLAKE_DIR}#${TARGET_HOST}"
fi

echo "=================================================================="
echo "  SUCCESS: ${TARGET_HOST} is now managed by nix-darwin!"
echo "  Open a new terminal tab and run 'rebuild' for future updates."
echo "=================================================================="
