# ==============================================================================
# SHARED STORAGE MODULE: modules/shared/storage/file-integrity-monitor.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 2):
#   Provides the File Integrity & Checksum Health Monitor ('rhash' + custom
#   'fleet-integrity-check' CLI) across Linux and macOS nodes. Generates and
#   verifies '.sha256' / 'SHA256SUMS' manifests alongside critical archives,
#   USB ISO libraries, and NAS cold storage to detect silent bitrot corruption.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Hard drives, SSDs, and especially USB flash drives can suffer from "bitrot"—
#   where magnetic or flash cells slowly degrade over months or years, flipping a
#   single bit inside a large Windows/NixOS installer ISO or backup archive without
#   changing the file's size or timestamp. If you don't verify checksums, you won't
#   know a file is corrupted until an emergency restore fails!
#
#   This module builds a custom shell command called 'fleet-integrity-check'
#   powered by 'rhash' (Recursive Hasher):
#     1. 'fleet-integrity-check init /path/to/folder'
#        Scans every file in the folder (and subfolders) and writes its digital
#        fingerprint (SHA-256 hash) into a 'SHA256SUMS' file.
#     2. 'fleet-integrity-check update /path/to/folder'
#        Adds hashes for any newly added files without re-hashing unchanged files.
#     3. 'fleet-integrity-check verify /path/to/folder'
#        Re-calculates every file's SHA-256 fingerprint and alerts you immediately
#        if any file has suffered bitrot or unexpected modification.
# ==============================================================================

{ pkgs, ... }:

let
  # 'pkgs.writeShellScriptBin' compiles an executable bash script directly into
  # '/nix/store/.../bin/fleet-integrity-check' with its exact dependency paths
  # (${pkgs.rhash}/bin/rhash) permanently baked in so it can never break.
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
  # Install both the underlying 'rhash' utility and our 'fleet-integrity-check'
  # wrapper script globally across all Linux and macOS machines.
  environment.systemPackages = [
    pkgs.rhash
    fleetIntegrityCheck
  ];
}
