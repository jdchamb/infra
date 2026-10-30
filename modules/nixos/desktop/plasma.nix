# ==============================================================================
# NIXOS DESKTOP MODULE: modules/nixos/desktop/plasma.nix (KDE Plasma 6 Desktop)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 22 — 1-to-1 Module for KDE Plasma 6):
#   Configures the KDE Plasma 6 Wayland desktop environment with SDDM Wayland,
#   enforcing the Breeze Dark color scheme ('kdeglobals') and compact 8pt
#   JetBrains Mono UI typography across panels, menus, and toolbars.
#   Pair with 'modules/nixos/desktop/krohnkite.nix' for dynamic KWin tiling.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # 1. Enable KDE Plasma 6 Desktop & SDDM Wayland Display Manager
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = lib.mkDefault true;
    wayland.enable = lib.mkDefault true;
  };

  # 2. Declarative User-Space KDE Dark Mode & Smallest High-Density Typography (Project 22)
  home-manager.users.jchambers = { ... }: {
    xdg.configFile."kdeglobals".text = ''
      [Colors:View]
      BackgroundAlternate=#181825
      BackgroundNormal=#1e1e2e
      ForegroundNormal=#cdd6f4

      [General]
      ColorScheme=BreezeDark
      Name=Breeze Dark
      fixed=JetBrains Mono,8,-1,5,50,0,0,0,0,0
      font=JetBrains Mono,8,-1,5,50,0,0,0,0,0
      menuFont=JetBrains Mono,8,-1,5,50,0,0,0,0,0
      smallestReadableFont=JetBrains Mono,7,-1,5,50,0,0,0,0,0
      toolBarFont=JetBrains Mono,8,-1,5,50,0,0,0,0,0
      shadeSortColumn=true

      [Icons]
      Theme=breeze-dark

      [KDE]
      LookAndFeelPackage=org.kde.breezedark.desktop
      SingleClick=false
      widgetStyle=Breeze
    '';
  };
}
