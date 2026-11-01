# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/secureboot.nix (Lanzaboote Secure Boot)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Provides declarative UEFI Secure Boot support across all NixOS machines using
#   Lanzaboote ('github:nix-community/lanzaboote') and 'sbctl'.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - Traditional Linux distributions often rely on Microsoft-signed Shim loaders
#     (Ubuntu/Fedora model). NixOS builds kernels and initrds deterministically
#     for every generation, which cannot be pre-signed by an external vendor.
#   - Lanzaboote solves this "the Nix way": it replaces the standard systemd-boot
#     installer hook with 'lzbt', which signs each NixOS generation's kernel,
#     initrd, and systemd-boot EFI binary directly on the machine.
#   - This module supports:
#       1. "Out-of-the-box boot": Before keys are generated or enrolled, the
#          system allows unsigned artifacts so installation and initial boot never fail.
#       2. "Auto Key Generation": Systemd automatically creates root-owned Secure Boot
#          keys in '/var/lib/sbctl' on first boot if they do not exist.
#       3. "Auto Key Enrollment": Prepares EFI authentication variables ({PK,KEK,db}.auth)
#          and places them in the ESP loader directory with Microsoft vendor keys included.
#          When the user resets their motherboard UEFI to "Setup Mode", systemd-boot
#          automatically enrolls the keys into firmware on the next reboot.
#       4. "Manual Enrollment / CLI Control": Installs 'sbctl' system-wide so administrators
#          can verify status via 'sbctl status' or run 'sudo sbctl enroll-keys --microsoft'.
#
# OPERATIONAL WORKFLOW:
#   Step 1: Deploy configuration via 'rebuild' (or nixos-rebuild switch).
#   Step 2: On reboot, 'sbctl' creates keys in '/var/lib/sbctl' and stages enrollment.
#   Step 3: To enforce Secure Boot:
#           - Option A (Automatic): Reboot into BIOS/UEFI -> Security -> Secure Boot ->
#             "Reset to Setup Mode" -> Save & Exit. systemd-boot will enroll keys and lock mode.
#           - Option B (Manual CLI): In terminal, run:
#               sudo sbctl enroll-keys --microsoft
#               sudo reboot
#   Step 4: Verify active state after reboot:
#           bootctl status
#           # Look for: "Secure Boot: enabled (user)"
# ==============================================================================

{ config, pkgs, lib, ... }:

let
  cfg = config.core.secureboot;
in
{
  options.core.secureboot = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to enable declarative UEFI Secure Boot integration via Lanzaboote.
      '';
    };

    autoEnroll = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to stage generated keys into the EFI System Partition so systemd-boot
        can automatically enroll them into UEFI firmware when the motherboard is in Setup Mode.
      '';
    };

    pkiBundle = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/sbctl";
      description = ''
        Directory storing the Secure Boot PKI keys (PK, KEK, db).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Lanzaboote manages the systemd-boot binary and entries directly.
    # We must force standard systemd-boot installation to false so the two hooks do not clash.
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = cfg.pkiBundle;

      # Allow unsigned boot artifacts during initial build/rebuild before keys exist.
      # Automatically set to true by autoGenerateKeys.
      autoGenerateKeys.enable = true;

      autoEnrollKeys = lib.mkIf cfg.autoEnroll {
        enable = true;
        # Include Microsoft vendor keys to ensure third-party UEFI Option ROMs (e.g. GPUs,
        # Thunderbolt, NICs) and dual-boot Windows partitions continue to boot smoothly.
        includeMicrosoftKeys = true;
      };
    };

    # sbctl CLI for checking status, key inspection, and manual enrollment
    environment.systemPackages = [ pkgs.sbctl ];
  };
}
