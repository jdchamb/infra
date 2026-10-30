# ==============================================================================
# NIXOS DESKTOP MODULE: modules/nixos/desktop/plasma.nix (KDE Plasma 6 Desktop)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 22 — 1-to-1 Module for KDE Plasma 6):
#   Deploys the full KDE Plasma 6 desktop environment running natively on Wayland,
#   backed by the SDDM display manager. Enforces declarative dark mode styling
#   (Breeze Dark) and compact, high-density 8pt JetBrains Mono typography across
#   all desktop menus, taskbars, panels, and Qt applications in 'kdeglobals'.
#   Pair with 'modules/nixos/desktop/krohnkite.nix' for dynamic KWin window tiling.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - What is KDE Plasma 6? Plasma is one of the most powerful, mature, and customizable
#     desktop environments in the Linux world. Version 6 represents a major architectural
#     leap: fully ported to Qt 6 and Wayland by default, delivering silky-smooth display
#     scaling, HDR support, and robust multi-monitor management.
#   - Declarative Theming ('kdeglobals'): Normally, configuring a desktop requires
#     clicking through dozens of GUI settings menus. This module writes the core
#     KDE configuration file ('kdeglobals') declaratively:
#       - Color Scheme: Breeze Dark (matches our terminal and editor themes).
#       - Typography: Compact 8pt JetBrains Mono font everywhere for high information
#         density on developer and technician screens.
#       - Double-Click: Disables KDE's legacy single-click file opening ('SingleClick=false')
#         in favor of standard double-click navigation.
#
# HOW TO USE:
#   - Select "Plasma (Wayland)" at the SDDM login screen.
#   - Pair with 'modules/nixos/desktop/krohnkite.nix' if you want automated window tiling.
#   - Launch applications via the Application Launcher menu (bottom-left) or Meta key.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. Desktop & Display Manager Activation
  # --------------------------------------------------------------------------
  # Enables KDE Plasma 6 desktop environment and core KDE services
  services.desktopManager.plasma6.enable = true;

  # Simple Desktop Display Manager (SDDM) configured with the Wayland backend
  services.displayManager.sddm = {
    enable = lib.mkDefault true;
    wayland.enable = lib.mkDefault true;
  };

  # --------------------------------------------------------------------------
  # 2. Declarative Desktop Theming (Home Manager for 'jchambers')
  # --------------------------------------------------------------------------
  home-manager.users.jchambers = { ... }: {
    # Seeds ~/.config/kdeglobals to lock in colors, fonts, and interaction defaults
    xdg.configFile."kdeglobals".text = ''
      [Colors:View]
      BackgroundAlternate=#181825
      BackgroundNormal=#1e1e2e
      ForegroundNormal=#cdd6f4

      [General]
      ColorScheme=BreezeDark
      Name=Breeze Dark
      # High-density 8pt JetBrains Mono typography across all interface elements
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
      # Enforce standard double-click to open files and folders
      SingleClick=false
      widgetStyle=Breeze
    '';
  };
}
