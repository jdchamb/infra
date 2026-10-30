# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/isoimagewriter.nix (USB ISO Flasher)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 1 — 1-to-1 Module for ISO Image Writer):
#   Installs KDE 'isoimagewriter' for writing compiled NixOS bootstrap/recovery
#   ISOs and Windows 11 deployment images safely onto physical USB media.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Flashing bootable USB drives using raw 'dd' commands in the terminal is
#   notoriously dangerous—a single typo in '/dev/sdX' can overwrite your main
#   OS drive. KDE ISO Image Writer provides a safe graphical picker that only
#   lists removable USB flash drives and verifies the image as it writes.
# ==============================================================================

{ pkgs, ... }:

{
  # Install KDE ISO Image Writer GUI utility
  environment.systemPackages = [
    pkgs.kdePackages.isoimagewriter
  ];
}
