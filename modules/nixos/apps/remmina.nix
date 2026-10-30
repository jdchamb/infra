# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/remmina.nix (Remmina Remote Desktop)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for Remmina):
#   Installs Remmina for managing remote Windows Server (PDQ, WDS, AD), macOS,
#   and VNC endpoints across the USD 308 network and on the recovery ISO.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Remmina is a "connection manager": it saves a list of servers with their
#   protocol (RDP, VNC, SSH, SPICE), username, and display settings, so you can
#   reconnect to the PDQ server or a domain controller with one double-click.
#   It is GTK-based, so it works well on non-KDE desktops (Sway/Hyprland/Niri)
#   and on the recovery ISO, complementing KDE's KRDC ('krdc.nix').
# ==============================================================================

{ pkgs, ... }:

{
  # Install Remmina multi-protocol remote desktop client
  environment.systemPackages = [
    pkgs.remmina
  ];
}
