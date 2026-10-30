# ==============================================================================
# NIXOS DESKTOP MODULE: modules/nixos/desktop/krohnkite.nix (KWin Tiling Engine)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 23 — 1-to-1 Module for Krohnkite):
#   Installs the 'krohnkite' dynamic tiling extension for KWin (the window manager
#   of KDE Plasma 6) and declaratively configures automated tiling layouts (Tile,
#   Quarter, Three-Column, Monocle) with 6-pixel screen gaps, mouse-follows-focus,
#   and borderless maximized windows in 'kwinrc'.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - Why use Krohnkite with KDE Plasma? Dedicated tiling window managers (like
#     Hyprland or Sway) require configuring everything from scratch (status bars,
#     Bluetooth menus, display scaling, audio mixers).
#     KDE Plasma provides a polished, battle-tested desktop experience with complete
#     system settings, but defaults to floating windows.
#     Krohnkite bridges the gap: it is a KWin script that automatically organizes
#     your windows into clean, non-overlapping tiles inside KDE Plasma, giving you
#     the keyboard-driven productivity of a tiling window manager combined with the
#     rock-solid features of KDE.
#   - Layouts Activated:
#       - Tile Layout: Master-and-stack layout (main work window on left, stacked tools on right).
#       - Quarter Layout: Divides the screen into four equal quadrants.
#       - Three-Column Layout: Centers the main window between two secondary sidebars.
#       - Monocle Layout: Fullscreens the current window, hiding others behind it.
#   - 'screenGapBetween = 6': Leaves a 6-pixel gap between adjacent windows for visual clarity.
#   - 'FocusFollowsMouse': Automatically focuses windows as you hover over them.
#
# HOW TO USE:
#   - Included on KDE Plasma workstations.
#   - Toggle tiling on/off: Meta + \ (Backslash)
#   - Cycle layouts: Meta + Space
#   - Move focus: Meta + H / J / K / L
# ==============================================================================

{ config, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. System Package: Krohnkite KWin Script
  # Installs the KDE Plasma 6 compatible Krohnkite script into the system environment.
  # --------------------------------------------------------------------------
  environment.systemPackages = [
    pkgs.kdePackages.krohnkite
  ];

  # --------------------------------------------------------------------------
  # 2. Declarative KWin Configuration (Home Manager for 'jchambers')
  # --------------------------------------------------------------------------
  home-manager.users.jchambers = { ... }: {
    # Injects ~/.config/kwinrc parameters on activation
    xdg.configFile."kwinrc".text = ''
      [Plugins]
      krohnkiteEnabled=true

      [Script-krohnkite]
      # Active tiling layout algorithms
      enableMonocleLayout=true
      enableQuarterLayout=true
      enableSpreadLayout=false
      enableStairLayout=false
      enableThreeColumnLayout=true
      enableTileLayout=true

      # Aesthetic margin spacing around tiles (in pixels)
      screenGapBetween=6
      screenGapBottom=6
      screenGapLeft=6
      screenGapRight=6
      screenGapTop=6

      [Windows]
      # Remove bulky window titlebars when a window is maximized
      BorderlessMaximizedWindows=true
      # Automatically activate the window beneath the mouse cursor without clicking
      FocusPolicy=FocusFollowsMouse
    '';
  };
}
