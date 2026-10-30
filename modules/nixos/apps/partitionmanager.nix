# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/partitionmanager.nix (Disk Partitioner)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for KDE Partition Manager):
#   Installs KDE Partition Manager for interactive inspection, resizing, and
#   formatting of GPT/MBR partition tables on external USB and lab drives.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Permanent machines in this fleet are partitioned declaratively by Disko
#   ('modules/nixos/hardware/disko-*.nix'). But for one-off tasks—wiping a
#   donated USB drive, inspecting a failed laptop's SSD, or recovering a
#   corrupted partition table—a visual tool is safer and faster than typing
#   'fdisk' commands. It is also bundled on the recovery ISO for that reason.
#
# CAUTION: Changes made here are destructive and NOT tracked by Nix. Always
# double-check the selected device before clicking "Apply".
# ==============================================================================

{ pkgs, ... }:

{
  # Install KDE Partition Manager GUI
  environment.systemPackages = [
    pkgs.kdePackages.partitionmanager
  ];
}
