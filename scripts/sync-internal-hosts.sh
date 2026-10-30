#!/usr/bin/env bash
# ==============================================================================
# SCRIPT: scripts/sync-internal-hosts.sh
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Synchronizes decrypted internal LAN host mappings (storage.internal, ai.internal)
#   from secrets/ips.yaml into the local operating system's /etc/hosts file.
#   Designed for macOS nodes (308-225660, MBA-Chambers) and standalone Linux nodes.
#
# USAGE:
#   ./scripts/sync-internal-hosts.sh
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IPS_FILE="$REPO_ROOT/secrets/ips.yaml"

if [ ! -f "$IPS_FILE" ]; then
  echo "Error: Secrets file '$IPS_FILE' not found." >&2
  exit 1
fi

echo "==> Decrypting internal host mappings with SOPS..."
if ! command -v sops >/dev/null 2>&1; then
  echo "Error: 'sops' command not found on PATH." >&2
  exit 1
fi

HOSTS_ENTRIES=$(sops --extract '["hosts-internal"]' "$IPS_FILE" 2>/dev/null || true)

if [ -z "$HOSTS_ENTRIES" ]; then
  echo "Error: Could not decrypt '$IPS_FILE' with local SOPS keys." >&2
  echo "Please ensure your Age private key is available at ~/.config/sops/age/keys.txt to decrypt internal host mappings." >&2
  exit 1
fi

echo "==> Updating /etc/hosts (requires sudo)..."
TMP_HOSTS=$(mktemp)
# Remove any existing .internal entries
grep -v "\.internal" /etc/hosts > "$TMP_HOSTS" || true
# Append new entries with header
cat << EOF >> "$TMP_HOSTS"

# Fleet Internal Services (Managed by infra/scripts/sync-internal-hosts.sh)
$HOSTS_ENTRIES
EOF

sudo cp "$TMP_HOSTS" /etc/hosts
rm -f "$TMP_HOSTS"
echo "==> Successfully updated /etc/hosts with internal endpoints:"
echo "$HOSTS_ENTRIES"
