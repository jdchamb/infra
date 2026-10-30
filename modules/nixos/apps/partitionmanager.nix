# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/partitionmanager.nix (Disk Partitioner)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for KDE Partition Manager):
#   Installs KDE Partition Manager for interactive inspection, resizing, and
#   formatting of GPT/MBR partition tables on external USB and lab drives.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.kdePackages.partitionmanager
  ];
}
