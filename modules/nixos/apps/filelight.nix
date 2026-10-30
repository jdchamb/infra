# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/filelight.nix (Storage Usage Analyzer)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for Filelight):
#   Installs KDE Filelight to visualize filesystem capacity via interactive
#   concentric sunburst rings.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.kdePackages.filelight
  ];
}
