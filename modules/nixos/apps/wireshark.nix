# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/wireshark.nix (Wireshark Packet Analyzer)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 16, 17, 18 — 1-to-1 Module for Wireshark):
#   Enables Wireshark with non-root packet capture capabilities ('dumpcap') and
#   adds 'jchambers' to the 'wireshark' group for inspecting VLAN tags, PoE LLDP
#   frames, and Brocade switch traffic.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Wireshark shows every network packet passing through a network card, which
#   is the ultimate tool for answering "why can't these two devices talk?".
#   Capturing raw packets normally requires root. Running the whole Wireshark
#   GUI as root is a security risk, so NixOS's 'programs.wireshark' module
#   installs a tiny privileged helper ('dumpcap') that only members of the
#   'wireshark' group may run. The GUI itself runs as your normal user.
#
#   We use 'programs.wireshark' (not just environment.systemPackages) precisely
#   because it creates that group and the capability-wrapped 'dumpcap'.
# ==============================================================================

{ config, pkgs, ... }:

{
  # 1. Enable Wireshark with the capability-restricted 'dumpcap' wrapper
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark; # Full Qt GUI build (vs. 'wireshark-cli' terminal-only)
  };

  # 2. Allow 'jchambers' to capture packets without sudo
  users.users.jchambers.extraGroups = [ "wireshark" ];
}
