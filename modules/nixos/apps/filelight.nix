# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/filelight.nix (Storage Usage Analyzer)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for Filelight):
#   Installs KDE Filelight to visualize filesystem capacity via interactive
#   concentric sunburst rings.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When a workstation SSD or network share starts filling up, running 'df -h'
#   only tells you that the drive is full, not *which* nested folder is hogging
#   gigabytes of space. Filelight scans any directory or mountpoint and draws an
#   interactive color-coded radial map so you can spot giant ISOs, caches, or
#   logs at a glance.
# ==============================================================================

{ pkgs, ... }:

{
  # Install KDE Filelight graphical disk usage visualizer
  environment.systemPackages = [
    pkgs.kdePackages.filelight
  ];
}
