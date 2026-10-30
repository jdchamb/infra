# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/wireshark.nix (Wireshark Packet Analyzer)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 16, 17, 18 — 1-to-1 Module for Wireshark):
#   Enables Wireshark with non-root packet capture capabilities ('dumpcap') and
#   adds 'jchambers' to the 'wireshark' group for inspecting VLAN tags, PoE LLDP
#   frames, and Brocade switch traffic.
# ==============================================================================

{ config, pkgs, ... }:

{
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  users.users.jchambers.extraGroups = [ "wireshark" ];
}
