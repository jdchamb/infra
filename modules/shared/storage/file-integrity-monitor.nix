# ==============================================================================
# SHARED STORAGE MODULE: modules/shared/storage/file-integrity-monitor.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 2):
#   Provides the File Integrity & Checksum Health Monitor ('rhash' + custom
#   'fleet-integrity-check' CLI) across Linux and macOS nodes. Generates and
#   verifies '.sha256' / 'SHA256SUMS' manifests alongside critical archives,
#   USB ISO libraries, and NAS cold storage to detect silent bitrot corruption.
# ==============================================================================

{ pkgs, ... }:

let
  fleetIntegrityCheck = pkgs.writeShellScriptBin "fleet-integrity-check" ''
    set -euo pipefail
    ACTION="''${1:-verify}"
    TARGET_DIR="''${2:-.}"
    MANIFEST="$TARGET_DIR/SHA256SUMS"

    case "$ACTION" in
      init|update)
        echo "==> Generating/updating recursive SHA-256 manifest in $MANIFEST..."
        ${pkgs.rhash}/bin/rhash --sha256 --recursive --update="$MANIFEST" "$TARGET_DIR"
        echo "==> Checksum manifest updated: $MANIFEST"
        ;;
      verify|check)
        if [ ! -f "$MANIFEST" ]; then
          echo "Error: No SHA256SUMS manifest found in '$TARGET_DIR'. Run 'fleet-integrity-check init $TARGET_DIR' first."
          exit 1
        fi
        echo "==> Verifying file integrity against $MANIFEST..."
        ${pkgs.rhash}/bin/rhash --sha256 --check "$MANIFEST"
        ;;
      *)
        echo "Usage: fleet-integrity-check <init|update|verify> [directory]"
        exit 1
        ;;
    esac
  '';
in
{
  environment.systemPackages = [
    pkgs.rhash
    fleetIntegrityCheck
  ];
}
