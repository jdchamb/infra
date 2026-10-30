# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/kdf.nix (KDiskFree Mount Monitor)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for KDiskFree):
#   Installs KDE's KDiskFree utility to monitor free space and mount status
#   across local NVMe partitions and USD 308 CIFS network shares.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.kdePackages.kdf
  ];
}
