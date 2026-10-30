# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/nmap.nix (Network Discovery & Port Scanner)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 16 & 17 — 1-to-1 Module for Nmap):
#   Installs 'nmap' for subnet host discovery, switch management port auditing,
#   and RTSP/ONVIF service probing on Reolink PoE doorbell cameras.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.nmap
  ];
}
