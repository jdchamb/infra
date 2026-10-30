# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/kdf.nix (KDiskFree Mount Monitor)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for KDiskFree):
#   Installs KDE's KDiskFree utility to monitor free space and mount status
#   across local NVMe partitions and USD 308 CIFS network shares.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   KDiskFree is a graphical version of the 'df -h' command. It shows every
#   mounted drive (local disks, USB sticks, and SMB network shares like
#   WorkStorage/CloudStorage) with a usage bar, so you can quickly spot a full
#   disk or a network share that failed to mount. Filelight ('filelight.nix')
#   answers "WHAT is using space"; KDiskFree answers "WHICH drives are full".
# ==============================================================================

{ pkgs, ... }:

{
  # Install the KDE KDiskFree graphical mount/free-space monitor
  environment.systemPackages = [
    pkgs.kdePackages.kdf
  ];
}
