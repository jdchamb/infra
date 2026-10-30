# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/firefox.nix (Mozilla Firefox Browser)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for Firefox):
#   Installs Mozilla Firefox at the system level with Wayland-native rendering
#   support for web administration (Snipe-IT, Codeberg, AdGuard Home).
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Every graphical workstation and recovery live ISO needs a reliable,
#   standards-compliant web browser for accessing internal web consoles
#   (like Snipe-IT asset management, Proxmox/Cockpit, Zammad, and Codeberg).
# ==============================================================================

{ pkgs, ... }:

{
  # Install Mozilla Firefox globally across the system
  environment.systemPackages = [
    pkgs.firefox
  ];
}
