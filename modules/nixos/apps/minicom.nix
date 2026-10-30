# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/minicom.nix (RS-232 Serial Console Client)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 17 — 1-to-1 Module for Minicom):
#   Installs 'minicom' and grants 'jchambers' membership in the 'dialout' group
#   for direct USB-to-RJ45 serial console access (9600 8N1) to the homelab
#   Brocade ICX switch.
# ==============================================================================

{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.minicom
  ];

  users.users.jchambers.extraGroups = [ "dialout" ];
}
