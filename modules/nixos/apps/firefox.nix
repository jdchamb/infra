# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/firefox.nix (Mozilla Firefox Browser)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for Firefox):
#   Installs Mozilla Firefox at the system level with Wayland-native rendering
#   support for web administration (Snipe-IT, Codeberg, AdGuard Home).
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.firefox
  ];
}
