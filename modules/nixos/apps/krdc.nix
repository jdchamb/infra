# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/krdc.nix (KDE Remote Desktop Client)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 10 — 1-to-1 Module for KRDC):
#   Installs KDE's KRDC remote desktop client for connecting to VNC (UltraVNC)
#   and RDP Windows 11 endpoints across USD 308 buildings.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.kdePackages.krdc
  ];
}
