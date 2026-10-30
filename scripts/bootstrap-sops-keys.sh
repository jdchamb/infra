#!/usr/bin/env bash
# ==============================================================================
# INFRASTRUCTURE UTILITY: scripts/bootstrap-sops-keys.sh
# ==============================================================================
#
# ROLE & ARCHITECTURE (Priority #1 — Zero-Trust Secrets Bootstrap from Scratch):
#   Generates pristine Age cryptographic keypairs for Mozilla SOPS, places the
#   private key in the platform-appropriate location with strict POSIX permissions
#   (mode 0600/0400), displays the public key for .sops.yaml registration, and
#   prompts for immediate offline disaster-recovery backup.
#
# WHY THIS EXISTS:
#   When previous SOPS keys are lost, systems cannot decrypt stored credentials.
#   Re-establishing trust must happen *before* configuring dependent services
#   (CIFS mounts, Borg backups, databases) so that no credentials ever leak
#   into version control or the world-readable /nix/store in plaintext.
#
# LOCATIONS MANAGED:
#   - macOS (nix-darwin / user):   ~/.config/sops/age/keys.txt
#   - NixOS (system daemon):        /var/lib/sops-nix/308-key.txt
#
# USAGE:
#   chmod +x scripts/bootstrap-sops-keys.sh
#   ./scripts/bootstrap-sops-keys.sh [work|personal|host]
# ==============================================================================

set -euo pipefail

KEY_TYPE="''${1:-work}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

echo "=================================================================="
echo "  PRIORITY #1: SOPS / AGE KEY GENERATOR & BOOTSTRAP FROM SCRATCH"
echo "  Target Scope: $KEY_TYPE"
echo "=================================================================="

# Check for age-keygen binary
if ! command -v age-keygen >/dev/null 2>&1; then
  echo "[-] 'age-keygen' not found in PATH."
  echo "[*] Attempting to run via nix-shell..."
  EXEC_CMD="nix-shell -p age --run"
else
  EXEC_CMD=""
fi

# Detect OS
OS_TYPE="$(uname -s)"
if [ "$OS_TYPE" = "Darwin" ]; then
  DEST_DIR="$HOME/.config/sops/age"
  DEST_FILE="$DEST_DIR/keys.txt"
else
  DEST_DIR="/var/lib/sops-nix"
  DEST_FILE="$DEST_DIR/308-key.txt"
fi

mkdir -p "$DEST_DIR"

# Backup existing key file if present
if [ -f "$DEST_FILE" ]; then
  BACKUP_FILE="${DEST_FILE}.bak_${TIMESTAMP}"
  echo "[!] Existing key file detected at $DEST_FILE"
  echo "[*] Archiving current file to $BACKUP_FILE"
  cp "$DEST_FILE" "$BACKUP_FILE"
  chmod 0600 "$BACKUP_FILE"
fi

# Generate new Age keypair
TEMP_KEY="$(mktemp /tmp/age-key.XXXXXX)"
chmod 0600 "$TEMP_KEY"

if [ -n "$EXEC_CMD" ]; then
  $EXEC_CMD "age-keygen -o $TEMP_KEY"
else
  age-keygen -o "$TEMP_KEY"
fi

PUBLIC_KEY="$(grep 'public key:' "$TEMP_KEY" | awk '{print $NF}')"

# If Darwin, append or create in ~/.config/sops/age/keys.txt
if [ "$OS_TYPE" = "Darwin" ]; then
  cat "$TEMP_KEY" >> "$DEST_FILE"
  chmod 0600 "$DEST_FILE"
else
  # NixOS target requires root ownership
  if [ "$(id -u)" -eq 0 ]; then
    cp "$TEMP_KEY" "$DEST_FILE"
    chmod 0400 "$DEST_FILE"
  else
    echo "[*] Escalating to write root-owned key to $DEST_FILE..."
    sudo cp "$TEMP_KEY" "$DEST_FILE"
    sudo chmod 0400 "$DEST_FILE"
    sudo chown root:root "$DEST_FILE"
  fi
fi

rm -f "$TEMP_KEY"

echo ""
echo "=================================================================="
echo "  SUCCESS: NEW AGE KEYPAIR GENERATED"
echo "=================================================================="
echo "  Private Key Stored At: $DEST_FILE"
echo "  Permissions Enforced:  0600 / 0400"
echo ""
echo "  >>> YOUR NEW PUBLIC KEY (ADD TO .sops.yaml) <<<"
echo "  $PUBLIC_KEY"
echo "=================================================================="
echo ""
echo "CRITICAL NEXT STEPS:"
echo "1. Paste the public key above into '.sops.yaml' under the appropriate rule."
echo "2. IMMEDIATELY copy and backup the private key from:"
echo "   $DEST_FILE"
echo "   Store it into an offline password vault (Bitwarden, 1Password, or encrypted USB)."
echo "3. Re-initialize encrypted secrets with: sops secrets/work.yaml"
echo "=================================================================="
