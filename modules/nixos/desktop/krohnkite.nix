# ==============================================================================
# NIXOS DESKTOP MODULE: modules/nixos/desktop/krohnkite.nix (KWin Tiling Engine)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 23 — 1-to-1 Module for Krohnkite):
#   Installs the 'krohnkite' dynamic tiling extension for KWin 6 (the modern
#   Plasma 6 successor to Bismuth) and declaratively activates Quarter, Monocle,
#   Three-Column, and Tile layouts with 6px screen gaps inside 'kwinrc'.
# ==============================================================================

{ config, pkgs, ... }:

{
  # 1. Install Krohnkite KWin Tiling Script Package
  environment.systemPackages = [
    pkgs.kdePackages.krohnkite
  ];

  # 2. Declaratively Enable Krohnkite Tiling & Gaps in KWin (Project 23)
  home-manager.users.jchambers = { ... }: {
    xdg.configFile."kwinrc".text = ''
      [Plugins]
      krohnkiteEnabled=true

      [Script-krohnkite]
      enableMonocleLayout=true
      enableQuarterLayout=true
      enableSpreadLayout=false
      enableStairLayout=false
      enableThreeColumnLayout=true
      enableTileLayout=true
      screenGapBetween=6
      screenGapBottom=6
      screenGapLeft=6
      screenGapRight=6
      screenGapTop=6

      [Windows]
      BorderlessMaximizedWindows=true
      FocusPolicy=FocusFollowsMouse
    '';
  };
}
